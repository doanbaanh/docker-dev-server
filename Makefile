# Makefile for web platform
.DEFAULT_GOAL := help

# arguments
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(ARGS):;@:)

# user mapping
export UID = $(shell id -u)
export GID = $(shell id -g)

help: ## Show this help
	@printf "\033[33m%s:\033[0m\n" 'Available commands'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[32m%-18s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ./services/*/docker-compose.yml ## Build platform
	@docker-compose -f docker-compose.yml $(shell for compose in $^ ; do echo " -f $${compose}"; done) pull
	@docker-compose -f docker-compose.yml $(shell for compose in $^ ; do echo " -f $${compose}"; done) build

up: ./services/*/docker-compose.yml ## Run platform
	@docker-compose -f docker-compose.yml $(shell for compose in $^ ; do echo " -f $${compose}"; done) up -d

down: ./services/*/docker-compose.yml ## Stop platform
	@docker-compose -f docker-compose.yml $(shell for compose in $^ ; do echo " -f $${compose}"; done) down

restart: ## Restart platform
	@make down
	@make up

reload: ## Reload NGINX configuration and worker
	@UID="$(id -u)" GID="$(id -g)" docker-compose exec web nginx -s reload
	@UID="$(id -u)" GID="$(id -g)" docker-compose restart php-worker

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

backup: ## Dump databases
	@docker exec -t postgres pg_dumpall -c -U postgres > ./backups/postgres.sql
	@docker exec -t mysql /usr/bin/mysqldump -u root --password=mysql --all-databases > ./backups/mysql.sql

restore: ## Restore databases from dump
	@cat ./backups/postgres.sql | docker exec -i postgres psql -U postgres
	@cat ./backups/mysql.sql | docker exec -i mysql /usr/bin/mysql -u root --password=root

ftp-up: ## Run FTP server
	@read -r -p "Project name: " DIR; \
	read -r -p "Username: " USERNAME; \
	read -r -p "Password: " PASSWORD; \
	docker run -d --rm \
		--name ftp \
		-p 20:20 -p 21:21 -p 47400-47470:47400-47470 \
		-v /root/web/services/$$DIR:/home/vsftpd \
		-e FTP_USER=$$USERNAME \
		-e FTP_PASS=$$PASSWORD \
		-e PASV_ADDRESS=${shell curl ifconfig.co} \
		bogem/ftp;

ftp-down: ## Stop FTP server
	@docker stop ftp
