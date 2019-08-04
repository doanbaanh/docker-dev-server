#!/usr/bin/make
SHELL = /bin/sh

# import env
include .env
export $(shell sed 's/=.*//' .env)

# default make action
.DEFAULT_GOAL := help

# variables
T_START=\033[0;32m
T_END=\033[0m

# commands
help:
	@echo "${T_START}CLI:${T_END}"
	@echo '  make php-sh  - PHP SH'
	@echo ''
	@echo "${T_START}Web Server:${T_END}"
	@echo '  make build   - Сборка сервисов'
	@echo '  make up      - Запуск веб сервера'
	@echo '  make down    - Остановка сервера'
	@echo '  make restart - Перезапуск сервера'
	@echo '  make update  - Обновление сервера из репозитории'
	@echo '  make restart-nginx - Перезагрузка NGINX'
	@echo ''

build:
ifeq ($(APP_ENV), production)
	docker-compose -f docker-compose.prod.yml pull
	docker-compose -f docker-compose.prod.yml build
else ifeq ($(APP_ENV), development)
	docker-compose -f docker-compose.dev.yml pull
	docker-compose -f docker-compose.dev.yml build
else
	docker-compose pull
	docker-compose build
endif

# CLI
php-sh:
ifeq ($(APP_ENV), production)
	docker-compose -f docker-compose.prod.yml exec php sh
else ifeq ($(APP_ENV), development)
	docker-compose -f docker-compose.dev.yml exec php sh
else
	docker-compose exec php sh
endif

# SERVER
up:
ifeq ($(APP_ENV), production)
	docker-compose -f docker-compose.prod.yml up -d
else ifeq ($(APP_ENV), development)
	docker-compose -f docker-compose.dev.yml up -d
else
	docker-compose up -d
endif

down:
ifeq ($(APP_ENV), production)
	docker-compose -f docker-compose.prod.yml down
else ifeq ($(APP_ENV), development)
	docker-compose -f docker-compose.dev.yml down
else
	docker-compose down
endif

restart:
ifeq ($(APP_ENV), production)
	docker-compose -f docker-compose.prod.yml down
	docker-compose -f docker-compose.prod.yml up -d
else ifeq ($(APP_ENV), development)
	docker-compose -f docker-compose.dev.yml down
	docker-compose -f docker-compose.dev.yml up -d
else
	docker-compose down
	docker-compose up -d
endif

restart-nginx:
ifeq ($(APP_ENV), production)
	docker-compose -f docker-compose.prod.yml restart nginx
else ifeq ($(APP_ENV), development)
	docker-compose -f docker-compose.dev.yml restart nginx
else
	docker-compose restart nginx
endif
