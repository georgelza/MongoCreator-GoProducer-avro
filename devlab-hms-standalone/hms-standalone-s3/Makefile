
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
	sudo docker build -t hms-standalone-s3:1.0 .

