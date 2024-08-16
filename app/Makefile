
.ONESHELL:

BINARY_NAME=goprod-avro
VERSION=1.0.0

.DEFAULT_GOAL := help

define HELP

Available commands:

- compile: Compile Golang Binary

- build_docker: Build Docker Image

- push_docker: Push Docker Image

endef

export HELP
help:
	@echo "$$HELP"
.PHONY: help

compile:
	GOOS=linux GOARCH=arm64 go build -o cmd/ cmd/main.go
	
builddocker: 

	sudo docker build --platform linux/arm64 --no-cache -t ${BINARY_NAME}:${VERSION} .
	sudo docker tag ${BINARY_NAME}:${VERSION} georgelza/${BINARY_NAME}:${VERSION}
	sudo docker rmi ${BINARY_NAME}:${VERSION}

push_docker:
	sudo docker push georgelza/${BINARY_NAME}:${VERSION}

run_core: 
	docker compose -p devlab up -d broker schema-registry
	
deploy: createtopics

createtopics:
	cd ../creTopics; ./creTopics.sh

run_app:
	docker compose -p devlab up -d app

down: 
	docker compose down

ps: 
	docker compose ps

logs: 
	docker compose logs