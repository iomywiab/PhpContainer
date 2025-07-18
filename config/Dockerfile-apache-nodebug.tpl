FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx
FROM --platform=$BUILDPLATFORM php:${PHP_VERSION}-apache

COPY --from=xx / /

# --------------------------------------------------
# Linux
# --------------------------------------------------
RUN echo "Upgrading Linux..."; \
apt-get update -y --fix-missing && apt-get upgrade -y

# --------------------------------------------------
# Linux tools
# --------------------------------------------------
RUN echo "Installing Linux tools..."; \
apt-get install --no-install-recommends --assume-yes --quiet ca-certificates curl tmux nano shellcheck dstat less wget htop  || ${IGNORE_UPDATES}

# --------------------------------------------------
# Apache config
# --------------------------------------------------
RUN echo "Enabling mod_rewrite"; \
a2enmod rewrite

# --------------------------------------------------
# Aliases
# --------------------------------------------------
RUN echo "Setting aliases..."; \
echo "alias ll='ls -lha'" >> ~/.bashrc

# --------------------------------------------------
# Git duplicate/delete
# --------------------------------------------------
RUN echo "Installing Git..."; \
apt-get install --no-install-recommends --assume-yes --quiet git

# --------------------------------------------------
# PHP config
# --------------------------------------------------
RUN echo "; PHP [${PHP_VERSION}] [${BASE_VERSION}] [$(date +'%F %T')]" > /usr/local/etc/php/conf.d/iomywiab-php.ini
RUN echo "${ERROR_REPORTING}"                                         >> /usr/local/etc/php/conf.d/iomywiab-php.ini

# --------------------------------------------------
# ZeroMQ client
# --------------------------------------------------
#RUN echo "Installing ZeroMQ..."
#RUN apt-get install libzmq3-dev -y
#RUN mkdir -p /iomywiab-php/extensions \
#&& mkdir -p /tmp/zmq && cd /tmp/zmq \
#&& git clone https://github.com/zeromq/php-zmq.git && cd php-zmq && phpize && ./configure && make && make install \
#&& cd /iomywiab-php/extensions/ && mv /tmp/zmq/php-zmq/modules/zmq.so ./ && rm -rf /tmp/zmq
#RUN echo "extension=/iomywiab-php/extensions/zmq.so" >> /usr/local/etc/php/conf.d/iomywiab-php.ini
##RUN docker-php-ext-install zmq

# --------------------------------------------------
# PHP Extension APCu (deprecated?)
# --------------------------------------------------
#RUN echo "Installing APCu..."
#RUN pecl install apcu \
#&& docker-php-ext-enable apcu \
#&& echo "apc.enable_cli=1"       >> /usr/local/etc/php/conf.d/iomywiab-php.ini \
#&& echo "apc.enable=1"           >> /usr/local/etc/php/conf.d/iomywiab-php.ini \
#&& echo "apc.use_request_time=0" >> /usr/local/etc/php/conf.d/iomywiab-php.ini

# --------------------------------------------------
# Composer
# --------------------------------------------------
RUN echo "Installing Composer..."; \
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
&& php -r "copy('https://composer.github.io/installer.sig', 'composer-hash.txt');" \
&& php -r "if (hash_file('sha384', 'composer-setup.php') === file_get_contents(__DIR__.'/composer-hash.txt')) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
&& php composer-setup.php \
&& php -r "unlink('composer-setup.php');" \
&& mv composer.phar /usr/local/bin/composer
#&& composer config --global --auth bitbucket-oauth.bitbucket.org sup6BWqv4uvXTLTuWH WhBP7r7N56gec62n3WEv6e4kKHJy5MCR

# --------------------------------------------------
# Python
# --------------------------------------------------
# RUN echo "Installing Python..."
# RUN apt-get install --no-install-recommends --assume-yes --quiet  python

# --------------------------------------------------
# PHP Extension KAFKA client
# --------------------------------------------------
#RUN echo "Installing Kafka..."
#RUN mkdir -p /tmp/kafka/&& cd /tmp/kafka \
#&& git clone --depth 1 --branch v1.8.2 https://github.com/edenhill/librdkafka.git \
#&& ( cd librdkafka && ./configure && make && make install ) \
#&& pecl install rdkafka \
#&& echo "extension=rdkafka.so" >> /usr/local/etc/php/conf.d/iomywiab-php.ini

# --------------------------------------------------
# MySql client
# --------------------------------------------------
RUN echo "Installing MySQL client..."; \
apt-get install --no-install-recommends --assume-yes --quiet default-mysql-client

# --------------------------------------------------
# PHP Extension MySQLi client
# --------------------------------------------------
RUN echo "Installing MySqli..."; \
docker-php-ext-install mysqli

# --------------------------------------------------
# PHP Extension pcntl
# --------------------------------------------------
RUN docker-php-ext-install pcntl

# --------------------------------------------------
# PHP Extension PDO
# --------------------------------------------------
RUN echo "Installing PDO..."; \
docker-php-ext-install pdo_mysql

# --------------------------------------------------
# PHP Extension Redis client
# --------------------------------------------------
RUN echo "Installing Redis..."; \
pecl install redis-${REDIS_VERSION} \
&& docker-php-ext-enable redis

# Do not install redis server here, rather run redis container
#RUN apt-get install --no-install-recommends --assume-yes --quiet redis-server \
#&& mv /etc/redis/redis.conf /etc/redis/redis.conf_orig \
#&& cat /etc/redis/redis.conf_orig | sed 's/supervised no/supervised auto/g' > /etc/redis/redis.conf

# --------------------------------------------------
# SSH client
# --------------------------------------------------
##RUN ssh-keyscan -H github.com           >> /root/.ssh/known_hosts
##RUN echo 'Host *'                       >> /root/.ssh/config
##RUN echo '    StrictHostKeyChecking no' >> /root/.ssh/config
##RUN echo '    IdentitiesOnly yes'       >> /root/.ssh/config
#RUN echo "Installing SSH client..."; \
#apt-get -y install openssh-client \
#&& mkdir -p /root/.ssh/
##COPY ./ssh/* /root/.ssh/

# --------------------------------------------------
# PHP Extension YAML
# --------------------------------------------------
RUN echo "Installing Yaml..."; \
apt-get install -y libyaml-dev \
&& pecl install yaml  \
&& echo "extension=yaml.so" >> /usr/local/etc/php/conf.d/iomywiab-php.ini \
&& docker-php-ext-enable yaml

# --------------------------------------------------
# PHP Extension Zip
# --------------------------------------------------
RUN echo "Installing Zip..."; \
set -eux \
&& apt-get install --no-install-recommends --assume-yes --quiet gzip libzip-dev zlib1g zip unzip \
&& docker-php-ext-install zip

# --------------------------------------------------
# PHP Extension GD
# --------------------------------------------------
RUN echo "Installing GD..."; \
apt-get install -y libpng-dev libgd-dev \
&& docker-php-ext-install gd

# --------------------------------------------------
# PHP Extension intl
# --------------------------------------------------
RUN echo "Installing intl..."; \
apt-get install -y libicu-dev icu-devtools \
&& docker-php-ext-install intl

# --------------------------------------------------
# Memory limit
# --------------------------------------------------
RUN echo "Installing memory_limit..."; \
echo "memory_limit=512M" >> /usr/local/etc/php/conf.d/iomywiab-php.ini
