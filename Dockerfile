FROM esepublic/baseimage
MAINTAINER Keith Bentrup <kbentrup@ebay.com>

RUN add-apt-repository ppa:ondrej/php5-5.6 && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes apache2 \
    libapache2-mod-php5 \
    php5-cli \
    php5-curl \
    php5-gd \
    php5-mcrypt \
    php-pear \
    php5-dev \
    php5-mysql \
    php5-intl \
    php5-xsl \
    php5-xdebug \
    mysql-client \
    rsync && \
  apt-get --purge autoremove -y && \
  apt-get clean && \
  rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/*

# install mod_pagespeed
RUN cd /tmp && \
  curl -O https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-beta_current_amd64.deb && \
  dpkg -i /tmp/mod-pagespeed-beta_current_amd64.deb && \
  apt-get -f install && \
  rm -rf /tmp/*

# remove default sites
# enable ssl, rewrite
# disable xdebug
RUN rm -rf /etc/apache2/sites-available/* /etc/apache2/sites-enabled/* && \
  mkdir -p /var/lock/apache2 /var/run/apache2 && \
  a2enmod ssl rewrite && \
  php5dismod xdebug
  
COPY apache2.conf /etc/apache2/

COPY apache2.sh /etc/service/apache2/run

COPY xdebug.ini /etc/php5/mods-available/
RUN echo -e "xdebug.remote_host=${XDEBUG_REMOTE_HOST:-127.0.0.1}
xdebug.remote_port=${XDEBUG_REMOTE_PORT:-9000}" >> /etc/php5/mods-available/xdebug.ini

EXPOSE 80 443
