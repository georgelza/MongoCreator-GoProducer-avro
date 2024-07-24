


-- Working with time/dates and timestamps in ksqldb
-- https://www.confluent.io/blog/ksqldb-2-0-introduces-date-and-time-data-types/

-- create stream object from source topic, same format as source
-- salesbaskets - This becomes a input table for us
CREATE STREAM avro_salesbaskets (
	   	InvoiceNumber VARCHAR,
	 	SaleDateTime_Ltz VARCHAR,
	 	SaleTimestamp_Epoc VARCHAR,
	  	TerminalPoint VARCHAR,
	   	Nett DOUBLE,
	  	Vat DOUBLE,
	 	Total DOUBLE,
       	Store STRUCT<
       		Id VARCHAR,
     		Name VARCHAR>,
     	Clerk STRUCT<
     		Id VARCHAR,
          	Name VARCHAR,
          	Surname VARCHAR>,
    	BasketItems ARRAY< STRUCT<
			id VARCHAR,
        	Name VARCHAR,
          	Brand VARCHAR,
          	Category VARCHAR,
         	Price DOUBLE,
        	Quantity integer >>) 
WITH (KAFKA_TOPIC='avro_salesbaskets',
		    VALUE_FORMAT='Avro',
        	PARTITIONS=1);


-- salespayments - This becomes a input table for us
CREATE STREAM avro_salespayments (
	      	InvoiceNumber VARCHAR,
	      	FinTransactionId VARCHAR,
	      	PayDateTime_Ltz VARCHAR,
			PayTimestamp_Epoc VARCHAR,
	      	Paid DOUBLE      )
	WITH (
		KAFKA_TOPIC='avro_salespayments',
       	VALUE_FORMAT='Avro',
       	PARTITIONS=1);


-- salescompleted - This will be a output table for us.
CREATE STREAM avro_salescompleted WITH (
		KAFKA_TOPIC='avro_salescompleted',
       	VALUE_FORMAT='Avro',
       	PARTITIONS=1)
       	as  
		select 
			b.InvoiceNumber,
			as_value(p.InvoiceNumber) as InvNumber,			
			b.SaleDateTime_Ltz,
			b.SaleTimestamp_Epoc, 
			b.TerminalPoint,
			b.Nett,
			b.Vat,
			b.Total,
			b.store,
			b.clerk,
			b.BasketItems,
			p.PayDateTime_Ltz,
			p.PayTimestamp_Epoc,
			p.Paid,
			p.FinTransactionId
		from 
			avro_salespayments p INNER JOIN
			avro_salesbaskets b
		WITHIN 7 DAYS 
		on b.InvoiceNumber = p.InvoiceNumber
	emit changes;


------------------------------------------------------------------------------
-- Some aggregations calculated via kSQL
-- Sales per store 

CREATE TABLE avro_sales_per_store_per_5min WITH (
		KAFKA_TOPIC='avro_sales_per_store_per_5min',
       	VALUE_FORMAT='AVRO',
       	PARTITIONS=1)
       	as  
		SELECT  
			store->id as store_id,
			as_value(store->id) as storeid,
			from_unixtime(WINDOWSTART) as Window_Start,
			from_unixtime(WINDOWEND) as Window_End,
			count(1) as sales_per_store
		FROM avro_salescompleted
		WINDOW TUMBLING (SIZE 5 MINUTE)
		GROUP BY store->id 
	EMIT FINAL;

	
CREATE TABLE avro_sales_per_store_per_hour WITH (
		KAFKA_TOPIC='avro_sales_per_store_per_hour',
       	VALUE_FORMAT='AVRO',
       	PARTITIONS=1)
       	as  
		SELECT  
			store->id as store_id,
			as_value(store->id) as storeid,
			from_unixtime(WINDOWSTART) as Window_Start,
			from_unixtime(WINDOWEND) as Window_End,
			count(1) as sales_per_store
		FROM avro_salescompleted
		WINDOW TUMBLING (SIZE 1 HOUR)
		GROUP BY store->id 
	EMIT FINAL;