FROM php:8.5-rc-cli-alpine AS base

# install non php packages
RUN set -eux; \
  apk add --no-cache --upgrade \
    bash \
    curl \
    tini

# install non-default extensions
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN set -eux; \
  chmod +x /usr/local/bin/install-php-extensions; \
  install-php-extensions \
    apcu \
    bcmath \
    gettext \
    intl \
    opcache \
    pcntl \
    sockets \
    zip

COPY php.ini php-cli.ini $PHP_INI_DIR/

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /srv

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["php-fpm"]

FROM base AS xdebug

RUN set -eux; \
  install-php-extensions \
    xdebug

COPY xdebug.ini $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini
