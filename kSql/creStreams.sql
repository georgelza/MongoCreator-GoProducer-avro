


-- Working with time/dates and timestamps in ksqldb
-- https://www.confluent.io/blog/ksqldb-2-0-introduces-date-and-time-data-types/

-- create stream object from source topic, same format as source
-- salesbaskets
CREATE STREAM pb_salesbaskets (
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
          	Name VARCHAR>,
    	BasketItems ARRAY< STRUCT<
			id VARCHAR,
        	Name VARCHAR,
          	Brand VARCHAR,
          	Category VARCHAR,
         	Price DOUBLE,
        	Quantity integer >>) 
WITH (KAFKA_TOPIC='pb_salesbaskets',
		    VALUE_FORMAT='ProtoBuf',
        	PARTITIONS=1);


-- salespayments       
CREATE STREAM pb_salespayments (
	      	InvoiceNumber VARCHAR,
	      	FinTransactionId VARCHAR,
	      	PayDateTime_Ltz VARCHAR,
			PayTimestamp_Epoc VARCHAR,
	      	Paid DOUBLE      )
	WITH (
		KAFKA_TOPIC='pb_salespayments',
       	VALUE_FORMAT='ProtoBuf',
       	PARTITIONS=1);


-- salescompleted
CREATE STREAM pb_salescompleted WITH (
		KAFKA_TOPIC='pb_salescompleted',
       	VALUE_FORMAT='ProtoBuf',
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
			p.FinTransactionId,
			p.PayDateTime_Ltz,
			p.PayTimestamp_Epoc,
			p.Paid
		from 
			pb_salespayments p INNER JOIN
			pb_salesbaskets b
		WITHIN 7 DAYS 
		on b.InvoiceNumber = p.InvoiceNumber
	emit changes;


-- Create 2 Avro based topics from our PB posted, to simplify the entire consumption side on Flink... it does not like
-- native include Pb deserializer
CREATE STREAM avro_salesbaskets WITH (
		KAFKA_TOPIC='avro_salesbaskets',
       	VALUE_FORMAT='Avro',
       	PARTITIONS=1)
       	as  
		select 
			InvoiceNumber, 
			SaleDateTime_Ltz,
			SaleTimestamp_Epoc,
			CAST(SaleTimestamp_Epoc AS BIGINT) AS Sales_epoc_bigint,
			TerminalPoint,
			Nett,
			Vat,
			Total,
			store,
			clerk,
			BasketItems
		from 
			pb_salesbaskets
	emit changes;


CREATE STREAM avro_salespayments WITH (
		KAFKA_TOPIC='avro_salespayments',
       	VALUE_FORMAT='Avro',
       	PARTITIONS=1)
       	as  
		select   	
			InvoiceNumber,
	      	FinTransactionId,
	      	PayDateTime_Ltz,
			PayTimestamp_Epoc,
		  	CAST(PayTimestamp_Epoc AS BIGINT) AS Pay_epoc_bigint,
	      	Paid  
		from pb_salespayments
	emit changes;


-- Build directly from avro_salespayments and avro_salesbaskets
CREATE STREAM avro_salescompleted WITH (
		KAFKA_TOPIC='avro_salescompleted',
       	VALUE_FORMAT='avro',
       	PARTITIONS=1)
       	as  
		select 
			p.InvoiceNumber,
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
			p.FinTransactionId,
			p.PayDateTime_Ltz,
			p.PayTimestamp_Epoc,
			p.Paid  
		from 
			pb_salespayments p INNER JOIN
			pb_salesbaskets b
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
		FROM pb_salescompleted
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
		FROM pb_salescompleted
		WINDOW TUMBLING (SIZE 1 HOUR)
		GROUP BY store->id 
	EMIT FINAL;


-- WE GONNA DO (accomplish) THE BELOW IN FLINK...
-- showing the diffferent, more scalable solution, once the values are aggregated back into a topic we will use
-- Connect config to sink to back end data store.
--
-- NOT to be executed, we going to do this via FLINK
-- limited to one store for POC, output in AVRO format, ye ye it took some time but finding why working
-- with avro serialized data is easier on the CP and Flink cluster.
CREATE TABLE avro_sales_per_store_per_terminal_point_per_5min WITH (
		KAFKA_TOPIC='avro_sales_per_store_per_terminal_point_per_5min',
       	FORMAT='AVRO',
       	PARTITIONS=1)
       	as  
		SELECT 
			store->id as store_id,
			TerminalPoint as terminal_point,
			count(1) as sales_per_terminal
		FROM pb_salescompleted
		WINDOW TUMBLING (SIZE 5 MINUTE)
		WHERE store->Id = '324213441'
		GROUP BY store->id , TerminalPoint	
	EMIT FINAL;

--
-- NOT to be executed, we going to do this via FLINK
CREATE TABLE avro_sales_per_store_per_terminal_point_per_hour WITH (
		KAFKA_TOPIC='avro_sales_per_store_per_terminal_point_per_hour',
       	FORMAT='AVRO',
       	PARTITIONS=1)
       	as  
		SELECT 
			store->id as store_id,
			TerminalPoint as terminal_point,
			count(1) as sales_per_terminal
		FROM pb_salescompleted
		WINDOW TUMBLING (SIZE 1 HOUR)
		GROUP BY store->id , TerminalPoint	
	EMIT FINAL;

------------------------------------------------------------------------------



-- OLD / IGNORE from here onwards
-- this updates the totals incrementally as it grows, the above emit final only shows/updates at the close of the windows
select 
  store_id, 
  terminal_point,
  from_unixtime(WINDOWSTART) as Window_Start,
  from_unixtime(WINDOWEND) as Window_End,
  SALES_PER_TERMINAL
from AVRO_SALES_PER_TERMINAL_POINT EMIT CHANGES;

-- change SaleTimsestam to BIGINT
CREATE STREAM pb_salesbaskets1 WITH (
		KAFKA_TOPIC='pb_salesbaskets1',
       	VALUE_FORMAT='ProtoBuf',
       	PARTITIONS=1)
       	as  
		select
			InvoiceNumber,
	 		SaleDateTime_Ltz,
		  	CAST(SaleTimestamp_Epoc AS BIGINT) AS Sale_epoc_bigint,
	  		TerminalPoint,
	   		Nett,
	  		Vat,
	 		Total,
       		Store,
     		Clerk,
    		BasketItems 
		from pb_salesbaskets
			emit changes;

-- change SaleTimsestam to TIMESTAMPTOSTRING, with a format
CREATE STREAM pb_salesbaskets2 WITH (
		KAFKA_TOPIC='pb_salesbaskets2',
       	VALUE_FORMAT='ProtoBuf',
       	PARTITIONS=1)
       	as  
		select
			InvoiceNumber,
	 		SaleDateTime_Ltz,
			TIMESTAMPTOSTRING(CAST(SaleTimestamp_Epoc AS BIGINT), 'yyyy-MM-dd''T''HH:mm:ss.SSS') AS SaleTimestamp_str,
	  		TerminalPoint,
	   		Nett,
	  		Vat,
	 		Total,
       		Store,
     		Clerk,
    		BasketItems 
		from pb_salesbaskets
			emit changes;


CREATE STREAM pb_salespayments1 WITH (
		KAFKA_TOPIC='pb_salespayments1',
       	VALUE_FORMAT='ProtoBuf',
       	PARTITIONS=1)
       	as  
		select   	
			InvoiceNumber,
	      	FinTransactionId,
	      	PayDateTime_Ltz,
		  	CAST(PayTimestamp_Epoc AS BIGINT) AS Pay_epoc_bigint,
	      	Paid  
		from pb_salespayments
	emit changes;


CREATE STREAM pb_salespayments2 WITH (
		KAFKA_TOPIC='pb_salespayments2',
       	VALUE_FORMAT='ProtoBuf',
       	PARTITIONS=1)
       	as  
		select   	
			InvoiceNumber,
	      	FinTransactionId,
	      	PayDateTime_Ltz,
		  	TIMESTAMPTOSTRING(CAST(PayTimestamp_Epoc AS BIGINT), 'yyyy-MM-dd''T''HH:mm:ss.SSS') AS PayTimestamp_str,
	      	Paid  
		from pb_salespayments
	emit changes;

-- SALETIMESTAMP is a string representing epoc based date/time, we need to convert to BIGINT
SELECT INVOICENUMBER, 
	TIMESTAMPTOSTRING(CAST(SaleTimestamp_Epoc AS BIGINT), 'YYYY-MM-dd HH:mm:ss.SSS') AS SALETIMESTAMP_str,
	STORE->Name,
	STORE->ID,
	CLERK->Name,
	CLERK->ID
FROM pb_salesbaskets;