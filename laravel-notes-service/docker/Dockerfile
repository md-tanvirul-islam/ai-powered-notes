FROM 8.4.1-fpm-alpine3.21

RUN apk update && \
    apk add --no-cache nginx git curl zip unzip openssh libzip-dev libpng-dev jpeg-dev freetype-dev gd bash \
    autoconf pkgconfig openssl-dev linux-headers shadow $PHPIZE_DEPS && \
    rm -rf /var/cache/apk/*

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

RUN docker-php-ext-install sockets pdo_mysql zip exif pcntl

RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg && \
    docker-php-ext-install gd

RUN pecl install redis && \
    docker-php-ext-enable redis

COPY --chown=www-data:www-data . /var/www/html

RUN deluser www-data && \
    adduser -D -u 1000 www-data

USER www-data

EXPOSE 80 443

CMD ["php-fpm"]
