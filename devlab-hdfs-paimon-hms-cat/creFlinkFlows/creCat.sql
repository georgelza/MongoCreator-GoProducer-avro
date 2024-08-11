
-- https://paimon.apache.org/docs/0.7/how-to/creating-catalogs/#creating-a-catalog-with-hive-metastore

CREATE CATALOG c_hive WITH (
  'type'          = 'hive',
  'hive-conf-dir' = '/opt/sql-client/conf'
);

USE CATALOG c_hive;

CREATE DATABASE c_hive.db01;

-- SHOW DATABASES;
-- USE c_hive.db01;
-- SHOW TABLES;

USE CATALOG default_catalog;

CREATE CATALOG c_paimon WITH (
    'type'                      = 'paimon',
    'metastore'                 = 'hive',
    'uri'                       = 'thrift://hms:9083',
    'hive-conf-dir'             = '/opt/sql-client/conf',
    'warehouse'                 = 'hdfs://namenode:9000/paimon/',
    'property-version'          = '1',
    'table-default.file.format' = 'parquet'
);

USE CATALOG c_paimon;

CREATE DATABASE c_paimon.dev;
--
-- When using hive catalog to change incompatible column types through alter table, you need to configure hive.metastore.disallow.incompatible.col.type.changes=false. see HIVE-17832.
-- If you are using Hive3, please disable Hive ACID:

-- hive.strict.managed.tables=false
-- hive.create.as.insert.only=false
-- metastore.create.as.acid=false