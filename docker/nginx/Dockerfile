FROM nginx:1.16-alpine

LABEL maintainer="doanbaanh@gmail.com"

COPY ./default.conf /etc/nginx/conf.d/default.conf
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./nginx.local.conf /etc/nginx/nginx.local.conf
COPY ./nginx.dev.conf /etc/nginx/nginx.dev.conf
