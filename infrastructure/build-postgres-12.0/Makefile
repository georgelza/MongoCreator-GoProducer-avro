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
	sudo docker build -t postgres-12.0:1.0.0 .

