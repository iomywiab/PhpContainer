FROM --platform=$BUILDPLATFORM iomywiab-php-${PHP_VERSION}-cli-nodebug

# --------------------------------------------------
# XDebug
# --------------------------------------------------
RUN echo "Installing XDebug..."
RUN apt-get install php-xdebug || pecl install xdebug-${XDEBUG_VERSION} || pecl install xdebug
RUN echo "Installing XDebug: done."
RUN docker-php-ext-enable xdebug
RUN mkdir -p /opt/project/logs/xdebug/profiler \
&& echo "${XDEBUG_PORT}"                                      >> /usr/local/etc/php/conf.d/iomywiab-php.ini \
&& echo "${XDEBUG_MODE}"                                      >> /usr/local/etc/php/conf.d/iomywiab-php.ini \
&& echo "${XDEBUG_CONNECT}"                                   >> /usr/local/etc/php/conf.d/iomywiab-php.ini \
&& echo "${XDEBUG_CLIENT_HOST}"                               >> /usr/local/etc/php/conf.d/iomywiab-php.ini \
&& echo "${XDEBUG_START_WITH_REQUEST}"                        >> /usr/local/etc/php/conf.d/iomywiab-php.ini \
&& echo 'xdebug.output_dir=/opt/project/logs/xdebug/profiler' >> /usr/local/etc/php/conf.d/iomywiab-php.ini \
&& echo 'xdebug.log=/opt/project/logs/xdebug/xdebug.log'      >> /usr/local/etc/php/conf.d/iomywiab-php.ini \
&& echo 'PHP_IDE_CONFIG=serverName=debug-php-${PHP_VERSION}'  >> /etc/environment

#&& docker-php-ext-enable xdebug \

# PHP_IDE_CONFIG=serverName=debug-php-${PHP_VERSION} could be overwritten with Docker environment
