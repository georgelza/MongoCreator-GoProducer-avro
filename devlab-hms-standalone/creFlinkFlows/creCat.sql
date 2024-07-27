
-- https://www.decodable.co/blog/catalogs-in-flink-sql-hands-on
-- https://github.com/decodableco/examples/tree/main/catalogs/flink-iceberg-jdbc


-- This willbe the commands used to create the catalog sitting behind flink
--

-- INTERESTING, things written to the c_hive catalog is only recorded as existing in the hive catalog, but not persisted to Minio/S3... The persistence in this case
-- comes from salescompleted writing out to Kafka. 

CREATE CATALOG c_hive WITH (
        'type' = 'hive',
        'hive-conf-dir' = './conf'
);

use catalog c_hive;

CREATE DATABASE c_hive.db01;

USE c_hive.db01;
SHOW TABLES;

CREATE CATALOG c_iceberg WITH (
       'type' = 'iceberg',
       'catalog-type'='hive',
       'warehouse' = 's3a://warehouse',
       'hive-conf-dir' = './conf'
);

use catalog c_iceberg;

CREATE DATABASE c_iceberg.dev;

USE c_iceberg.dev;
SHOW TABLES;






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