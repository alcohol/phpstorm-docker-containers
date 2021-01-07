FROM php:7.4-cli-alpine AS base

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
    apcu_bc \
    bcmath \
    gettext \
    intl \
    mcrypt \
    opcache \
    pcntl \
    sockets \
    zip

COPY php.ini php-cli.ini $PHP_INI_DIR/

WORKDIR /srv

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["php-fpm"]

FROM base AS xdebug

RUN set -eux; \
  install-php-extensions \
    xdebug

COPY xdebug.ini $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini
