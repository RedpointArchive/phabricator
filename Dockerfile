FROM hachque/systemd-none

# Install requirements
RUN zypper --non-interactive in git

# Create nginx user and group
RUN echo "nginx:x:497:495:user for nginx:/var/lib/nginx:/bin/false" >> /etc/passwd
RUN echo "nginx:!:495:" >> /etc/group

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
RUN zypper --non-interactive in nginx php-fpm php5-mbstring php5-mysql php5-curl php5-pcntl php5-gd php5-openssl php5-ldap php5-fileinfo php5-posix php5-json php5-iconv php5-ctype php5-zip php5-sockets which python-Pygments nodejs ca-certificates ca-certificates-mozilla ca-certificates-cacert sudo

# Expose Nginx on port 80 and 443
EXPOSE 80
EXPOSE 443

# Expose Aphlict (notification server) on 843 and 22280
EXPOSE 843
EXPOSE 22280

# Expose SSH port 24 (Git SSH will be on 22, regular SSH on 24)
EXPOSE 24

# Add files
ADD nginx.conf /etc/nginx/nginx.conf
ADD nginx-ssl.conf /etc/nginx/nginx-ssl.conf
ADD fastcgi.conf /etc/nginx/fastcgi.conf
ADD 25-nginx /etc/init.simple/25-nginx
ADD 25-php-fpm /etc/init.simple/25-php-fpm
ADD 10-boot-conf /etc/init.simple/10-boot-conf
ADD 35-phd /etc/init.simple/35-phd
ADD 40-aphlict /etc/init.simple/40-aphlict
ADD php-fpm.conf /etc/php5/fpm/php-fpm.conf
ADD php.ini /etc/php5/fpm/php.ini

# Move the default SSH to port 24
RUN echo "" >> /etc/ssh/sshd_config
RUN echo "Port 24" >> /etc/ssh/sshd_config

# Configure Phabricator SSH service
RUN mkdir /etc/phabricator-ssh
ADD sshd_config.phabricator /etc/phabricator-ssh/sshd_config.phabricator
ADD 45-phabricator-ssh /etc/init.simple/45-phabricator-ssh
ADD phabricator-ssh-hook.sh /etc/phabricator-ssh/phabricator-ssh-hook.sh
RUN chown root:root /etc/phabricator-ssh/*

# Workaround for https://gist.github.com/porjo/35ea98cb64553c0c718a
RUN chmod u+s /usr/sbin/postdrop
RUN chmod u+s /usr/sbin/postqueue

# Set /init as the default
CMD ["/init"]
