FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx
FROM --platform=$BUILDPLATFORM php:${PHP_VERSION}

COPY --from=xx / /

# --------------------------------------------------
# Linux
# --------------------------------------------------
RUN echo "Upgrading Linux..."
RUN apt-get update -y --fix-missing || ${IGNORE_UPDATES}
RUN apt-get upgrade -y

# --------------------------------------------------
# Register bitbucket for SSH access
# --------------------------------------------------
#ssh-keyscan -t ed25519 bitbucket.org >> /root/.ssh/known_hosts
# ssh -v  -T git@bitbucket.org

# --------------------------------------------------
# Linux tools
# --------------------------------------------------
RUN echo "Installing Linux tools..."
RUN apt-get install --no-install-recommends --assume-yes --quiet ca-certificates curl tmux nano shellcheck dstat less wget unzip procps htop || ${IGNORE_UPDATES}

# --------------------------------------------------
# Aliases
# --------------------------------------------------
RUN echo "Setting aliases..."
RUN echo "alias ll='ls -lha'" >> ~/.bashrc

# --------------------------------------------------
# PHP
# --------------------------------------------------
RUN echo "Configuring PHP engine..."
RUN echo "; PHP [${PHP_VERSION}] [${BASE_VERSION}] [$(date +'%F %T')]" > /usr/local/etc/php/conf.d/iomywiab-php.ini
RUN echo "${ERROR_REPORTING}"                                         >> /usr/local/etc/php/conf.d/iomywiab-php.ini

# --------------------------------------------------
# Git duplicate/delete
# --------------------------------------------------
RUN echo "Installing Git..."
RUN apt-get install --no-install-recommends --assume-yes --quiet git || ${IGNORE_UPDATES}

# --------------------------------------------------
# ZeroMQ
# --------------------------------------------------
#RUN echo "Installing ZeroMQ..."
#RUN apt-get install libzmq3-dev -y || ${IGNORE_UPDATES}
#RUN mkdir -p /pn/extensions \
#&& mkdir -p /tmp/zmq \
#&& cd /tmp/zmq \
#&& git clone https://github.com/zeromq/php-zmq.git \
#&& cd php-zmq  \
#&& phpize  \
#&& ./configure  \
#&& make  \
#&& make install \
#&& cd /pn/extensions/  \
#&& mv /tmp/zmq/php-zmq/modules/zmq.so ./  \
#&& rm -rf /tmp/zmq || ${IGNORE_UPDATES}
#RUN echo "extension=/pn/extensions/zmq.so" >> /usr/local/etc/php/conf.d/iomywiab-php.ini
##RUN docker-php-ext-install zmq

# --------------------------------------------------
# APCu
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
RUN echo "Installing Composer..."
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
&& php -r "copy('https://composer.github.io/installer.sig', 'composer-hash.txt');" \
&& php -r "if (hash_file('sha384', 'composer-setup.php') === file_get_contents(__DIR__.'/composer-hash.txt')) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
&& php composer-setup.php \
&& php -r "unlink('composer-setup.php');" \
&& mv composer.phar /usr/local/bin/composer
#&& composer config --global --auth bitbucket-oauth.bitbucket.org sup6BWqv4uvXTLTuWH WhBP7r7N56gec62n3WEv6e4kKHJy5MCR

# --------------------------------------------------
# Git
# --------------------------------------------------
RUN echo "Installing Git..."
RUN apt-get install --no-install-recommends --assume-yes --quiet git || ${IGNORE_UPDATES}

# --------------------------------------------------
# Python
# --------------------------------------------------
# RUN echo "Installing Python..."
# RUN apt-get install --no-install-recommends --assume-yes --quiet  python

# --------------------------------------------------
# KAFKA (Git)
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
RUN echo "Installing MySQL client..."
RUN apt-get install --no-install-recommends --assume-yes --quiet default-mysql-client

# --------------------------------------------------
# MySQLi
# --------------------------------------------------
RUN echo "Installing MySqli..."
RUN docker-php-ext-install mysqli

# --------------------------------------------------
# ext-pcntl
# --------------------------------------------------
RUN docker-php-ext-install pcntl

# --------------------------------------------------
# PDO
# --------------------------------------------------
RUN echo "Installing PDO..."
RUN docker-php-ext-install pdo_mysql

# --------------------------------------------------
# Redis
# --------------------------------------------------
RUN echo "Installing Redis..."
RUN pecl install redis-${REDIS_VERSION} \
&& docker-php-ext-enable redis

# Do not install redis server here, rather run redis container
#RUN apt-get install --no-install-recommends --assume-yes --quiet redis-server \
#&& mv /etc/redis/redis.conf /etc/redis/redis.conf_orig \
#&& cat /etc/redis/redis.conf_orig | sed 's/supervised no/supervised auto/g' > /etc/redis/redis.conf

# --------------------------------------------------
# SSH client
# --------------------------------------------------
#RUN echo "Installing SSH client..."
##RUN ssh-keyscan -H github.com           >> /root/.ssh/known_hosts
##RUN echo 'Host *'                       >> /root/.ssh/config
##RUN echo '    StrictHostKeyChecking no' >> /root/.ssh/config
##RUN echo '    IdentitiesOnly yes'       >> /root/.ssh/config
#RUN apt-get -y install openssh-client \
#&& mkdir -p /root/.ssh/
## COPY ./ssh/* /root/.ssh/

# --------------------------------------------------
# YAML
# --------------------------------------------------
RUN echo "Installing Yaml..."
RUN apt-get install -y libyaml-dev \
&& pecl install yaml  \
&& echo "extension=yaml.so" >> /usr/local/etc/php/conf.d/iomywiab-php.ini \
&& docker-php-ext-enable yaml

# --------------------------------------------------
# Zip
# --------------------------------------------------
RUN echo "Installing Zip..."
RUN set -eux \
&& apt-get install --no-install-recommends --assume-yes --quiet gzip libzip-dev zlib1g zip unzip \
&& docker-php-ext-install zip

# --------------------------------------------------
# Endless loop
# --------------------------------------------------
#COPY bootstrap.sh /bootstrap.sh
#RUN chmod +x /bootstrap.sh
#ENTRYPOINT [ "/bootstrap.sh" ]
CMD tail -f /dev/null

# --------------------------------------------------
# GD
# --------------------------------------------------
RUN echo "Installing Gd..."
RUN apt-get install --no-install-recommends --assume-yes --quiet libgd-dev \
&& docker-php-ext-install gd
