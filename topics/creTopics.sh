#!/bin/bash

export COMPOSE_PROJECT_NAME=devlab

docker compose exec broker kafka-topics \
 --create -topic pb_salespayments \
 --bootstrap-server localhost:9092 \
 --partitions 1 \
 --replication-factor 1

docker compose exec broker kafka-topics \
 --create -topic pb_salesbaskets \
 --bootstrap-server localhost:9092 \
 --partitions 1 \
 --replication-factor 1

# Lets list topics, excluding the default Confluent Platform topics
docker compose exec broker kafka-topics \
 --bootstrap-server localhost:9092 \
 --list | grep -v '_confluent' |grep -v '__' |grep -v '_schemas'

 ./reg_salespayments.sh

 ./reg_salesbaskets.sh