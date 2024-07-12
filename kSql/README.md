# Some kSQL Notes

So I start with the 2 source topics, pb_salesbaskets and pb_salespayments. We use Protobuf as a serialization here due to speed... Ye Ye... I love JSON, but at 8000messages/second vs 500-600 who cna argue.

Once we have the Pb based topics we can alwys create short lived avro topics source from a acro stream that select from the originating Pb based topic. Now we have Avro, which everyone loves... and we work with Pb which is fast.

Another version I might try simply publishing via Avro serilization, skipping the Pb_* -> Stream -> avro_* step.

For the first how to... I used stream processing to create pb_salescompleted and avro_salescompleted which is a join between the pb_salesbaskets and pb_salespayments. Showing how we can build a completed basket.

This is then sinked to MongoDB using a sink connector.

I now use the avro_salescompleted to derive a sales per store per hour number into avro_sales_per_store_per_5min (this is just to see actvity during developement), avro_sales_per_store_per_hour. Note this stream is created to emit on final which means it only outputs at turn of hour... An option would be to output on change, which then become a source for a real time dashboard, especially if you going to sink to a prometheus TSDB and dashboard via say Grafana.