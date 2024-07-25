
-- https://www.decodable.co/blog/catalogs-in-flink-sql-hands-on
-- https://github.com/decodableco/examples/tree/main/catalogs/flink-iceberg-jdbc



CREATE CATALOG c_iceberg_hive WITH (
   'type'                  = 'iceberg',
   'io-impl'               = 'org.apache.iceberg.aws.s3.S3FileIO',
   'warehouse'             = 's3://warehouse',
   's3.endpoint'           = 'http://minio:9000',
   's3.path-style-access'  = 'true',
   'catalog-type'          = 'hive'
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
