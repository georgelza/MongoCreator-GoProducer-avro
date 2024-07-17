#!/bin/bash

export COMPOSE_PROJECT_NAME=devlab

docker compose exec broker kafka-topics \
 --create -topic avro_salespayments \
 --bootstrap-server mbp.local:9092 \
 --partitions 1 \
 --replication-factor 1

docker compose exec broker kafka-topics \
 --create -topic avro_salesbaskets \
 --bootstrap-server mbp.local:9092 \
 --partitions 1 \
 --replication-factor 1

# Lets list topics, excluding the default Confluent Platform topics
docker compose exec broker kafka-topics \
 --bootstrap-server mbp.local:9092 \
 --list | grep -v '_confluent' |grep -v '__' |grep -v '_schemas'

 ./reg_salespayments.sh

 ./reg_salesbaskets.sh