
-- https://paimon.apache.org/docs/0.7/how-to/creating-catalogs/#creating-a-catalog-with-hive-metastore


CREATE CATALOG c_hive_paimon WITH (
    'type'                      = 'paimon',
    'metastore'                 = 'hive',
    'uri'                       = 'thrift://hms:9083',
    'hive-conf-dir'             = '/opt/sql-client/conf'
    'hadoop-conf-dir'           = '/etc/hadoop',
    'warehouse'                 = 'hdfs://namenode:9000/paimon/',
    'table-default.file.format' = 'parquet'
);

USE CATALOG c_hive_paimon; 


--
-- When using hive catalog to change incompatible column types through alter table, you need to configure hive.metastore.disallow.incompatible.col.type.changes=false. see HIVE-17832.
-- If you are using Hive3, please disable Hive ACID:

-- hive.strict.managed.tables=false
-- hive.create.as.insert.only=false
-- metastore.create.as.acid=false