
.DEFAULT_GOAL := help

define HELP

Available commands:

- build: Build this project

endef

export HELP
help:
	@echo "$$HELP"
.PHONY: help

build:
	sudo docker build -t apacheflink:1.18.1-scala_2.12-java11 .

