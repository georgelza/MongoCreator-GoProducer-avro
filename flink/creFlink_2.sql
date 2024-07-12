
-- Source topic is Avro serialized (Pb requires a PB Serdes be compiled into the Flink containers, it's not included default)
-- key is based the invnumber (as it was used t join salesbaskets and salespayments)
-- Flink UI : http://localhost:9081/#/overview

-- The below builds avro_salescompleted locally (on Apache Flink environment) as a output of a join, the results are inserted into avro_salescompleted.
-- After this we then do the per store per terminal per hour aggregation/calculations.
-- this is done here this way to "lighten" the load/dependency on Kafka stream processing, and well, as another method/arrow in quiver.

-- pull (INPUT) the avro_salesbaskets topic into Flink
CREATE TABLE avro_salesbaskets_x (
    INVOICENUMBER STRING,
    SALEDATETIME_LTZ STRING,
    SALETIMESTAMP_EPOC STRING,
    TERMINALPOINT STRING,
    NETT DOUBLE,
    VAT DOUBLE,
    TOTAL DOUBLE,
    STORE row<ID STRING, NAME STRING>,
    CLERK row<ID STRING, NAME STRING>,
    BASKETITEMS array<row<ID STRING, NAME STRING, BRAND STRING, CATEGORY STRING, PRICE DOUBLE, QUANTITY INT>>,
    SALESTIMESTAMP_WM AS TO_TIMESTAMP(FROM_UNIXTIME(CAST(SALETIMESTAMP_EPOC AS BIGINT) / 1000)),
    WATERMARK FOR SALESTIMESTAMP_WM AS SALESTIMESTAMP_WM
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

-- pull (INPUT) the avro_salespayments topic into Flink
CREATE TABLE avro_salespayments_x (
    INVOICENUMBER STRING,
    FINTRANSACTIONID STRING,
    PAYDATETIME_LTZ STRING,
    PAYTIMESTAMP_EPOC STRING,
    PAID DOUBLE,
    PAYTIMESTAMP_WM AS TO_TIMESTAMP(FROM_UNIXTIME(CAST(PAYTIMESTAMP_EPOC AS BIGINT) / 1000)),
    WATERMARK FOR PAYTIMESTAMP_WM AS PAYTIMESTAMP_WM
) WITH (
    'connector' = 'kafka',
    'topic' = 'avro_salespayments',
    'properties.bootstrap.servers' = 'broker:29092',
    'properties.group.id' = 'testGroup',
    'scan.startup.mode' = 'earliest-offset',
    'value.format' = 'avro-confluent',
    'value.avro-confluent.url' = 'http://schema-registry:8081',
    'value.fields-include' = 'ALL'
);

-- Our avro_salescompleted (OUTPUT) table which will push values to the CP Kafka topic.
-- https://nightlies.apache.org/flink/flink-docs-release-1.13/docs/connectors/table/formats/avro-confluent/
CREATE TABLE avro_salescompleted_x (
    INVOICENUMBER STRING,
    SALEDATETIME_LTZ STRING,
    SALETIMESTAMP_EPOC STRING,
    TERMINALPOINT STRING,
    NETT DOUBLE,
    VAT DOUBLE,
    TOTAL DOUBLE,
    STORE row<ID STRING, NAME STRING>,
    CLERK row<ID STRING, NAME STRING>,
    BASKETITEMS array<row<ID STRING, NAME STRING, BRAND STRING, CATEGORY STRING, PRICE DOUBLE, QUANTITY INT>>,
    FINTRANSACTIONID STRING,
    PAYDATETIME_LTZ STRING,
    PAYTIMESTAMP_EPOC STRING,
    PAID DOUBLE,
    SALESTIMESTAMP_WM AS TO_TIMESTAMP(FROM_UNIXTIME(CAST(SALETIMESTAMP_EPOC AS BIGINT) / 1000)),
    PAYTIMESTAMP_WM AS TO_TIMESTAMP(FROM_UNIXTIME(CAST(PAYTIMESTAMP_EPOC AS BIGINT) / 1000)),
    WATERMARK FOR SALESTIMESTAMP_WM AS SALESTIMESTAMP_WM
) WITH (
    'connector' = 'kafka',
    'topic' = 'avro_salescompleted_x',
    'properties.bootstrap.servers' = 'broker:29092',
    'properties.group.id' = 'testGroup',
    'scan.startup.mode' = 'earliest-offset',
    'value.format' = 'avro-confluent',
    'value.avro-confluent.url' = 'http://schema-registry:8081',
    'value.fields-include' = 'ALL'
);

-- Improve further by using *_WM values that was pre casted to date/time fields n the 2 source tables.
Insert into avro_salescompleted_x
    SELECT 
        b.INVOICENUMBER,
        b.SALEDATETIME_LTZ,
        b.SALETIMESTAMP_EPOC,
        b.TERMINALPOINT,
        b.NETT,
        b.VAT,
        b.TOTAL,
        b.STORE,
        b.CLERK,    
        b.BASKETITEMS,        
        a.FINTRANSACTIONID,
        a.PAYDATETIME_LTZ,
        a.PAYTIMESTAMP_EPOC,
        a.PAID
    FROM 
        avro_salespayments_x a,
        avro_salesbaskets_x b
    WHERE a.INVOICENUMBER = b.INVOICENUMBER
    AND PAYTIMESTAMP_WM > SALESTIMESTAMP_WM 
    AND SALESTIMESTAMP_WM > (SALESTIMESTAMP_WM - INTERVAL '1' HOUR);


-- Create sales per store per terminal per 5 min output table - dev purposes
CREATE TABLE avro_sales_per_store_per_terminal_per_5min_x (
    store_id STRING,
    terminalpoint STRING,
    window_start  TIMESTAMP(3),
    window_end TIMESTAMP(3),
    salesperterminal BIGINT,
    totalperterminal DOUBLE
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
    `STORE`.`ID` as STORE_ID,
    TERMINALPOINT,
    window_start,
    window_end,
    COUNT(*) as salesperterminal,
    SUM(TOTAL) as totalperterminal
  FROM TABLE(
    TUMBLE(TABLE avro_salescompleted_x, DESCRIPTOR(SALESTIMESTAMP_WM), INTERVAL '5' MINUTES))
  GROUP BY `STORE`.`ID`, TERMINALPOINT, window_start, window_end;


-- Create sales per store per terminal per hour output table
CREATE TABLE avro_sales_per_store_per_terminal_per_hour_x (
    store_id STRING,
    terminalpoint STRING,
    window_start  TIMESTAMP(3),
    window_end TIMESTAMP(3),
    salesperterminal BIGINT,
    totalperterminal DOUBLE
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
    `STORE`.`ID` as STORE_ID,
    TERMINALPOINT,
    window_start,
    window_end,
    COUNT(*) as salesperterminal,
    SUM(TOTAL) as totalperterminal
  FROM TABLE(
    TUMBLE(TABLE avro_salescompleted_x, DESCRIPTOR(SALESTIMESTAMP_WM), INTERVAL '1' HOUR))
  GROUP BY `STORE`.`ID`, TERMINALPOINT, window_start, window_end;


  -- Calculate sales per store per product
SELECT 
    `STORE`.`ID` as STORE_ID,
    `BASKETITEMS`.`NAME` as PRODUCT,
    window_start,
    window_end,
    SUM(`BASKETITEMS`.`QUANTITY`) as SALESPERPRODUCT,
    SUM(`BASKETITEMS`.`PRICE`) as TOTALPERPRODUCT
  FROM TABLE(
    TUMBLE(TABLE avro_salescompleted_x, DESCRIPTOR(SALESTIMESTAMP_WM), INTERVAL '5' MINUTES))
  GROUP BY `STORE`.`ID`, `BASKETITEMS`.`NAME`, window_start, window_end;

  -- Calculate sales per store per brand
SELECT 
    `STORE`.`ID` as STORE_ID,
    `BASKETITEMS`.`BRAND` as BRAND,
    window_start,
    window_end,
    SUM(`BASKETITEMS`.`QUANTITY`) as SALESPERBRAND,
    SUM(`BASKETITEMS`.`PRICE`) as TOTALPERBRAND
  FROM TABLE(
    TUMBLE(TABLE avro_salescompleted_x, DESCRIPTOR(SALESTIMESTAMP_WM), INTERVAL '5' MINUTES))
  GROUP BY `STORE`.`ID`, `BASKETITEMS`.`BRAND`, window_start, window_end;

  -- Calculate sales per store per category
SELECT 
    `STORE`.`ID` as STORE_ID,
    `BASKETITEMS`.`CATEGORY` as CATEGORY,
    window_start,
    window_end,
    SUM(`BASKETITEMS`.`QUANTITY`) as SALESPERCATEGORY,
    SUM(`BASKETITEMS`.`PRICE`) as TOTALPERCATEGORY
  FROM TABLE(
    TUMBLE(TABLE avro_salescompleted_x, DESCRIPTOR(SALESTIMESTAMP_WM), INTERVAL '5' MINUTES))
  GROUP BY `STORE`.`ID`, `BASKETITEMS`.`CATEGORY`, window_start, window_end;

