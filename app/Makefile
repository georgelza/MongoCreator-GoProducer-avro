.DEFAULT_GOAL := help
include .env

.ONESHELL:

BINARY_NAME=goprod-avro
VERSION=1.0.0

define HELP

Available commands:

- build: Build Docker Image.
- push_docker: Push Docker Image.

- run_core: Run the Broker and Shema Registry.
- deploy: create topics and schema registry entries.

- run_app: Run the container app that will produce the documents onto the 2 topics.
- stop_app: Well... stop the app ;)

- down, ps & logs: well what is expected.

endef

export HELP
help:
	@echo "$$HELP"
.PHONY: help

build: 
	sudo docker build --platform linux/arm64 -t ${BINARY_NAME}:${VERSION} .
	sudo docker tag ${BINARY_NAME}:${VERSION} ${REPO_NAME}/${BINARY_NAME}:${VERSION}
	sudo docker rmi ${BINARY_NAME}:${VERSION}

push_docker:
	docker push ${REPO_NAME}/${BINARY_NAME}:${VERSION}

run_core: 
	docker compose -p devlab up -d broker schema-registry
	
deploy: createtopics

createtopics:
	cd ../creTopics; ./creTopics.sh

run_app:
	./run_avro.sh
#	docker compose -p devlab up -d app
# 	docker run -it --network devlab  georgelza/goprod-avro:1.0.0 runs_avro.sh

stop_app:
	docker compose -p devlab stop app

down: 
	docker compose down

ps: 
	docker compose ps

logs: 
	docker compose logs

monitor_app:
	docker compose logs -f app |grep Record