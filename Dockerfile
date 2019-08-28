FROM alpine:3.10
LABEL maintainer="viveksam@gmail.com"

COPY root/. /

RUN echo "@community http://dl-4.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "@testing http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    echo "@edge https://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    # read packages and update
    apk update && apk upgrade && \
    # add packages
    apk add ca-certificates rsyslog logrotate runit && \
    # Make info file about this build
    mkdir -p /etc/BUILDS/ && \
    # # printf "Build of nimmis/alpine-micro:3.9, date: %s\n"  `date -u +"%Y-%m-%dT%H:%M:%SZ"` > /etc/BUILDS/alpine-micro && \
    # install extra from github, including replacement for process 0 (init)
    # add extra package for installation
    apk add curl && \
    cd /tmp && \
    # Install utils and init process
    curl -Ls https://github.com/nimmis/docker-utils/archive/master.tar.gz | tar xfz - && \
    ./docker-utils-master/install.sh && \
    rm -Rf ./docker-utils-master && \
    # Install backup support
    # # curl -Ls https://github.com/nimmis/backup/archive/master.tar.gz | tar xfz - && \
    # # ./backup-master/install.sh all && \
    # # rm -Rf ./backup-master && \
    # remove extra packages
    apk del curl && \
    # fix container bug for syslog
    # # sed  -i "s|\*.emerg|\#\*.emerg|" /etc/rsyslog.conf && \
    # # sed -i 's/$ModLoad imklog/#$ModLoad imklog/' /etc/rsyslog.conf && \
    # # sed -i 's/$KLogPermitNonKernelFacility on/#$KLogPermitNonKernelFacility on/' /etc/rsyslog.conf && \
    # Apache Install
    apk add apache2 libxml2-dev apache2-utils && \
    mkdir /web/ && chown -R apache.www-data /web && \
    sed -i 's#^DocumentRoot ".*#DocumentRoot "/web/html"#g' /etc/apache2/httpd.conf && \
    sed -i 's#AllowOverride [Nn]one#AllowOverride All#' /etc/apache2/httpd.conf && \
    sed -i 's#^ServerRoot .*#ServerRoot /web#g'  /etc/apache2/httpd.conf && \
    sed -i 's/^#ServerName.*/ServerName webproxy/' /etc/apache2/httpd.conf && \
    sed -i 's#^IncludeOptional /etc/apache2/conf#IncludeOptional /web/config/conf#g' /etc/apache2/httpd.conf && \
    sed -i 's#PidFile "/run/.*#Pidfile "/web/run/httpd.pid"#g'  /etc/apache2/conf.d/mpm.conf && \
    sed -i 's#Directory "/var/www/localhost/htdocs.*#Directory "/web/html" >#g' /etc/apache2/httpd.conf && \
    sed -i 's#Directory "/var/www/localhost/cgi-bin.*#Directory "/web/cgi-bin" >#g' /etc/apache2/httpd.conf && \
    sed -i 's#/var/log/apache2/#/web/logs/#g' /etc/logrotate.d/apache2 && \
    sed -i 's/Options Indexes/Options /g' /etc/apache2/httpd.conf && \
    # Php7 Install
    apk add --no-cache \
            libressl@edge \
            curl \
            wget \
            openssl \
            bash \
            nano \
            php7@community \
            php7-apache2@community \
            php7-openssl@community \
            php7-mbstring@community \
            php7-apcu@testing \
            php7-intl@community \
            php7-mcrypt@community \
            php7-json@community \
            php7-gd@community \
            php7-curl@community \
            php7-fpm@community \
            php7-mysqlnd@community \
            php7-pgsql@community \
            php7-sqlite3@community \
            php7-phar@community && \
    # ln -s /usr/bin/php7 /usr/bin/php && \
    cd /tmp && curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer && \
    # remove cached info
    rm -rf /var/cache/apk/*

# Expose backup volume

VOLUME /backup
VOLUME /web
# Set environment variables.

ENV HOME /root

# Define working directory.

WORKDIR /root
EXPOSE 80 443
# Define default command.

CMD ["/boot.sh"]