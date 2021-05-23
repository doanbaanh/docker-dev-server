FROM doanbaanh/php-fpm

LABEL maintainer="doanbaanh@gmail.com"

RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini

RUN install-php-extensions xdebug
COPY xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
