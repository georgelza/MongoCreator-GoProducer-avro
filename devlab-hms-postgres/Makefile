
.DEFAULT_GOAL := help

define HELP

Available commands:

- build: Build all the images from the downloaded infrastructure components. After this execute "make run", followed by "make deploy" and then "make app".

- run: This will startup the core infrastructure of the project first
- deploy: This will create the Kafka topics, schema entries, all the Hive catalogs, Flink tables, flink inserts jobs etc.
- run_app: Run workload creator/the Golang app.
- stop_app: Stop the workload creator/the Golang app.

- stop: Stop the project.
- down: Tear down the project, clean directories.
- ps: Show all running containers.

- logs: Show logs.
- monitor_app: show the logs of the workload creator/the Golang app.

- watch: Watch logs.
- ksql: Open KSql.
- fsql: Open Flink Sql.

endef

export HELP
help:
	@echo "$$HELP"
.PHONY: help

build:
	cd connect; make build
	cd flink; make build
	cd sql-client; make build
	cd ../app; make build

run: core
# Run the core, followed by deploy and then app

core:
	docker compose -p devlab up -d broker schema-registry control-center connect 
	docker compose -p devlab up -d ksqldb-server ksqldb-cli kcat 
	docker compose -p devlab up -d hive-metastore
	docker compose -p devlab up -d flink-sql-client 
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

run_app:
	docker compose -p devlab up -d app

stop_app:
	docker compose -p devlab stop app

stop:
	docker compose stop

down:	
	docker compose down
	cd data; cd minio; rm -rf * ;rm -rf .minio.sys ;rm -rf .DS*

ps:
	docker compose ps

logs:
	docker compose logs

monitor_app:
	docker compose logs -f app |grep Record

watch:
	watch docker compose ps

ksql:
	docker compose exec ksqldb-cli ksql http://ksqldb-server:8088

fsql:
	docker compose exec flink-sql-client sql-client.sh
