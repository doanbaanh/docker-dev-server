FROM php:7.2-fpm-alpine

LABEL maintainer="doanbaanh@gmail.com"

RUN apk update && apk --no-cache add \
	busybox-suid \
	ca-certificates \
	curl \
	freetype-dev \
	git \
	libjpeg-turbo-dev \
	libmcrypt-dev \
	libpng-dev \
	libwebp-dev \
	make \
	msmtp \
	nano \
	postgresql-dev \
	supervisor \
	&& docker-php-ext-configure gd \
		--with-gd \
		--with-webp-dir=/usr/include/ \
		--with-freetype-dir=/usr/include/ \
		--with-png-dir=/usr/include/ \
		--with-jpeg-dir=/usr/include/ \
	&& docker-php-ext-install bcmath gd pdo pdo_pgsql pdo_mysql mysqli opcache zip \
	&& rm /var/cache/apk/*

COPY .msmtprc /etc/.msmtprc
RUN chmod 600 /etc/.msmtprc \
	&& sed -i -e "s/user\s*=\s*www-data/user = root/g" /usr/local/etc/php-fpm.d/www.conf \
	&& sed -i -e "s/group\s*=\s*www-data/group = root/g" /usr/local/etc/php-fpm.d/www.conf

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
	&& php composer-setup.php \
	&& php -r "unlink('composer-setup.php');" \
	&& mv composer.phar /usr/local/bin/composer

COPY php.ini /usr/local/etc/php/php.ini
COPY www.conf /usr/local/etc/php-fpm.d/www.conf

WORKDIR /var/www

CMD ["php-fpm", "-R"]
