
.DEFAULT_GOAL := build

define HELP

Available commands:

- build: Build this project

endef

export HELP
help:
	@echo "$$HELP"
.PHONY: help

build:
	sudo docker build -t kafka-connect-custom:1.2 .

