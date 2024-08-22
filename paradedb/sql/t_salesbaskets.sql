
-- Parquet files directly
CREATE FOREIGN TABLE t_salesbaskets ()
SERVER parquet_server
OPTIONS (files 's3://iceberg/dev.db/t_salesbaskets/data/*.parquet');

--
-- or
-- Iceberg tables as it points to the metadata and data files.
CREATE FOREIGN TABLE t_salesbaskets ()
SERVER parquet_server
OPTIONS (
    files 's3://iceberg/dev.db/t_salesbaskets/*'
);

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




-- Yellow Taxi Datasets

CREATE FOREIGN TABLE nyc_yellow_2023 ()
SERVER parquet_server
OPTIONS (files 's3://iceberg/nyc/yellow/2023/*.parquet');

select count(*) from nyc_yellow_2023;

CREATE FOREIGN TABLE nyc_yellow ()
SERVER parquet_server
OPTIONS (files 's3://iceberg/nyc/yellow/*/*.parquet');

select count(*) from nyc_yellow;