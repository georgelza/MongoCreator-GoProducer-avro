
-- https://paimon.apache.org/docs/0.7/how-to/creating-catalogs/#creating-a-catalog-with-filesystem-metastore

CREATE CATALOG fs_paimon WITH (
    'type'      = 'paimon',
    'warehouse' = 'hdfs:///paimon/fs'
);

USE CATALOG fs_paimon;

   