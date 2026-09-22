FROM php:8.4-cli-alpine AS base

# install non php package(s)
RUN set -eux; \
  apk add --no-cache --upgrade \
    bash \
    curl \
    openssh \
    tini

# install default extension(s)
RUN set -eux; \
  docker-php-ext-install -j"$(nproc)" \
    bcmath \
    ftp \
    gettext \
    intl \
    pcntl \
    pdo_mysql \
    soap \
    sockets \
    xsl \
    zip

COPY --from=ghcr.io/php/pie:bin /pie /usr/bin/pie

# install non-default extension(s)
RUN pie install --no-cache apcu/apcu

COPY php.ini php-cli.ini $PHP_INI_DIR/

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /srv

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["php-fpm"]

FROM base AS xdebug

RUN pie install --no-cache xdebug/xdebug

COPY xdebug.ini $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini
