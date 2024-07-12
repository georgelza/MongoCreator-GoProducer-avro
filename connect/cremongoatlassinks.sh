#!/bin/bash

#------------------------------------------------------------------------------
#-- Post/Sink to Atlas

. ./.pwdmongoatlas

# above file contains:
#
# ATLAS
# export MONGO_URL=mongodb+srv://username:password@cluster_url


curl -X POST \
  -H "Content-Type: application/json" \
  --data '
     { "name": "mongo-atlas-salesbaskets-sink-pb",
        "config": {
          "connector.class": "com.mongodb.kafka.connect.MongoSinkConnector",
          "connection.uri": "'${MONGO_URL}'",
          "key.converter": "org.apache.kafka.connect.storage.StringConverter",
          "value.converter":"io.confluent.connect.protobuf.ProtobufConverter",
          "value.converter.schema.registry.url":"http://schema-registry:8081",
          "value.converter.schemas.enable": true,
          "database": "MongoCom0",
          "collection": "pb_salesbaskets",
          "topics": "pb_salesbaskets"
        }
      } 
      ' \
  http://localhost:8083/connectors -w "\n"


  curl -X POST \
  -H "Content-Type: application/json" \
  --data '
     { "name": "mongo-atlas-salespayments-sink-pb",
        "config": {
          "connector.class": "com.mongodb.kafka.connect.MongoSinkConnector",
          "connection.uri": "'${MONGO_URL}'",
          "key.converter": "org.apache.kafka.connect.storage.StringConverter",
          "value.converter":"io.confluent.connect.protobuf.ProtobufConverter",
          "value.converter.schema.registry.url":"http://schema-registry:8081",
          "value.converter.schemas.enable": true,
          "database": "MongoCom0",
          "collection": "pb_salespayments",
          "topics": "pb_salespayments"
        }
      } 
      ' \
  http://localhost:8083/connectors -w "\n"


# We dont do a salescompleted as thats to be done on Atlas using stream processing there.

 curl -X POST \
  -H "Content-Type: application/json" \
  --data '
     { "name": "mongo-atlas-salesbystorebyhour-sink-avro",
        "config": {
          "connector.class": "com.mongodb.kafka.connect.MongoSinkConnector",
          "connection.uri": "'${MONGO_URL}'",
          "key.converter": "org.apache.kafka.connect.storage.StringConverter",
          "value.converter":"io.confluent.connect.avro.AvroConverter",
          "value.converter.schema.registry.url":"http://schema-registry:8081",
          "value.converter.schemas.enable": true,
          "database": "MongoCom0",
          "collection": "sales_by_store_by_hour",
          "topics": "avro_sales_per_store_per_hour"
        }
      } 
      ' \
  http://localhost:8083/connectors -w "\n"

      
  curl -X POST \
  -H "Content-Type: application/json" \
  --data '
     { "name": "mongo-atlas-salesbystoreby5min-sink-avro",
        "config": {
          "connector.class": "com.mongodb.kafka.connect.MongoSinkConnector",
          "connection.uri": "'${MONGO_URL}'",
          "key.converter": "org.apache.kafka.connect.storage.StringConverter",
          "value.converter":"io.confluent.connect.avro.AvroConverter",
          "value.converter.schema.registry.url":"http://schema-registry:8081",
          "value.converter.schemas.enable": true,
          "database": "MongoCom0",
          "collection": "sales_by_store_by_5min",
          "topics": "avro_sales_per_store_per_5min"
        }
      } 
      ' \
  http://localhost:8083/connectors -w "\n"

