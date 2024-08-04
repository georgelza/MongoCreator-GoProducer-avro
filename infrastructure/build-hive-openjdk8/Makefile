.DEFAULT_GOAL := help

HIVE_VERSION=3.1.3-java8
HADOOP_VERSION=3.3.5-java8
VERSION=1.0.0

define HELP

Available commands:

- basehadoop: Build the Apache Hadoop base image project

- basehive: Build the Apache Hive base image project

- build: Build this project

- run: Run the project

- stop: Stop the project

- down: Down the project

- hms: Connect to Hive Metastore container

- hive: Connect to Hive Server2 container

- pg: Connect to Postgres container

- ps: Show all running containers

- logs: Show logs

- watch: Watch logs

endef

export HELP
help:
	@echo "$$HELP"
.PHONY: help

custom_ca:
ifdef CUSTOM_CA
	cp -rf $(CUSTOM_CA)/* ca_certificates/ || cp -f $(CUSTOM_CA) ca_certificates/
endif

basehadoop:
	sudo docker build -t hadoop-base-$(HADOOP_VERSION):$(VERSION) --no-cache ./basehadoop

basehive:
	sudo docker build -t hive-base-$(HIVE_VERSION):$(VERSION) --no-cache ./basehive

build:  
	sudo docker build -t hive-metastore-$(HIVE_VERSION):$(VERSION) ./hive-metastore 
	sudo docker build -t hive-hiveserver2-$(HIVE_VERSION):$(VERSION) ./hive-hiveserver2

run:
	docker compose -p devlab up -d

stop:
	docker compose stop

down:	
	docker compose down

hms: 
	docker compose exec -it metaserver bash

hive:
	docker compose exec -it hiveserver2 bash

pg: 
	docker compose exec -it postgres bash

ps:
	docker compose ps

logs:
	docker compose logs

watch:
	watch docker compose ps