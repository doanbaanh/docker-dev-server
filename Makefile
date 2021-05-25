# Makefile for web platform
.DEFAULT_GOAL := help

# arguments
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(ARGS):;@:)

# env
export APP_ENV = production
-include .env
export $(shell sed 's/=.*//' .env)

# mapping
export UID = $(shell id -u)
export GID = $(shell id -g)
export IP = $(shell ifconfig en0 | grep inet | awk '$$1=="inet" {print $$2}')

test: ## test
	@echo $$PWD

help: ## Show this help
	@printf "\033[33m%s:\033[0m\n" 'Available commands'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[32m%-18s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ./workspace/*/docker-compose.yml ## Build platform
	@docker-compose -f docker-compose.yml $(shell for compose in $^ ; do echo " -f $${compose}"; done) pull
	@docker-compose -f docker-compose.yml $(shell for compose in $^ ; do echo " -f $${compose}"; done) build

up: ./workspace/*/docker-compose.yml ## Run platform
	@docker-compose -f docker-compose.yml $(shell for compose in $^ ; do echo " -f $${compose}"; done) up -d

down: ./workspace/*/docker-compose.yml ## Stop platform
	@docker-compose -f docker-compose.yml $(shell for compose in $^ ; do echo " -f $${compose}"; done) down

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
	@echo 'Container names:'
	@docker ps | awk '(NR>1) { print "– " $$NF }'
	@echo ''
	@read -r -p "Enter container name: " CONTAINER; \
	docker exec -ti $$CONTAINER sh;
endif

clean: ## Clean logs
	@rm -rf ./logs/*

node-up: ## Run nodejs container
	@docker run -i -t --rm \
		--name node \
		--volumes-from web \
		--workdir /var/www \
		node:12-alpine sh

node-down: ## Stop nodejs container
	@docker stop node
	@docker rm node

cypress-up: ## Run cypress container
	@echo "Host machine IP:" $(IP)
	@read -r -p "Project name: " DIR \
	docker run -i -t --rm \
		--name cypress \
		--volumes-from web \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		--workdir /var/www/$$PROJECT/tests \
		-e DISPLAY=$(IP):0 \
		cypress/browser:node12.18.3-chrome89-ff86 \
		/bin/bash

cypress-down: ## Stop cypress container
	@docker stop cypress
	@docker rm cypress

ftp-up: ## Run FTP server
	@read -r -p "Project name: " DIR; \
	read -r -p "Username: " USERNAME; \
	read -r -p "Password: " PASSWORD; \
	docker run -d --rm \
		--name ftp \
		-p 20:20 -p 21:21 -p 47400-47470:47400-47470 \
		-v $$PWD/$$DIR:/home/vsftpd \
		-e FTP_USER=$$USERNAME \
		-e FTP_PASS=$$PASSWORD \
		-e PASV_ADDRESS=${shell curl ifconfig.co} \
		bogem/ftp;

ftp-down: ## Stop FTP server
	@docker stop ftp

backup: ## Dump databases
	@docker exec -t postgres pg_dumpall -c -U postgres > ./backups/postgres.sql
	@docker exec -t mysql /usr/bin/mysqldump -u root --password=mysql --all-databases > ./backups/mysql.sql

restore: ## Restore databases from dump
	@cat ./backups/postgres.sql | docker exec -i postgres psql -U postgres
	@cat ./backups/mysql.sql | docker exec -i mysql /usr/bin/mysql -u root --password=root
