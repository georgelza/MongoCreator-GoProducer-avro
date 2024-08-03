
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
	sudo docker build -t apacheflink_sqlpod:1.18.1-scala_2.12-java11-d .

