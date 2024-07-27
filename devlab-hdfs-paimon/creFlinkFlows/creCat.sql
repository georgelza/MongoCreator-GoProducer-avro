
-- https://www.decodable.co/blog/catalogs-in-flink-sql-hands-on
-- https://github.com/decodableco/examples/tree/main/catalogs/flink-iceberg-jdbc


-- This willbe the commands used to create the catalog sitting behind flink
--

CREATE CATALOG c_hive WITH (
    'type' = 'hive'
  );


CREATE CATALOG c_iceberg_hive WITH (
   'type'                     = 'hive', 
   'io-impl'                  = 'org.apache.iceberg.aws.s3.S3FileIO',
   'warehouse'                = 's3://warehouse', 
   's3.endpoint'              = 'http://minio:9000',
   's3.path-style-access'     = 'true',
   'catalog-type'             = 'hive'
);


CREATE DATABASE `c_iceberg_hive`.`db01`;

USE `c_iceberg_hive`.`db01`;

-- Example/test

CREATE TABLE t_foo (c1 varchar, c2 int);

INSERT INTO t_foo VALUES ('a',42);

-- Go see minio:9001/browser

SET 'execution.runtime-mode' = 'batch';
SET 'sql-client.execution.result-mode' = 'tableau';

-- Wait a few moments; running this straightaway often doesn't show
-- the results

SELECT * FROM t_foo;


---------------------------------------------------------------------------------------------------------

CREATE CATALOG c_hive WITH (
   'type'               = 'hive',
   'hive-conf-dir'      = './conf'
);

CREATE CATALOG c_iceberg_hive WITH (
   'type'               = 'iceberg',
   'hive-conf-dir'      = './conf'
);


CREATE CATALOG c_iceberg_hive WITH (
   'type'                  = 'iceberg',
   'io-impl'               = 'org.apache.iceberg.aws.s3.S3FileIO',
   'warehouse'             = 's3://warehouse',
   's3.endpoint'           = 'http://minio:9000',
   's3.path-style-access'  = 'true',
   'catalog-type'          = 'hive'
);

-- if executed in sql-client container
CREATE CATALOG c_iceberg_hive WITH (
   'type'                  = 'iceberg',
   's3.endpoint'           = 'http://minio:9000',
   's3.path-style-access'  = 'true',
   'catalog-type'          = 'hive'
);


CREATE TABLE iceberg_test WITH (
    'connector'            = 'iceberg',
    'catalog-type'         = 'hive',
    'catalog-name'         = 'c_iceberg_hive',
    'warehouse'            = 's3a://warehouse',
    'hive-conf-dir'        = '/opt/sql-client/conf',
    'write.format.default' = 'parquet'
);

CREATE TABLE iceberg_test WITH (
    'connector'            = 'iceberg',
    'catalog-type'         = 'hive',
    'catalog-name'         = 'dev',
    'warehouse'            = 's3a://warehouse',
    'hive-conf-dir'        = './conf',
    'write.format.default' = 'orc'
);

CREATE CATALOG c_iceberg_jdbc WITH (
   'type'                  = 'iceberg',
   'io-impl'               = 'org.apache.iceberg.aws.s3.S3FileIO',
   'warehouse'             = 's3://warehouse',
   's3.endpoint'           = 'http://minio:9000',
   's3.path-style-access'  = 'true',
   'catalog-type'          = 'hive'
);

CREATE DATABASE `c_iceberg_hive`.`db01`;




--  Base Hive images, 
-- https://hub.docker.com/r/apache/hive
--docker run -d -p 9083:9083 --env SERVICE_NAME=hive-metastore --env DB_DRIVER=postgres \
   --env SERVICE_OPTS="-Djavax.jdo.option.ConnectionDriverName=org.postgresql.Driver -Djavax.jdo.option.ConnectionURL=jdbc:postgresql://postgres:5432/hive_metastore -Djavax.jdo.option.ConnectionUserName=hive -Djavax.jdo.option.ConnectionPassword=hive" \
   --mount source=data/hive,target=/opt/hive/data/warehouse \
   --name hive-metastore --network devlab  apache/hive:3.0.0

-- This gives us persistence.
--docker run -d -p 10000:10000 -p 10002:10002 --env SERVICE_NAME=hiveserver2 \
   --env SERVICE_OPTS="-Dhive.metastore.uris=thrift://hive-metastore:9083" \
   --mount source=data/hive,target=/opt/hive/data/warehouse \
   --env IS_RESUME="true" \
   --name hiveserver2 --network devlab apache/hive:3.0.0