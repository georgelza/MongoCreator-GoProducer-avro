
.DEFAULT_GOAL := help

define HELP

Available commands:

- build: Build all the images from the downloaded infrastructure components.

- run: This will startup the compose project 

- deploy: This will create all the catalogs, tables, flink inserts etc.

- stop: Stop the project

- down: Tear down the project, clean directories

- ps: Show all running containers

- logs: Show logs

- watch: Watch logs

- ksql: Open KSql

- fsql: Open Flink Sql

endef

export HELP
help:
	@echo "$$HELP"
.PHONY: help

build:
	cd connect; make build
	cd flink; make build;
	cd sql-client; make build
	cd ../app; make build

run: core
# Run the core, followed by deploy and then app

core: confluent flink hms misc

confluent:
	docker compose -p devlab up -d broker schema-registry control-center connect ksqldb-server ksqldb-cli kcat 
flink: 
	docker compose -p devlab up -d flink-jobmanager flink-taskmanager flink-sql-client
hms:
	docker compose -p devlab up -d minio mc postgres hive-metastore 
misc:
	docker compose -p devlab up -d pyiceberg duckdb

deploy: createcat createtopics deployksql deployflink1 deployflink2

createcat:
	docker compose exec flink-sql-client sql-client.sh -f /sql/creCat.sql
createtopics:
	cd ../creTopics; ./creTopics.sh
deployksql:
	docker compose exec ksqldb-cli ksql -f /sql/creStreams.sql  http://ksqldb-server:8088
deployflink1:
	docker compose exec flink-sql-client sql-client.sh -f /sql/creFlink_1.sql
deployflink2:
	docker compose exec flink-sql-client sql-client.sh -f /sql/creFlink_2.sql

app:
	docker compose -p devlab up -d app


stop:
	docker compose stop

down:	
	docker compose down
	cd data; cd minio; rm -rf * ;rm -rf .minio.sys ;rm -rf .DS*

ps:
	docker compose ps

logs:
	docker compose logs

watch:
	watch docker compose ps

ksql:
	docker compose exec ksqldb-cli ksql http://ksqldb-server:8088

fsql:
	docker compose exec flink-sql-client sql-client.sh
