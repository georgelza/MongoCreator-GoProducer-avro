# Some Apache Flink Notes

So this follows the activities from the kSql section.

We use the same avro_salesbaskets and avro_salespayments source topics (this is because flink does not natively support Pb deserialization, you have to add the libraries to your containers). These 2 topics are then pulled into flink as 2 tables, avro serialized. 

We now create a table avro_salescompleted by joining the 2 source tables. 

Next up is a table to hold sales per store per terminal per hour ( and per 5 min for dev purposes).

This is then followed by a insert statement with a select / aggregatio and a window tumble.

This all is backed by a Kafka topic which can be sinked via a connect back into our back end data store, for this project this being MongoDB ATLAS.

We will run some further aggregations on MongoDB Atlas via their new stream processing engine to derive sales per product and per brand per hour and per day.

All Hive catalogged tables are either sourced from the source defined in the connector=xxx parameter or output to same, in my case it's kafka topics.

Apache Hive catalog allows for computed columns and flink watermark, this in itself is critical when working with the data in Apache Flink.

Below is first examples of what did not work... followed by what did, and my "understanding"

# First attempt, of many that failed.

Thinking was use a single catalog to store all table object definitions, and then define tables that we specifically want pushed down into our Minio based S3 object store.

Lets create our Iceberg based catalog.

CREATE CATALOG c_iceberg WITH (
        'type'          = 'iceberg',
        'catalog-type'  = 'hive',
        'warehouse'     = 's3a://iceberg',
        'hive-conf-dir' = './conf');

CREATE DATABASE `c_iceberg`.`dev`;
USE `c_iceberg`.`dev`;


The following failed, my understanding is as the table to be created inherites the definition of the source, the source in this case includes the watermark hidden column, which is not allowed in the iceberg table/datalake, and the saleTimestamp_WM column which is computed column, also not allowed as it is currently not a capability of iceberg datalake.

CREATE TABLE c_iceberg.dev.t_salesbaskets (
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
    'connector' = 'kafka',
    'topic' = 'avro_salesbaskets',
    'properties.bootstrap.servers' = 'broker:29092',
    'properties.group.id' = 'testGroup',
    'scan.startup.mode' = 'earliest-offset',
    'value.format' = 'avro-confluent',
    'value.avro-confluent.schema-registry.url' = 'http://schema-registry:9081',
    'value.fields-include' = 'ALL'
);

This fails immediate, with error saying "Cannot create table with computed columns"

## This also failed!

Second try, we create the source table, but this time we basically just want to persist the structure/definition into a Hive Metastore, as the data is already living in a Apache Kafka topic.

CREATE CATALOG c_hive WITH (
        'type' = 'hive',
        'hive-conf-dir' = './conf'
);

use catalog c_hive;

CREATE DATABASE c_hive.db01;

CREATE TABLE c_hive.db01.t_k_avro_salesbaskets (
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
    'connector' = 'kafka',
    'topic' = 'avro_salesbaskets',
    'properties.bootstrap.servers' = 'broker:29092',
    'properties.group.id' = 'testGroup',
    'scan.startup.mode' = 'earliest-offset',
    'value.format' = 'avro-confluent',
    'value.avro-confluent.schema-registry.url' = 'http://schema-registry:9081',
    'value.fields-include' = 'ALL'
);

Now we "Attempt" to create the output table, the table where we want to push data to, this time we create it inside a catalog based on ICEBERG, with Iceberg persistence provide via a S3 based object store hosted inside a MinIO container.

--> FAILED
CREATE TABLE c_iceberg.dev.t_salesbaskets WITH (
	  'connector'     = 'iceberg',
	  'catalog-type'  = 'hive',
	  'catalog-name'  = 'dev',
	  'warehouse'     = 's3a://iceberg',
	  'hive-conf-dir' = './conf')
  AS SELECT * FROM c_hive.db01.t_k_avro_salesbaskets;

--> AND FAILED
CREATE TABLE c_iceberg_hive.dev.t_salesbaskets WITH (
	  'connector'     = 'iceberg',
	  'catalog-type'  = 'hive',
	  'catalog-name'  = 'dev',
	  'warehouse'     = 's3a://warehouse',
	  'hive-conf-dir' = './conf')
  LIKE c_hive.db01.t_k_avro_salesbaskets;

INSERT INTO c_iceberg_hive.dev.t_salesbaskets
SELECT * FROM c_hive.db01.t_k_avro_salesbaskets;

Both times complained about the same errors as previous, computed column not allowed currently.

## Another try, lets try and get rid of the computed column.

I even tried to create a table with the saleTimestamp_WM defined as a TIMESTAMP(3), then inserted records into it.

CREATE TABLE c_hive.db01.t_k_avro_salesbaskets (
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
    `saleTimestamp_WM` TIMESTAMP(3),
    WATERMARK FOR `saleTimestamp_WM` AS `saleTimestamp_WM`
) WITH (
    'connector' = 'kafka',
    'topic' = 'avro_salesbaskets',
    'properties.bootstrap.servers' = 'broker:29092',
    'properties.group.id' = 'testGroup',
    'scan.startup.mode' = 'earliest-offset',
    'value.format' = 'avro-confluent',
    'value.avro-confluent.schema-registry.url' = 'http://schema-registry:9081',
    'value.fields-include' = 'ALL'
);

The above worked as the definition went into a Hive catalog.

Then tried:

INSERT INTO c_hive.db01.t_k_avro_salesbaskets
SELECT * FROM c_hive.db01.t_k_avro_salesbaskets;

As the watermark column is hidden this works, but, there is a snag... See below.

CREATE TABLE c_iceberg.dev.t_salesbaskets AS
  SELECT * FROM c_hive.db01.t_k_avro_salesbaskets;


--> Failed, My thinking here is, even though we selecting from a hive catalogged table, the source table still contained a watermark column, and well Iceberg does not support watermark's, and well it made it clear iceberg does not support watermark columns, so there was that ;)


# Now onto what Worked

The following is what worked. Like above, we create a reference for the source table, we know we can do the source inside a Hive based catalog, as this does not create a persisted object, it simply references it.

CREATE CATALOG c_hive WITH (
        'type' = 'hive',
        'hive-conf-dir' = './conf'
);

USE CATALOG c_hive;

CREATE DATABASE c_hive.db01;

CREATE TABLE c_hive.db01.t_k_avro_salesbaskets (
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
    'connector' = 'kafka',
    'topic' = 'avro_salesbaskets',
    'properties.bootstrap.servers' = 'broker:29092',
    'properties.group.id' = 'testGroup',
    'scan.startup.mode' = 'earliest-offset',
    'value.format' = 'avro-confluent',
    'value.avro-confluent.schema-registry.url' = 'http://schema-registry:9081',
    'value.fields-include' = 'ALL'
);

Now we create our Iceberg based catalog.

CREATE CATALOG c_iceberg WITH (
       'type' = 'iceberg',
       'catalog-type'='hive',
       'warehouse' = 's3a://iceberg',
       'hive-conf-dir' = './conf'
);

USE CATALOG c_iceberg;

CREATE DATABASE c_iceberg.dev;

Followed by a CTAS statement, notice we exclude the watermark column, as this is not allowed in the iceberg table and by referencing the fields, we actually pull their value/data and not their definitions.

CREATE TABLE c_iceberg.dev.t_salesbaskets AS
  SELECT 
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
  FROM c_hive.db01.t_k_avro_salesbaskets;

  As we're creating this inside the c_iceberg.dev catalog.database by fully qualifying the location, it inherits the storage location from the catalog, which says Iceberg based table, Definitions into Hive, data onto MinIO.

  As much as this section is for the Hive Metastore Stand Alone with internal DerbyDB, the steps and results were replicated into the Hive Metastore Standalone with the PostgreSql data store. See the devlab-hms-postgres environment.