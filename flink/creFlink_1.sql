
-- Source topic is Avro serialized (Pb requires a PB Serdes be compiled into the Flink containers, it's not included default)
-- key is based the invnumber (as it was used t join salesbaskets and salespayments)
-- Flink UI : http://localhost:9081/#/overview

-- The below builds a table avro_salescompleted, backed/sourced from the Kafka topic 
-- as a kStream job/output.
CREATE TABLE avro_salescompleted (
    INVNUMBER STRING,
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
    WATERMARK FOR SALESTIMESTAMP_WM AS SALESTIMESTAMP_WM
) WITH (
    'connector' = 'kafka',
    'topic' = 'avro_salescompleted',
    'properties.bootstrap.servers' = 'broker:29092',
    'scan.startup.mode' = 'earliest-offset',
    'properties.group.id' = 'testGroup',
    'value.format' = 'avro-confluent',
    'value.avro-confluent.schema-registry.url' = 'http://schema-registry:8081',
    'value.fields-include' = 'ALL'
);

-- https://nightlies.apache.org/flink/flink-docs-master/docs/dev/table/sql/queries/window-agg/
-- We going to output the group by into this table, backed by topic which we will sink to MongoDB via connector
CREATE TABLE avro_sales_per_store_per_terminal_per_5min (
    store_id STRING,
    terminalpoint STRING,
    window_start  TIMESTAMP(3),
    window_end TIMESTAMP(3),
    salesperterminal BIGINT,
    totalperterminal DOUBLE,
    PRIMARY KEY (store_id, terminalpoint, window_start, window_end) NOT ENFORCED
) WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'avro_sales_per_store_per_terminal_per_5min',
    'properties.bootstrap.servers' = 'broker:29092',
    'key.format' = 'avro-confluent',
    'key.avro-confluent.url' = 'http://schema-registry:8081',
    'value.format' = 'avro-confluent',
    'value.avro-confluent.url' = 'http://schema-registry:8081',
    'value.fields-include' = 'ALL'
);


-- Aggregate query/worker
Insert into avro_sales_per_store_per_terminal_per_5min
SELECT 
    `STORE`.`ID` as STORE_ID,
    TERMINALPOINT,
    window_start,
    window_end,
    COUNT(*) as salesperterminal,
    SUM(TOTAL) as totalperterminal
  FROM TABLE(
    TUMBLE(TABLE avro_salescompleted, DESCRIPTOR(SALESTIMESTAMP_WM), INTERVAL '5' MINUTES))
  GROUP BY `STORE`.`ID`, TERMINALPOINT, window_start, window_end;

CREATE TABLE avro_sales_per_store_per_terminal_per_hour (
    store_id STRING,
    terminalpoint STRING,
    window_start  TIMESTAMP(3),
    window_end TIMESTAMP(3),
    salesperterminal BIGINT,
    totalperterminal DOUBLE,
    PRIMARY KEY (store_id, terminalpoint, window_start, window_end) NOT ENFORCED
) WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'avro_sales_per_store_per_terminal_per_hour',
    'properties.bootstrap.servers' = 'broker:29092',
    'key.format' = 'avro-confluent',
    'key.avro-confluent.url' = 'http://schema-registry:8081',
    'value.format' = 'avro-confluent',
    'value.avro-confluent.url' = 'http://schema-registry:8081',
    'value.fields-include' = 'ALL'
);


-- Aggregate query/worker
Insert into avro_sales_per_store_per_terminal_per_hour
SELECT 
    `STORE`.`ID` as STORE_ID,
    TERMINALPOINT,
    window_start,
    window_end,
    COUNT(*) as salesperterminal,
    SUM(TOTAL) as totalperterminal
  FROM TABLE(
    TUMBLE(TABLE avro_salescompleted, DESCRIPTOR(SALESTIMESTAMP_WM), INTERVAL '1' HOUR))
  GROUP BY `STORE`.`ID`, TERMINALPOINT, window_start, window_end;