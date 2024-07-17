
-- Source topics is Avro serialized.
-- Flink UI : http://localhost:9081/#/overview

-- The below builds avro_salescompleted_x locally (on Apache Flink environment) as a output of a join from below 2 tables, the join results are inserted into avro_salescompleted_x.
-- salesbaskets_x and salespayments_x is build as virtual tables from the original topics (salesbaskets and salespayments)
-- join key is invoiceNumber.

-- After this we do a simple aggregate on sales per store per terminal per 5min and per hour (these values are at the root of the avro_salesbaskets table).
-- After this we unnest the baskeItems array into table:unnested_sales and then calculate:
-- sales per store per product per 5 min
-- sales per store per brand per 5 min
-- sales per store per category per 5min

-- NOTE: Case sentivity... need to match the case as per types/fs.go structs avro sections.
-- pull (INPUT) the avro_salesbaskets topic into Flink into avro_salesbaskets_x
CREATE TABLE avro_salesbaskets_x (
    `invoiceNumber` STRING,
    `saleDateTime_Ltz` STRING,
    `saleTimestamp_Epoc` STRING,
    `terminalPoint` STRING,
    `nett` DOUBLE,
    `vat` DOUBLE,
    `total` DOUBLE,
    `store` row<`id` STRING, `name` STRING>,
    `clerk` row<`id` STRING, `name` STRING, `surname` STRING>,
    `basketItems` array<row<`id` STRING, `name` STRING, `brand` STRING, `category` STRING, `price` DOUBLE, `quantity` INT>>,
    `saleTimestamp_WM` AS TO_TIMESTAMP(FROM_UNIXTIME(CAST(`saleTimestamp_Epoc` AS BIGINT) / 1000)),
    WATERMARK FOR `saleTimestamp_WM` AS `saleTimestamp_WM`
) WITH (
    'connector' = 'kafka',
    'topic' = 'avro_salesbaskets',
    'properties.bootstrap.servers' = 'broker:29092',
    'properties.group.id' = 'testGroup',
    'scan.startup.mode' = 'earliest-offset',
    'value.format' = 'avro-confluent',
    'value.avro-confluent.schema-registry.url' = 'http://schema-registry:8081',
    'value.fields-include' = 'ALL'
);

-- pull (INPUT) the avro_salespayments topic into Flink (avro_salespayments_x)
CREATE TABLE avro_salespayments_x (
    `invoiceNumber` STRING,
    `payDateTime_Ltz` STRING,
    `payTimestamp_Epoc` STRING,
    `paid` DOUBLE,
    `finTransactionId` STRING,
    `payTimestamp_WM` AS TO_TIMESTAMP(FROM_UNIXTIME(CAST(`payTimestamp_Epoc` AS BIGINT) / 1000)),
    WATERMARK FOR `payTimestamp_WM` AS `payTimestamp_WM`
) WITH (
    'connector' = 'kafka',
    'topic' = 'avro_salespayments',
    'properties.bootstrap.servers' = 'broker:29092',
    'properties.group.id' = 'testGroup',
    'scan.startup.mode' = 'earliest-offset',
    'value.format' = 'avro-confluent',
    'value.avro-confluent.url' = 'http://schema-registry:8081', 
    'value.avro-confluent.properties.use.latest.version' = 'true',
    'value.fields-include' = 'ALL'
);


-- Our avro_salescompleted_x (OUTPUT) table which will push values to the CP Kafka topic.
-- https://nightlies.apache.org/flink/flink-docs-release-1.13/docs/connectors/table/formats/avro-confluent/
CREATE TABLE avro_salescompleted_x (
    `invoiceNumber` STRING,
    `saleDateTime_Ltz` STRING,
    `saleTimestamp_Epoc` STRING,
    `terminalPoint` STRING,
    `nett` DOUBLE,
    `vat` DOUBLE,
    `total` DOUBLE,
    `store` row<`id` STRING, `name` STRING>,
    `clerk` row<`id` STRING, `name` STRING, `surname` STRING>,
    `basketItems` array<row<`id` STRING, `name` STRING, `brand` STRING, `category` STRING, `price` DOUBLE, `quantity` INT>>,     
    `payDateTime_Ltz` STRING,
    `payTimestamp_Epoc` STRING,
    `paid` DOUBLE,
    `finTransactionId` STRING,
    `payTimestamp_WM` AS TO_TIMESTAMP(FROM_UNIXTIME(CAST(`payTimestamp_Epoc` AS BIGINT) / 1000)),
    `saleTimestamp_WM` AS TO_TIMESTAMP(FROM_UNIXTIME(CAST(`saleTimestamp_Epoc` AS BIGINT) / 1000)),
    WATERMARK FOR `saleTimestamp_WM` AS `saleTimestamp_WM`
) WITH (
    'connector' = 'kafka',
    'topic' = 'avro_salescompleted_x',
    'properties.bootstrap.servers' = 'broker:29092',
    'properties.group.id' = 'testGroup',
    'scan.startup.mode' = 'earliest-offset',
    'value.format' = 'avro-confluent',
    'value.avro-confluent.schema-registry.url' = 'http://schema-registry:8081',
    'value.fields-include' = 'ALL'
);

-- the fields in the select is case sensitive, needs to match theprevious create tables which match the definitions in the struct/avro sections.
Insert into avro_salescompleted_x
select
        b.invoiceNumber,
        b.saleDateTime_Ltz,
        b.saleTimestamp_Epoc,
        b.terminalPoint,
        b.nett,
        b.vat,
        b.total,
        b.store,
        b.clerk,    
        b.basketItems,        
        a.payDateTime_Ltz,
        a.payTimestamp_Epoc,
        a.paid,
        a.finTransactionId
    FROM 
        avro_salespayments_x a,
        avro_salesbaskets_x b
    WHERE a.invoiceNumber = b.invoiceNumber
    AND a.payTimestamp_WM > b.saleTimestamp_WM 
    AND b.saleTimestamp_WM > (b.saleTimestamp_WM - INTERVAL '1' HOUR);


-- Create sales per store per terminal per 5 min output table - dev purposes
CREATE TABLE avro_sales_per_store_per_terminal_per_5min_x (
    `store_id` STRING,
    `terminalPoint` STRING,
    window_start  TIMESTAMP(3),
    window_end TIMESTAMP(3),
    `salesperterminal` BIGINT,
    `totalperterminal` DOUBLE
) WITH (
    'connector' = 'kafka',
    'topic' = 'avro_sales_per_store_per_terminal_per_5min_x',
    'properties.bootstrap.servers' = 'broker:29092',
    'properties.group.id' = 'testGroup',
    'scan.startup.mode' = 'earliest-offset',
    'value.format' = 'avro-confluent',
    'value.avro-confluent.url' = 'http://schema-registry:8081',
    'value.fields-include' = 'ALL'
);

-- Calculate sales per store per terminal per 5 min - dev purposes
-- Aggregate query/worker
Insert into avro_sales_per_store_per_terminal_per_5min_x
SELECT 
    `store`.`id` as `store_id`,
    terminalPoint,
    window_start,
    window_end,
    COUNT(*) as `salesperterminal`,
    SUM(total) as `totalperterminal`
  FROM TABLE(
    TUMBLE(TABLE avro_salescompleted_x, DESCRIPTOR(saleTimestamp_WM), INTERVAL '5' MINUTES))
  GROUP BY `store`.`id`, terminalPoint, window_start, window_end;


-- Create sales per store per terminal per hour output table
CREATE TABLE avro_sales_per_store_per_terminal_per_hour_x (
    `store_id` STRING,
    `terminalPoint` STRING,
    window_start  TIMESTAMP(3),
    window_end TIMESTAMP(3),
    `salesperterminal` BIGINT,
    `totalperterminal` DOUBLE
) WITH (
    'connector' = 'kafka',
    'topic' = 'avro_sales_per_store_per_terminal_per_hour_x',
    'properties.bootstrap.servers' = 'broker:29092',
    'properties.group.id' = 'testGroup',
    'scan.startup.mode' = 'earliest-offset',
    'value.format' = 'avro-confluent',
    'value.avro-confluent.url' = 'http://schema-registry:8081',
    'value.fields-include' = 'ALL'
);

-- Calculate sales per store per terminal per hour
Insert into avro_sales_per_store_per_terminal_per_hour_x
SELECT 
    `store`.`id` as `store_id`,
    terminalPoint,
    window_start,
    window_end,
    COUNT(*) as `salesperterminal`,
    SUM(total) as `totalperterminal`
  FROM TABLE(
    TUMBLE(TABLE avro_salescompleted_x, DESCRIPTOR(saleTimestamp_WM), INTERVAL '1' HOUR))
  GROUP BY `store`.`id`, terminalPoint, window_start, window_end;


--- unest the salesBasket
CREATE TABLE unnested_sales (
    `store_id` STRING,
    `product` STRING,
    `brand` STRING,
    `saleValue` DOUBLE,
    `category` STRING,
    `saleDateTime_Ltz` STRING,
    `saleTimestamp_Epoc` STRING,
    `saleTimestamp_WM` AS TO_TIMESTAMP(FROM_UNIXTIME(CAST(`saleTimestamp_Epoc` AS BIGINT) / 1000)),
    WATERMARK FOR `saleTimestamp_WM` AS `saleTimestamp_WM`
) WITH (
    'connector' = 'kafka',
    'topic' = 'unnested_sales',
    'properties.bootstrap.servers' = 'broker:29092',
    'properties.group.id' = 'testGroup',
    'scan.startup.mode' = 'earliest-offset',
    'value.format' = 'avro-confluent',
    'value.avro-confluent.url' = 'http://schema-registry:8081',
    'value.fields-include' = 'ALL'
);

-- TESTING
CREATE TABLE unnested_salesxx (
    `store_id` STRING,
    `product` STRING,
    `brand` STRING,
    `saleValue` DOUBLE,
    `category` STRING,
    `saleDateTime_Ltz` STRING,
    `saleTimestamp_Epoc` STRING,
    `saleTimestamp_WM` AS TO_TIMESTAMP(FROM_UNIXTIME(CAST(`saleTimestamp_Epoc` AS BIGINT) / 1000)),
    WATERMARK FOR `saleTimestamp_WM` AS `saleTimestamp_WM`
) PARTITIONED BY (`store_id`) 
WITH (
    'connector' = 'kafka',
    'topic' = 'unnested_sales',
    'properties.bootstrap.servers' = 'broker:29092',
    'properties.group.id' = 'testGroup',
    'scan.startup.mode' = 'earliest-offset',
    'value.format' = 'avro-confluent',
    'value.avro-confluent.url' = 'http://schema-registry:8081',
    'value.fields-include' = 'ALL'
);

insert into unnested_salesxx 
SELECT
      `store`.`id` as `store_id`,
      bi.`name` AS `product`,
      bi.`brand` AS `brand`,
      bi.`price` * bi.`quantity` AS `saleValue`,
      bi.`category` AS `category`,
      `saleDateTime_Ltz` as saleDateTime_Ltz,
      `saleTimestamp_Epoc` as saleTimestamp_Epoc
    FROM avro_salescompleted_x  -- assuming avro_salescompleted_x is a table function
    CROSS JOIN UNNEST(`basketItems`) AS bi;


-- Sales per store per brand per 5 min - output table
CREATE TABLE avro_sales_per_store_per_brand_per_5min_x (
  `store_id` STRING,
  `brand` STRING,
  window_start  TIMESTAMP(3),
  window_end TIMESTAMP(3),
  `salesperbrand` BIGINT,
  `totalperbrand` DOUBLE
) WITH (
    'connector' = 'kafka',
    'topic' = 'avro_sales_per_store_per_brand_per_5min_x',
    'properties.bootstrap.servers' = 'broker:29092',
    'properties.group.id' = 'testGroup',
    'scan.startup.mode' = 'earliest-offset',
    'value.format' = 'avro-confluent',
    'value.avro-confluent.url' = 'http://schema-registry:8081',
    'value.fields-include' = 'ALL'
);

Insert into avro_sales_per_store_per_brand_per_5min_x
SELECT 
    store_id,
    brand,
    window_start,
    window_end,
    COUNT(*) as `salesperbrand`,
    SUM(saleValue) as `totalperbrand`
  FROM TABLE(
    TUMBLE(TABLE unnested_sales, DESCRIPTOR(saleTimestamp_WM), INTERVAL '5' MINUTE))
  GROUP BY store_id, brand, window_start, window_end;


-- Sales per store per product per 5 min - output table
CREATE TABLE avro_sales_per_store_per_product_per_5min_x (
  `store_id` STRING,
  `product` STRING,
  window_start  TIMESTAMP(3),
  window_end TIMESTAMP(3),
  `salesperproduct` BIGINT,
  `totalperproduct` DOUBLE
) WITH (
    'connector' = 'kafka',
    'topic' = 'avro_sales_per_store_per_product_per_5min_x',
    'properties.bootstrap.servers' = 'broker:29092',
    'properties.group.id' = 'testGroup',
    'scan.startup.mode' = 'earliest-offset',
    'value.format' = 'avro-confluent',
    'value.avro-confluent.url' = 'http://schema-registry:8081',
    'value.fields-include' = 'ALL'
);

Insert into avro_sales_per_store_per_product_per_5min_x
SELECT 
    store_id,
    product,
    window_start,
    window_end,
    COUNT(*) as `salesperproduct`,
    SUM(saleValue) as `totalperproduct`
  FROM TABLE(
    TUMBLE(TABLE unnested_sales, DESCRIPTOR(saleTimestamp_WM), INTERVAL '5' MINUTE))
  GROUP BY store_id, product, window_start, window_end;

-- Sales per store per category per 5 min - output table
CREATE TABLE avro_sales_per_store_per_category_per_5min_x (
  `store_id` STRING,
  `category` STRING,
  window_start  TIMESTAMP(3),
  window_end TIMESTAMP(3),
  `salesperproduct` BIGINT,
  `totalperproduct` DOUBLE
) WITH (
    'connector' = 'kafka',
    'topic' = 'avro_sales_per_store_per_category_per_5min_x',
    'properties.bootstrap.servers' = 'broker:29092',
    'properties.group.id' = 'testGroup',
    'scan.startup.mode' = 'earliest-offset',
    'value.format' = 'avro-confluent',
    'value.avro-confluent.url' = 'http://schema-registry:8081',
    'value.fields-include' = 'ALL'
);

Insert into avro_sales_per_store_per_category_per_5min_x
SELECT 
    store_id,
    category,
    window_start,
    window_end,
    COUNT(*) as `salespercategory`,
    SUM(saleValue) as `totalpercategory`
  FROM TABLE(
    TUMBLE(TABLE unnested_sales, DESCRIPTOR(saleTimestamp_WM), INTERVAL '5' MINUTE))
  GROUP BY store_id, category, window_start, window_end;
