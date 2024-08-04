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
	sudo docker build -t ubuntu20.04-openjdk11:1.0.0 .
