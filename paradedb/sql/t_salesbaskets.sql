
-- Parquet files directly
CREATE FOREIGN TABLE t_salesbaskets ()
SERVER parquet_server
OPTIONS (files 's3://iceberg/dev.db/t_salesbaskets/data/*.parquet');

drop foreign table t_salesbaskets;
--
-- or
-- Iceberg tables as it points to the metadata and data files.
CREATE FOREIGN TABLE t_salesbaskets ()
SERVER parquet_server
OPTIONS (files 's3://iceberg/dev.db/t_salesbaskets/*/*');

select count(*) from t_salesbaskets;

select 
	store->>'id' as store_id, 
	clerk->>'name' as clerk_name,
	clerk->>'surname' as clerk_surnname
from t_salesbaskets limit 5;

select  
	basketitems[1]->>'brand' as brand,
	basketitems[1]->>'name' as product,
	basketitems[1]->>'category' as category, 
	basketitems[1]->>'price' as price,
	basketitems[1]->>'quantity' as quantity,
	round(CAST(basketitems[1]->>'price' as numeric)*CAST (basketitems[1]->>'quantity' as integer),2) as subtotal
from t_salesbaskets limit 5;

CREATE FOREIGN TABLE t_salespayments ()
SERVER parquet_server
OPTIONS (
    files 's3://iceberg/dev.db/t_salespayments/*'
);

CREATE FOREIGN TABLE t_salescompleted ()
SERVER parquet_server
OPTIONS (
    files 's3://iceberg/dev.db/t_salescompleted/*'
);

CREATE FOREIGN TABLE t_unnested_sales ()
SERVER parquet_server
OPTIONS (
    files 's3://iceberg/dev.db/t_unnested_sales/*'
);


-- Yellow Taxi Datasets -> Parquet direct atm.
CREATE FOREIGN TABLE nyc_yellow_2023 ()
SERVER parquet_server
OPTIONS (files 's3://iceberg/nyc/yellow/2023/*.parquet');

CREATE FOREIGN TABLE nyc_yellow_2024 ()
SERVER parquet_server
OPTIONS (files 's3://iceberg/nyc/yellow/2024/*.parquet');

CREATE FOREIGN TABLE nyc_yellow ()
SERVER parquet_server
OPTIONS (files 's3://iceberg/nyc/yellow/*/*.parquet');

select count(*) from nyc_yellow_2023;
select count(*) from nyc_yellow_2024;
select count(*) from nyc_yellow;


-- Green taxi Datasets -> Parquet direct atm.
CREATE FOREIGN TABLE nyc_gree_2023 ()
SERVER parquet_server
OPTIONS (files 's3://iceberg/nyc/green/2023/*.parquet');

CREATE FOREIGN TABLE nyc_green_2024 ()
SERVER parquet_server
OPTIONS (files 's3://iceberg/nyc/green/2024/*.parquet');

CREATE FOREIGN TABLE nyc_green ()
SERVER parquet_server
OPTIONS (files 's3://iceberg/nyc/green/*/*.parquet');

select count(*) from nyc_green_2023;
select count(*) from nyc_ygreen_2024;
select count(*) from nyc_green;