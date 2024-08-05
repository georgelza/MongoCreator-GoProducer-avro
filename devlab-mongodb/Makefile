
.DEFAULT_GOAL := help

define HELP

Available commands:

- run: Run the project

- stop: Stop the project

- down: Down the project

- ps: Show all running containers

- logs: Show logs

- watch: Watch logs

endef

export HELP
help:
	@echo "$$HELP"
.PHONY: help

run:
	docker compose -p devlab up -d

stop:
	docker compose stop

down:	
	docker compose down

ps:
	docker compose ps

logs:
	docker compose logs

watch:
	watch docker compose ps