
-- https://paimon.apache.org/docs/0.7/how-to/creating-catalogs/#creating-a-catalog-with-filesystem-metastore

CREATE CATALOG my_catalog WITH (
    'type' = 'paimon',
    'warehouse' = 'hdfs:///path/to/warehouse'
);
-- With above the table storage type is defined at CTAS time
OR

CREATE CATALOG hdfs_paimon WITH (
  'type'='paimon',
  'catalog-type'='hadoop',     
  'warehouse'='hdfs://namenode:9000/warehouse/',
  'property-version'='1'
);
-- With above we just create table on storage, table inherites type from catalog definition

USE CATALOG hdfs_paimon;

-- Create Database db01

-- Create database dev

