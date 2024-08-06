
.DEFAULT_GOAL := help

define HELP

Available commands:

- run: Run the project

- stop: Stop the project

- down: Down the project

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
# cd hdfs; make buildbase
# cd hdfs; make build
# cd sql-client; make build

run:
	docker compose -p devlab up -d
	./creTopics/creTopics.sh
	docker compose exec ksqldb-cli ksql -f ../crelSqlFlows/creStreams.sql  http://ksqldb-server:8088

stop:
	docker compose stop

down:	
	docker compose down

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