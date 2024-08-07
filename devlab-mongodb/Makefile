
.DEFAULT_GOAL := help

define HELP

Available commands:

- build: Build all the images from the downloaded infrastructure components.

- run: This will startup the compose project 

- deploy: This will create all the catalogs, tables, flink inserts etc.

- run: Run the project

- stop: Stop the project

- down: Down the project

- ps: Show all running containers

- logs: Show logs

- watch: Watch logs

endef

export HELP
help:
	@echo "$$HELP"
.PHONY: help

build:
	cd connect; make build

run:
	docker compose -p devlab up -d

deploy: createtopics deployksql deployconnect

createtopics:
	cd ../creTopics; ./creTopics.sh
deployksql:
	docker compose exec ksqldb-cli ksql -f /sql/creStreams.sql  http://ksqldb-server:8088
deployconnect:
	cd ../creConnect; ./cremongoatlassinks.sh

stop:
	docker compose stop

down:	
	docker compose down

down:	
	docker compose down

ps:
	docker compose ps

logs:
	docker compose logs

watch:
	watch docker compose ps