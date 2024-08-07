
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
	cd hdfs; make buildbase
	cd hdfs; make build
	cd sql-client; make build

run:
	docker compose -p devlab up -d

deploy: createcat createtopics deployksql deployflink1 deployflink2

createtopics:
	cd ../creTopics; ./creTopics.sh
deployksql:
	docker compose exec ksqldb-cli ksql -f /sql/creStreams.sql  http://ksqldb-server:8088
createcat:
	docker compose exec flink-sql-client sql-client.sh -f /sql/creCat.sql
deployflink1:
	docker compose exec flink-sql-client sql-client.sh -f /sql/creFlink_1.sql
deployflink2:
	docker compose exec flink-sql-client sql-client.sh -f /sql/creFlink_2.sql

stop:
	docker compose stop

down:	
	docker compose down
	cd data; cd hdfs; rm -rf * ;rm -rf .DS*
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