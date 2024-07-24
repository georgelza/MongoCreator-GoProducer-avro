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

-- SALETIMESTAMP is a string representing epoc based date/time, we need to convert to BIGINT
SELECT INVOICENUMBER, 
	TIMESTAMPTOSTRING(CAST(SaleTimestamp_Epoc AS BIGINT), 'YYYY-MM-dd HH:mm:ss.SSS') AS SALETIMESTAMP_str,
	STORE->Name,
	STORE->ID,
	CLERK->Name,
	CLERK->ID
FROM pb_salesbaskets;


-- change SaleTimsestamp to BIGINT
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