# Makefile for web platform
.DEFAULT_GOAL := help

# arguments
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(ARGS):;@:)

# include docker-compose.extends.yml
ifneq ("$(wildcard ./docker-compose.extends.yml)","")
	DOCKER_COMPOSE_EXTENDS = -f docker-compose.extends.yml
endif



help: ## Show this help
	@printf "\033[33m%s:\033[0m\n" 'Available commands'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[32m%-18s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build platform
	@docker-compose -f docker-compose.yml $(DOCKER_COMPOSE_EXTENDS) pull
	@docker-compose -f docker-compose.yml $(DOCKER_COMPOSE_EXTENDS) build

up: ## Start platform
	@docker-compose -f docker-compose.yml $(DOCKER_COMPOSE_EXTENDS) up -d

down: ## Stop platform
	@docker-compose -f docker-compose.yml $(DOCKER_COMPOSE_EXTENDS) down

restart: ## Restart platform
	@make down
	@make up

reload: ## Reload NGINX configuration and worker
	@docker-compose exec web nginx -s reload
	@docker-compose restart php-worker

sh:  ## Attach to container
ifneq (,${ARGS})
	@docker exec -ti ${ARGS} sh
else
	@echo 'run: make sh <container_name>'
endif

clean: ## Clean logs
	@rm -rf ./logs/*

backup: ## Dump databases
	@docker exec -t postgres pg_dumpall -c -U postgres > ./backups/postgres.sql

restore: ## Restore databases from dump
	@cat ./backups/postgres.sql | docker exec -i postgres psql -U postgres
