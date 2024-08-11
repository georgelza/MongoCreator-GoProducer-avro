
.ONESHELL:

BINARY_NAME=goprod-avro
VERSION=1.0.0
GOOS=linux
GOARCH=arm64
# GOOS=${GOOS} 
# GOARCH=${GOARCH}

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
# env GOOS=linux GOARCH=arm64 go build -o ./cmd/main ./cmd/main.go
#	go build -o ./cmd/main ./cmd/main.go
	sudo docker build --platform=linux/arm64 -t ${BINARY_NAME}:${VERSION} .
	

build_docker:
#	sudo docker build --platform=linux/arm64 -t ${BINARY_NAME}:${VERSION} .
	sudo docker build --platform=linux/arm64 -t ${BINARY_NAME}:${VERSION} .
	sudo docker tag ${BINARY_NAME}:${VERSION} georgelza/${BINARY_NAME}:${VERSION}
	sudo docker rmi ${BINARY_NAME}:${VERSION}

push_docker:
	sudo docker push georgelza/${BINARY_NAME}:${VERSION}

