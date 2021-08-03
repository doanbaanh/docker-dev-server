# Makefile for web platform
.DEFAULT_GOAL := help

# arguments
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(ARGS):;@:)

# env
# export APP_ENV = production
# -include .env
# export $(shell sed 's/=.*//' .env)

# mapping
export UID = $(shell id -u)
export GID = $(shell id -g)
export IP = $(shell ifconfig en0 | grep inet | awk '$$1=="inet" {print $$2}')

help: ## Show this help
	@printf "\033[33m%s:\033[0m\n" 'Available commands'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[32m%-18s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build development server
	@docker-compose -f docker-compose.yml pull
	@docker-compose -f docker-compose.yml build

up: ## Run development server
	@docker-compose -f docker-compose.yml up -d

down: ## Stop development server
	@docker-compose -f docker-compose.yml down

restart: ## Restart development server
	@make down
	@make up

reload: ## Reload NGINX configuration
	@docker-compose exec web nginx -s reload

restart-workers: ## Restart PHP workers
	@docker-compose restart php5-worker
	@docker-compose restart php7-worker
	@docker-compose restart php8-worker

sh:  ## Attach to container
ifneq (,${ARGS})
	@docker exec -ti ${ARGS} sh
else
	@echo 'Container names:'
	@docker ps | awk '(NR>1) { print "– " $$NF }'
	@echo ''
	@read -r -p "Enter container name: " CONTAINER; \
	docker exec -ti $$CONTAINER sh;
endif

clean: ## Clean logs
	@rm -rf ./logs/*

dump: ## Dump databases
	@docker exec -t postgres pg_dumpall -c -U postgres > ./backups/postgres.sql
	@docker exec -t mysql /usr/bin/mysqldump -u root --password=mysql --all-databases > ./backups/mysql.sql

restore: ## Restore databases from dump
	@cat ./backups/postgres.sql | docker exec -i postgres psql -U postgres
	@cat ./backups/mysql.sql | docker exec -i mysql /usr/bin/mysql -u root --password=root

cypress-up: ## Run cypress container
	@echo "Starting XQuartz service ..."
	@open -a XQuartz
	@echo "Host machine IP:" $(IP)
	@xhost + $$IP
	@read -r -p "Project name: " DIR; \
	read -r -p "Base url: http://" BASE_URL; \
	export DIR=$$DIR; \
	export BASE_URL=$$BASE_URL; \
	docker-compose -f docker-compose.yml -f ./docker/docker-compose.yml up cypress

cypress-down: ## Stop cypress container
	@docker rm -f cypress

ftp-up: ## Run FTP server
	@read -r -p "Project name: " DIR; \
	read -r -p "Username: " USERNAME; \
	read -r -p "Password: " PASSWORD; \
	export DIR=$$DIR; \
	export USERNAME=$$USERNAME; \
	export PASSWORD=$$PASSWORD; \
	export EXTERNAL_IP=${shell curl ifconfig.co} \
	docker-compose -f docker-compose.yml -f ./docker/docker-compose.yml up ftp

ftp-down: ## Stop FTP server
	@docker rm -f ftp
