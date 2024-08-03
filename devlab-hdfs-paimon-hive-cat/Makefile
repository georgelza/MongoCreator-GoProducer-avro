
.DEFAULT_GOAL := help

define HELP

Available commands:

- run: Run this project

endef

export HELP
help:
	@echo "$$HELP"
.PHONY: help

run:
	docker compose -p devlab up -d

down:
	docker compose down

stop:
	docker compose stop