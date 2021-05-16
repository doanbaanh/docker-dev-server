FROM php:7.4-fpm-alpine

LABEL maintainer="doanbaanh@gmail.com"

ENV COMPOSER_ALLOW_SUPERUSER 1

RUN apk update && apk --no-cache --virtual add \
		$PHPIZE_DEPS \
		supervisor \
	&& rm /var/cache/apk/*

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions \
	&& sync \
	&& install-php-extensions \
		apcu \
		bcmath \
		exif \
		gd \
		imagick \
		intl \
		opcache \
		pdo_mysql \
		pdo_pgsql \
		redis \
		zip

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
	&& php composer-setup.php \
	&& php -r "unlink('composer-setup.php');" \
	&& mv composer.phar /usr/local/bin/composer

COPY php.ini /usr/local/etc/php/php.ini
COPY www.conf /usr/local/etc/php-fpm.d/www.conf

CMD ["php-fpm", "-R"]
