FROM hachque/systemd-none

# Install requirements
RUN zypper --non-interactive in git

# Add user
RUN echo "git:x:2000:2000:user for phabricator:/srv/phabricator:/bin/bash" >> /etc/passwd
RUN echo "wwwgrp-phabricator:!:2000:nginx" >> /etc/group

# Set up the Phabricator code base
RUN mkdir /srv/phabricator
RUN chown git:wwwgrp-phabricator /srv/phabricator
USER git
WORKDIR /srv/phabricator
RUN git clone git://github.com/facebook/libphutil.git
RUN git clone git://github.com/facebook/arcanist.git
RUN git clone git://github.com/facebook/phabricator.git
USER root
WORKDIR /

# Install requirements
RUN zypper --non-interactive in nginx php-fpm php5-mbstring php5-mysql php5-curl php5-pcntl php5-gd php5-openssl php5-ldap php5-fileinfo php5-posix php5-json php5-iconv which

# Expose Nginx on port 80 and 443
EXPOSE 80
EXPOSE 443

# Add files
ADD nginx.conf /etc/nginx/nginx.conf
ADD nginx-ssl.conf /etc/nginx/nginx-ssl.conf
ADD fastcgi.conf /etc/nginx/fastcgi.conf
ADD 25-nginx /etc/init.simple/25-nginx
ADD 25-php-fpm /etc/init.simple/25-php-fpm
ADD 10-boot-conf /etc/init.simple/10-boot-conf
ADD php-fpm.conf /etc/php5/fpm/php-fpm.conf
ADD php.ini /etc/php5/fpm/php.ini

# Set /init as the default
CMD ["/init"]
