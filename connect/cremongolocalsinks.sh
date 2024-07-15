#!/bin/bash

# https://www.confluent.io/blog/kafka-connect-deep-dive-converters-serialization-explained/
#------------------------------------------------------------------------------
#-- Post/Sink to Local Mongo container

. ./.pwdmongolocal

# above file contains:
#
# LOCAL
# export MONGO_URL=mongodb://hostname:port/?directConnection=true


curl -X POST \
  -H "Content-Type: application/json" \
  --data '
      {"name": "mongo-local-salesbaskets-sink-avro",
        "config": {
          "connector.class":"com.mongodb.kafka.connect.MongoSinkConnector",
          "connection.uri": "'${MONGO_URL}'",
          "key.converter": "org.apache.kafka.connect.storage.StringConverter",
          "value.converter":"io.confluent.connect.avro.AvroConverter",
          "value.converter.schema.registry.url":"http://schema-registry:8081",
          "value.converter.schemas.enable": true,
          "database":"MongoCom0",
          "collection":"avro_salesbaskets",
          "topics":"avro_salesbaskets"
          }
      }
      ' \
  http://localhost:8083/connectors -w "\n"


curl -X POST \
  -H "Content-Type: application/json" \
  --data '
      {"name": "mongo-local-salespayments-sink-avro",
        "config": {
          "connector.class":"com.mongodb.kafka.connect.MongoSinkConnector",
          "connection.uri": "'${MONGO_URL}'",
          "key.converter": "org.apache.kafka.connect.storage.StringConverter",
          "value.converter":"io.confluent.connect.avro.AvroConverter",
          "value.converter.schema.registry.url":"http://schema-registry:8081",
          "value.converter.schemas.enable": true,
          "database":"MongoCom0",
          "collection":"avro_salespayments",
          "topics":"avro_salespayments"
          }
      }
      ' \
  http://localhost:8083/connectors -w "\n"

curl -X POST \
  -H "Content-Type: application/json" \
  --data '
     { "name": "mongo-local-salescompleted-sink-avro",
        "config": {
          "connector.class":"com.mongodb.kafka.connect.MongoSinkConnector",
          "connection.uri": "'${MONGO_URL}'",
          "key.converter": "org.apache.kafka.connect.storage.StringConverter",
          "value.converter":"io.confluent.connect.avro.AvroConverter",
          "value.converter.schema.registry.url":"http://schema-registry:8081",
          "value.converter.schemas.enable": true,
          "database":"MongoCom0",
          "collection":"avro_salescompleted",
          "topics":"avro_salescompleted"
          }
      }
      ' \
  http://localhost:8083/connectors -w "\n"


# Originate from kSQL processing
curl -X POST \
  -H "Content-Type: application/json" \
  --data '
     { "name": "mongo-local-sales-by-store-by-5min-sink-avro",
        "config": {
          "connector.class":"com.mongodb.kafka.connect.MongoSinkConnector",
          "connection.uri": "'${MONGO_URL}'",
          "key.converter": "org.apache.kafka.connect.storage.StringConverter",
          "value.converter":"io.confluent.connect.avro.AvroConverter",
          "value.converter.schema.registry.url":"http://schema-registry:8081",
          "value.converter.schemas.enable": true,
          "database":"MongoCom0",
          "collection":"avro_sales_by_store_by_5min",
          "topics":"avro_sales_per_store_per_5min"
          }
      }
      ' \
  http://localhost:8083/connectors -w "\n"


curl -X POST \
  -H "Content-Type: application/json" \
  --data '
     { "name": "mongo-local-sales-by-store-by-hour-sink-avro",
        "config": {
          "connector.class":"com.mongodb.kafka.connect.MongoSinkConnector",
          "connection.uri": "'${MONGO_URL}'",
          "key.converter": "org.apache.kafka.connect.storage.StringConverter",
          "value.converter":"io.confluent.connect.avro.AvroConverter",
          "value.converter.schema.registry.url":"http://schema-registry:8081",
          "value.converter.schemas.enable": true,
          "database":"MongoCom0",
          "collection":"avro_sales_by_store_by_hour",
          "topics":"avro_sales_per_store_per_hour"
          }
      }
      ' \
  http://localhost:8083/connectors -w "\n"

# Originates out of Flink Processing
  curl -X POST \
  -H "Content-Type: application/json" \
  --data '
     { "name": "mongo-local-sales-by-store-by-terminal-5min-x-sink-avro",
        "config": {
          "connector.class":"com.mongodb.kafka.connect.MongoSinkConnector",
          "connection.uri": "'${MONGO_URL}'",
          "key.converter": "org.apache.kafka.connect.storage.StringConverter",
          "value.converter":"io.confluent.connect.avro.AvroConverter",
          "value.converter.schema.registry.url":"http://schema-registry:8081",
          "value.converter.schemas.enable": true,
          "database":"MongoCom0",
          "collection":"avro_sales_by_store_by_terminal_5min_x",
          "topics":"avro_sales_per_store_per_terminal_per_5min_x"
          }
      }
      ' \
  http://localhost:8083/connectors -w "\n"

  curl -X POST \
  -H "Content-Type: application/json" \
  --data '
     { "name": "mongo-local-sales-by-store-by-terminal-hour-x-sink-avro",
        "config": {
          "connector.class":"com.mongodb.kafka.connect.MongoSinkConnector",
          "connection.uri": "'${MONGO_URL}'",
          "key.converter": "org.apache.kafka.connect.storage.StringConverter",
          "value.converter":"io.confluent.connect.avro.AvroConverter",
          "value.converter.schema.registry.url":"http://schema-registry:8081",
          "value.converter.schemas.enable": true,
          "database":"MongoCom0",
          "collection":"avro_sales_by_store_by_terminal_hour_x",
          "topics":"avro_sales_per_store_per_terminal_per_hour_x"
          }
      }
      ' \
  http://localhost:8083/connectors -w "\n"