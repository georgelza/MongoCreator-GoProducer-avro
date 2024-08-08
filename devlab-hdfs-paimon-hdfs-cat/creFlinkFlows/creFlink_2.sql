
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

-- Add sink to Paimon on HDFS

-- Our avro_salescompleted_x (OUTPUT) table which will push values to the CP Kafka topic.
-- https://nightlies.apache.org/flink/flink-docs-release-1.13/docs/connectors/table/formats/avro-confluent/


-- Change the file.format='pick option' to change the file version. options are Avro, ORC or Parquet.


-- Create a data Source, pulling data from Kafka topic, table definition recorded in our hive catalog

-- Set checkpoint to happen every minute
SET 'execution.checkpointing.interval' = '60sec';

-- Set this so that the operators are separate in the Flink WebUI.
SET 'pipeline.operator-chaining.enabled' = 'false';

-- display mode
-- SET 'sql-client.execution.result-mode' = 'table';

-- SET 'execution.runtime-mode' = ''streaming;
-- SET 'execution.runtime-mode' = ''batch;

SET 'pipeline.name' = 'Sales Basket Injestion - Kafka Source';

CREATE OR REPLACE TABLE c_hive.db01.t_k_avro_salesbaskets_x (
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
    `saleTimestamp_WM` as TO_TIMESTAMP(FROM_UNIXTIME(CAST(`saleTimestamp_Epoc` AS BIGINT) / 1000)),
    WATERMARK FOR `saleTimestamp_WM` AS `saleTimestamp_WM`
) WITH (
    'connector'                       = 'kafka',
    'topic'                           = 'avro_salesbaskets',
    'properties.bootstrap.servers'    = 'broker:29092',
    'properties.group.id'             = 'testGroup',
    'scan.startup.mode'               = 'earliest-offset',
    'value.format'                    = 'avro-confluent',
    'value.avro-confluent.schema-registry.url' = 'http://schema-registry:9081',
    'value.fields-include'            = 'ALL'
);

-- Create Paimon target table, stored on HDFS, data pulled from hive catalogged table

SET 'pipeline.name' = 'Sales Basket Injestion - Paimon Target';

CREATE TABLE c_paimon.dev.t_p_avro_salesbaskets_x WITH (
    'file.format' = 'parquet' 
  ) AS SELECT 
    `invoiceNumber`,
    `saleDateTime_Ltz`,
    `saleTimestamp_Epoc`,
    `terminalPoint`,
    `nett`,
    `vat`,
    `total`,
    `store`,
    `clerk`,
    `basketItems`,
    `saleTimestamp_WM`
  FROM c_hive.db01.t_k_avro_salesbaskets_x;

-- Now cancel the created insert, and replace with below.
-- INSERT INTO c_paimon.dev.t_p_avro_salesbaskets_x
--   SELECT 
--     `invoiceNumber`,
--     `saleDateTime_Ltz`,
--     `saleTimestamp_Epoc`,
--     `terminalPoint`,
--     `nett`,
--     `vat`,
--     `total`,
--     `store`,
--     `clerk`,
--     `basketItems`,
--     `saleTimestamp_WM`
--   FROM c_hive.db01.t_k_avro_salesbaskets_x;

-- Create a data Source, pulling data from Kafka topic, table definition recorded in our hive catalog

SET 'pipeline.name' = 'Sales Payments Injestion - Kafka Source';

CREATE OR REPLACE TABLE c_hive.db01.t_k_avro_salespayments_x (
    `invoiceNumber` STRING,
    `payDateTime_Ltz` STRING,
    `payTimestamp_Epoc` STRING,
    `paid` DOUBLE,
    `finTransactionId` STRING,
    `payTimestamp_WM` AS TO_TIMESTAMP(FROM_UNIXTIME(CAST(`payTimestamp_Epoc` AS BIGINT) / 1000)),
    WATERMARK FOR `payTimestamp_WM` AS `payTimestamp_WM`
) WITH (
    'connector'                     = 'kafka',
    'topic'                         = 'avro_salespayments',
    'properties.bootstrap.servers'  = 'broker:29092',
    'properties.group.id'           = 'testGroup',
    'scan.startup.mode'             = 'earliest-offset',
    'value.format'                  = 'avro-confluent',
    'value.avro-confluent.url'      = 'http://schema-registry:9081', 
    'value.avro-confluent.properties.use.latest.version' = 'true',
    'value.fields-include'          = 'ALL'
);

-- Create Paimon target table, stored on HDFS, data pulled from hive catalogged table

SET 'pipeline.name' = 'Sales Payments Injestion - Paimon Target';

CREATE TABLE c_paimon.dev.t_p_avro_salespayments_x WITH (
    'file.format' = 'parquet'
  ) AS SELECT 
    `invoiceNumber`,
    `payDateTime_Ltz`,
    `payTimestamp_Epoc`,
    `paid`,
    `finTransactionId`,
    `payTimestamp_WM`
  FROM c_hive.db01.t_k_avro_salespayments_x;


-- INSERT INTO c_paimon.dev.t_p_avro_salespayments_x
--   SELECT 
--     `invoiceNumber`,
--     `payDateTime_Ltz`,
--     `payTimestamp_Epoc`,
--     `paid`,
--     `finTransactionId`,
--     `payTimestamp_WM`
--   FROM c_hive.db01.t_k_avro_salespayments_x;

-- Create a data Source, pulling data from Kafka topic, table definition recorded in our hive catalog

SET 'pipeline.name' = 'Sales Completed Injestion - Kafka Target';

CREATE OR REPLACE TABLE c_hive.db01.t_f_avro_salescompleted_x (
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
    'connector'                     = 'kafka',
    'topic'                         = 'avro_salescompleted_x',
    'properties.bootstrap.servers'  = 'broker:29092',
    'properties.group.id'           = 'testGroup',
    'scan.startup.mode'             = 'earliest-offset',
    'value.format'                  = 'avro-confluent',
    'value.avro-confluent.schema-registry.url' = 'http://schema-registry:9081',
    'value.fields-include'          = 'ALL'
);

-- the fields in the select is case sensitive, needs to match the previous created tables which match the definitions in the struct/avro schema's.

-- populate hive catalogged table -> This is a flink table, that pushes data to Kafka

INSERT INTO c_hive.db01.t_f_avro_salescompleted_x
SELECT
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
        c_hive.db01.t_k_avro_salespayments_x a,
        c_hive.db01.t_k_avro_salesbaskets_x b
    WHERE a.invoiceNumber = b.invoiceNumber
    AND a.payTimestamp_WM > b.saleTimestamp_WM 
    AND b.saleTimestamp_WM > (b.saleTimestamp_WM - INTERVAL '1' HOUR);


-- Create Paimon target table, stored on HDFS, data pulled from hive catalogged table

SET 'pipeline.name' = 'Sales Completed Injestion - Paimon Target';

CREATE TABLE c_paimon.dev.t_p_avro_salescompleted_x WITH (
    'file.format' = 'parquet'
  ) AS SELECT 
    `invoiceNumber`,
    `saleDateTime_Ltz`,
    `saleTimestamp_Epoc`,
    `terminalPoint`,
    `nett`,
    `vat`,
    `total`,
    `store`,
    `clerk`,
    `basketItems`,     
    `payDateTime_Ltz`,
    `payTimestamp_Epoc`,
    `paid`,
    `finTransactionId`,
    `payTimestamp_WM`,
    `saleTimestamp_WM`
   FROM c_hive.db01.t_f_avro_salescompleted_x;

-- Now cancel the created insert, and replace with below.

-- INSERT INTO c_paimon.dev.t_p_avro_salescompleted_x
--   SELECT 
--     `invoiceNumber`,
--     `saleDateTime_Ltz`,
--     `saleTimestamp_Epoc`,
--     `terminalPoint`,
--     `nett`,
--     `vat`,
--     `total`,
--     `store`,
--     `clerk`,
--     `basketItems`,     
--     `payDateTime_Ltz`,
--     `payTimestamp_Epoc`,
--     `paid`,
--     `finTransactionId`,
--     `payTimestamp_WM`,
--     `saleTimestamp_WM`
--    FROM c_hive.db01.t_f_avro_salescompleted_x;

--- unest the salesBasket

SET 'pipeline.name' = 'Unnesting Sales Baskets - Kafka Target';

CREATE OR REPLACE TABLE c_hive.db01.t_f_unnested_sales (
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
    'connector'                     = 'kafka',
    'topic'                         = 'unnested_sales',
    'properties.bootstrap.servers'  = 'broker:29092',
    'properties.group.id'           = 'testGroup',
    'scan.startup.mode'             = 'earliest-offset',
    'value.format'                  = 'avro-confluent',
    'value.avro-confluent.url'      = 'http://schema-registry:9081',
    'value.fields-include'          = 'ALL'
);

-- populate hive catalogged table -> This is a flink table, that pushes data to Kafka

INSERT INTO c_hive.db01.t_f_unnested_sales
SELECT
      `store`.`id` as `store_id`,
      bi.`name` AS `product`,
      bi.`brand` AS `brand`,
      bi.`price` * bi.`quantity` AS `saleValue`,
      bi.`category` AS `category`,
      `saleDateTime_Ltz` as saleDateTime_Ltz,
      `saleTimestamp_Epoc` as saleTimestamp_Epoc
    FROM c_hive.db01.t_f_avro_salescompleted_x  -- assuming avro_salescompleted_x is a table function
    CROSS JOIN UNNEST(`basketItems`) AS bi;


-- Create Paimon target table, stored on HDFS, data pulled from hive catalogged table
-- CTAS does not support PARTITIONED BY (`store_id`) in statement yet... will need to manually/correct create table, partitioned and then
-- use a insert into statement. 

SET 'pipeline.name' = 'Unnesting Sales Baskets - Paimon Target';

CREATE TABLE c_paimon.dev.t_p_unnested_sales WITH (
    'file.format' = 'parquet',
    'bucket'      = '2',
    'bucket-key'  = 'store_id'
  ) AS SELECT 
      `store_id`,
      `product` ,
      `brand` ,
      `saleValue`,
      `category`,
      `saleDateTime_Ltz`,
      `saleTimestamp_Epoc`
  FROM c_hive.db01.t_f_unnested_sales;


-- Now cancel the created insert, and replace with below.

-- INSERT INTO c_paimon.dev.t_p_unnested_sales 
--   SELECT 
--       `store_id`,
--       `product` ,
--       `brand` ,
--       `saleValue`,
--       `category`,
--       `saleDateTime_Ltz`,
--       `saleTimestamp_Epoc`
--   FROM c_hive.db01.t_f_unnested_sales;


-- docker compose exec mc bash -c "mc ls -r minio/warehouse/"

-- Sales per store per brand per 5 min - output table

SET 'pipeline.name' = 'Sales Per Store Per Brand per X - Kafka Target';

CREATE OR REPLACE TABLE c_hive.db01.t_f_avro_sales_per_store_per_brand_per_5min_x (
  `store_id` STRING,
  `brand` STRING,
  window_start  TIMESTAMP(3),
  window_end TIMESTAMP(3),
  `salesperbrand` BIGINT,
  `totalperbrand` DOUBLE
) WITH (
    'connector'                     = 'kafka',
    'topic'                         = 'avro_sales_per_store_per_brand_per_5min_x',
    'properties.bootstrap.servers'  = 'broker:29092',
    'properties.group.id'           = 'testGroup',
    'scan.startup.mode'             = 'earliest-offset',
    'value.format'                  = 'avro-confluent',
    'value.avro-confluent.url'      = 'http://schema-registry:9081',
    'value.fields-include'          = 'ALL'
);

INSERT INTO c_hive.db01.t_f_avro_sales_per_store_per_brand_per_5min_x
SELECT 
    store_id,
    brand,
    window_start,
    window_end,
    COUNT(*) as `salesperbrand`,
    SUM(saleValue) as `totalperbrand`
  FROM TABLE(
    TUMBLE(TABLE c_hive.db01.t_f_unnested_sales, DESCRIPTOR(saleTimestamp_WM), INTERVAL '5' MINUTE))
  GROUP BY store_id, brand, window_start, window_end;


-- Sales per store per product per 5 min - output table

SET 'pipeline.name' = 'Sales Per Store Per Product per X - Kafka Target';

CREATE OR REPLACE TABLE c_hive.db01.t_f_avro_sales_per_store_per_product_per_5min_x (
  `store_id` STRING,
  `product` STRING,
  window_start  TIMESTAMP(3),
  window_end TIMESTAMP(3),
  `salesperproduct` BIGINT,
  `totalperproduct` DOUBLE
) WITH (
    'connector'                     = 'kafka',
    'topic'                         = 'avro_sales_per_store_per_product_per_5min_x',
    'properties.bootstrap.servers'  = 'broker:29092',
    'properties.group.id'           = 'testGroup',
    'scan.startup.mode'             = 'earliest-offset',
    'value.format'                  = 'avro-confluent',
    'value.avro-confluent.url'      = 'http://schema-registry:9081',
    'value.fields-include'          = 'ALL'
);

INSERT INTO c_hive.db01.t_f_avro_sales_per_store_per_product_per_5min_x
SELECT 
    store_id,
    product,
    window_start,
    window_end,
    COUNT(*) as `salesperproduct`,
    SUM(saleValue) as `totalperproduct`
  FROM TABLE(
    TUMBLE(TABLE c_hive.db01.t_f_unnested_sales, DESCRIPTOR(saleTimestamp_WM), INTERVAL '5' MINUTE))
  GROUP BY store_id, product, window_start, window_end;

-- Sales per store per category per 5 min - output table

SET 'pipeline.name' = 'Sales Per Store Per Category per X - Kafka Target';

CREATE OR REPLACE TABLE c_hive.db01.t_f_avro_sales_per_store_per_category_per_5min_x (
  `store_id` STRING,
  `category` STRING,
  window_start  TIMESTAMP(3),
  window_end TIMESTAMP(3),
  `salesperproduct` BIGINT,
  `totalperproduct` DOUBLE
) WITH (
    'connector'                     = 'kafka',
    'topic'                         = 'avro_sales_per_store_per_category_per_5min_x',
    'properties.bootstrap.servers'  = 'broker:29092',
    'properties.group.id'           = 'testGroup',
    'scan.startup.mode'             = 'earliest-offset',
    'value.format'                  = 'avro-confluent',
    'value.avro-confluent.url'      = 'http://schema-registry:9081',
    'value.fields-include'          = 'ALL'
);

INSERT INTO c_hive.db01.t_f_avro_sales_per_store_per_category_per_5min_x
SELECT 
    store_id,
    category,
    window_start,
    window_end,
    COUNT(*) as `salespercategory`,
    SUM(saleValue) as `totalpercategory`
  FROM TABLE(
    TUMBLE(TABLE c_hive.db01.t_f_unnested_sales, DESCRIPTOR(saleTimestamp_WM), INTERVAL '5' MINUTE))
  GROUP BY store_id, category, window_start, window_end;

-- Create sales per store per terminal per 5 min output table - dev purposes

SET 'pipeline.name' = 'Sales Per Store Per Terminal per X - Kafka Target';

CREATE OR REPLACE TABLE c_hive.db01.t_f_avro_sales_per_store_per_terminal_per_5min_x (
    `store_id` STRING,
    `terminalPoint` STRING,
    window_start  TIMESTAMP(3),
    window_end TIMESTAMP(3),
    `salesperterminal` BIGINT,
    `totalperterminal` DOUBLE
) WITH (
    'connector'                     = 'kafka',
    'topic'                         = 'avro_sales_per_store_per_terminal_per_5min_x',
    'properties.bootstrap.servers'  = 'broker:29092',
    'properties.group.id'           = 'testGroup',
    'scan.startup.mode'             = 'earliest-offset',
    'value.format'                  = 'avro-confluent',
    'value.avro-confluent.url'      = 'http://schema-registry:9081',
    'value.fields-include'          = 'ALL'
);

-- Calculate sales per store per terminal per 5 min - dev purposes
-- Aggregate query/worker

INSERT INTO c_hive.db01.t_f_avro_sales_per_store_per_terminal_per_5min_x
SELECT 
    `store`.`id` as `store_id`,
    terminalPoint,
    window_start,
    window_end,
    COUNT(*) as `salesperterminal`,
    SUM(total) as `totalperterminal`
  FROM TABLE(
    TUMBLE(TABLE c_hive.db01.t_f_avro_salescompleted_x, DESCRIPTOR(saleTimestamp_WM), INTERVAL '5' MINUTES))
  GROUP BY `store`.`id`, terminalPoint, window_start, window_end;


-- Create sales per store per terminal per hour output table

CREATE OR REPLACE TABLE c_hive.db01.t_f_avro_sales_per_store_per_terminal_per_hour_x (
    `store_id` STRING,
    `terminalPoint` STRING,
    window_start  TIMESTAMP(3),
    window_end TIMESTAMP(3),
    `salesperterminal` BIGINT,
    `totalperterminal` DOUBLE
) WITH (
    'connector'                     = 'kafka',
    'topic'                         = 'avro_sales_per_store_per_terminal_per_hour_x',
    'properties.bootstrap.servers'  = 'broker:29092',
    'properties.group.id'           = 'testGroup',
    'scan.startup.mode'             = 'earliest-offset',
    'value.format'                  = 'avro-confluent',
    'value.avro-confluent.url'      = 'http://schema-registry:9081',
    'value.fields-include'          = 'ALL'
);

-- Calculate sales per store per terminal per hour

INSERT INTO c_hive.db01.t_f_avro_sales_per_store_per_terminal_per_hour_x
SELECT 
    `store`.`id` as `store_id`,
    terminalPoint,
    window_start,
    window_end,
    COUNT(*) as `salesperterminal`,
    SUM(total) as `totalperterminal`
  FROM TABLE(
    TUMBLE(TABLE c_hive.db01.t_f_avro_salescompleted_x, DESCRIPTOR(saleTimestamp_WM), INTERVAL '1' HOUR))
  GROUP BY `store`.`id`, terminalPoint, window_start, window_end;