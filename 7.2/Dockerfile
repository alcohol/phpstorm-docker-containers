FROM php:7.2-cli-alpine AS base

RUN set -eux; \
  apk add --no-cache --upgrade tini bash; \
  apk add --no-cache --virtual .build-deps \
    autoconf \
    coreutils \
    g++ \
    icu-dev \
    libzip-dev \
    make \
    zlib-dev; \
  docker-php-ext-configure intl; \
  docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) intl opcache zip; \
  runDeps="$( \
    scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
      | tr ',' '\n' \
      | sort -u \
      | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
  )"; \
  apk add --no-cache $runDeps; \
  apk del --no-network .build-deps; \
  rm -rf /tmp/pear ~/.pearrc

COPY php.ini php-cli.ini $PHP_INI_DIR/

WORKDIR /srv

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["php-fpm"]

FROM base AS xdebug

RUN set -eux; \
  apk add --no-cache --virtual .build-deps autoconf g++ make icu-dev zlib-dev libzip-dev; \
  pecl install xdebug; \
  runDeps="$( \
    scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
      | tr ',' '\n' \
      | sort -u \
      | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
  )"; \
  apk add --no-cache $runDeps; \
  apk del --no-network .build-deps; \
  rm -rf /tmp/pear ~/.pearrc

COPY xdebug.ini $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini
