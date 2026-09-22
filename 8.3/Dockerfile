FROM php:8.3-cli-alpine AS base

# install non php package(s)
RUN apk add --no-cache --upgrade \
    bash \
    curl \
    openssh \
    tini

# install build dependencies
RUN apk add --no-cache --upgrade --virtual .build-deps \
  $PHPIZE_DEPS \
  gettext-dev \
  icu-dev \
  libtool \
  libxml2-dev \
  libxslt-dev \
  libzip-dev \
  linux-headers

# install runtime dependencies
RUN apk add --no-cache --upgrade \
  gettext \
  icu-data-full \
  icu-libs \
  libxml2 \
  libxslt \
  libzip \
  tzdata

# install default extension(s)
RUN docker-php-ext-install -j"$(nproc)" \
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

# clean up build dependencies
RUN apk del --no-cache --purge .build-deps

COPY php.ini php-cli.ini $PHP_INI_DIR/

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /srv

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["php"]

FROM base AS xdebug

RUN apk add --no-cache --upgrade --virtual .build-deps \
  $PHPIZE_DEPS \
  libtool \
  linux-headers

RUN pie install --no-cache xdebug/xdebug

RUN apk del --no-cache --purge .build-deps

COPY xdebug.ini $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini
