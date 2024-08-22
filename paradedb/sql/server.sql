CREATE FOREIGN DATA WRAPPER parquet_wrapper
HANDLER parquet_fdw_handler VALIDATOR parquet_fdw_validator;

CREATE SERVER parquet_server FOREIGN DATA WRAPPER parquet_wrapper;

CREATE USER MAPPING FOR pdbadmin
SERVER parquet_server
OPTIONS (
  type 'S3',
  key_id 'safzyj-paxGoc-4nitdu',
  secret 'safzyj-paxGoc-n3itdu',
  region 'za-south-1',
  endpoint '172.16.10.24:9000',
  url_style 'path',
  use_ssl 'false'
);


