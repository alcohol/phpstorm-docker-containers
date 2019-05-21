FROM php:7.0-fpm-alpine

RUN apk add --update --no-cache tini bash \
# install build dependencies
 && apk add --update --no-cache --virtual .build-deps autoconf g++ icu-dev make zlib-dev \
# enable extensions
 && docker-php-ext-configure intl \
 && docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) intl opcache zip \
# install xdebug (but don't enable it yet)
 && pecl install xdebug \
# install Blackfire probe
 && version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
 && curl -fLsS -A "Docker" -o /tmp/blackfire-probe.tar.gz https://blackfire.io/api/v1/releases/probe/php/alpine/amd64/$version \
 && mkdir -p /tmp/blackfire \
 && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp/blackfire \
 && mv /tmp/blackfire/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
 && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > $PHP_INI_DIR/conf.d/blackfire.ini \
 && rm -rf /tmp/blackfire /tmp/blackfire-probe.tar.gz \
# install Blackfire client
 && curl -fLsS -A "Docker" https://blackfire.io/api/v1/releases/client/linux_static/amd64 | tar zxp -C /usr/local/bin/ blackfire \
# filter out build dependencies that we need at runtime
 && runDeps="$( \
    scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
      | tr ',' '\n' \
      | sort -u \
      | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" \
 && apk add --virtual .phpext-rundeps $runDeps \
# uninstall remaining build dependencies
 && apk del .build-deps

COPY php.ini php-cli.ini $PHP_INI_DIR/

WORKDIR /srv

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["php-fpm"]
