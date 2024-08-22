

CREATE FOREIGN TABLE t_salesbaskets ()
SERVER parquet_server
OPTIONS (files 's3://iceberg/dev.db/t_salesbaskets/data/*.parquet');

select count(*) from t_salesbaskets;


select store->>'id' from t_salesbaskets limit 5;

select basketitems[1]->>'quantity', 
	basketitems[1]->>'brand',
	basketitems[1]->>'name',
	basketitems[1]->>'price',
	basketitems[1]->>'category' 
	from t_salesbaskets limit 5;


-- Yellow Taxi Datasets

CREATE FOREIGN TABLE nyc_yellow_2023 ()
SERVER parquet_server
OPTIONS (files 's3://iceberg/nyc/yellow/2023/*.parquet');

select count(*) from nyc_yellow_2023;

CREATE FOREIGN TABLE nyc_yellow ()
SERVER parquet_server
OPTIONS (files 's3://iceberg/nyc/yellow/*/*.parquet');

select count(*) from nyc_yellow;