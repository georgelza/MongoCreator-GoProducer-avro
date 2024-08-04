
-- https://paimon.apache.org/docs/0.7/how-to/creating-catalogs/#creating-a-catalog-with-hive-metastore

CREATE CATALOG hive_paimon WITH (
    'type'                  = 'paimon',
    'metastore'             = 'hive',
    -- 'uri'                = 'thrift://hms:9083', default use 'hive.metastore.uris' in HiveConf
    -- 'hive-conf-dir'      = '...', this is recommended in the kerberos environment
    -- 'hadoop-conf-dir'    = '...', this is recommended in the kerberos environment
    -- 'warehouse'          = 'hdfs:///paimon/hdfs', default use 'hive.metastore.warehouse.dir' in HiveConf
);

USE CATALOG hive_paimon; 