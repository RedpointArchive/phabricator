FROM hachque/systemd-none

# Update base image
RUN zypper --non-interactive patch || true
# Update again in case package manager was updated.
RUN zypper --non-interactive patch

# Install requirements
RUN zypper --non-interactive in git

# Install NodeJS + WebSockets module
RUN zypper --non-interactive ar http://download.opensuse.org/repositories/home:/marec2000:/nodejs/openSUSE_13.1/ nodejs
RUN zypper --gpg-auto-import-keys --non-interactive in nodejs-ws
RUN zypper --non-interactive rr nodejs

# Install requirements
RUN zypper --non-interactive in nginx php-fpm php5-mbstring php5-mysql php5-curl php5-pcntl php5-gd php5-openssl php5-ldap php5-fileinfo php5-posix php5-json php5-iconv php5-ctype php5-zip php5-sockets which python-Pygments nodejs ca-certificates ca-certificates-mozilla ca-certificates-cacert sudo subversion mercurial php5-xmlwriter

# The long line below is the expansion of the following shorter line.
# We track the long line explicitly so we can uninstall the packages only needed for building.
#RUN zypper --non-interactive install php5-devel php5-pear gcc autoconf make
RUN zypper --non-interactive install autoconf automake binutils cpp cpp48 gcc gcc48 glibc-devel libasan0 libatomic1 libcloog-isl4 libgomp1 libisl10 libitm1 libltdl7 libmpc3 libmpfr4 libpcre16-0 libpcrecpp0 libpcreposix0 libstdc++-devel libstdc++48-devel libtool libtsan0 libxml2-devel libxml2-tools linux-glibc-devel m4 make ncurses-devel pcre-devel php5-devel php5-pear php5-zlib pkg-config readline-devel tack xz-devel zlib-devel

# pecl runs configure, make, and copies the result into the local php extension path
RUN pecl install apc

# Now we don't need any of the build tools anymore, remove them.
#RUN zypper --non-interactive remove gcc autoconf automake
RUN zypper --non-interactive remove autoconf automake binutils cpp cpp48 gcc gcc48 glibc-devel libasan0 libatomic1 libcloog-isl4 libgomp1 libisl10 libitm1 libltdl7 libmpc3 libmpfr4 libpcre16-0 libpcrecpp0 libpcreposix0 libstdc++-devel libstdc++48-devel libtool libtsan0 libxml2-devel libxml2-tools linux-glibc-devel m4 ncurses-devel pcre-devel php5-devel php5-pear pkg-config readline-devel tack xz-devel zlib-devel

# Remove cached things taht pecl left in /tmp/
RUN rm -rf /tmp/*

# Install a few extra things
RUN zypper --non-interactive install mariadb-client vim vim-data

# Force reinstall cronie
RUN zypper --non-interactive install -f cronie

# Remove cached things taht pecl left in /tmp/
RUN rm -rf /tmp/*

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
RUN git clone --progress git://github.com/facebook/phabricator.git
RUN git clone --progress git://github.com/PHPOffice/PHPExcel.git
USER root
WORKDIR /

# Clone Let's Encrypt
RUN git clone https://github.com/letsencrypt/letsencrypt /srv/letsencrypt

# Install WinRM tool
RUN zypper --non-interactive in go
WORKDIR /root/
RUN git clone https://github.com/masterzen/winrm
WORKDIR /root/winrm
RUN mkdir /root/.go
RUN GOPATH=/root/.go make
RUN cp /root/.go/bin/winrm /usr/bin/winrm
RUN chmod a+x /usr/bin/winrm
RUN zypper --non-interactive rm go make
WORKDIR /

# Install letsencrypt
WORKDIR /srv/letsencrypt
RUN ./letsencrypt-auto --help
WORKDIR /

# Install PHPExcel
RUN echo '' >> /etc/php5/fpm/php-fpm.conf
RUN echo 'php_value[include_path] = "/srv/phabricator/PHPExcel/Classes"' >> /etc/php5/fpm/php-fpm.conf

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
ADD server-http.conf /etc/nginx/disabled-server-http.conf
ADD server-https-letsencrypt.conf /etc/nginx/disabled-server-https-letsencrypt.conf
ADD server-https-manual.conf /etc/nginx/disabled-server-https-manual.conf
ADD fastcgi.conf /etc/nginx/fastcgi.conf
ADD 15-https /etc/init.simple/15-https
ADD 25-nginx /etc/init.simple/25-nginx
ADD 25-php-fpm /etc/init.simple/25-php-fpm
ADD 20-postfix /etc/init.simple/20-postfix
ADD 10-boot-conf /etc/init.simple/10-boot-conf
ADD 35-phd /etc/init.simple/35-phd
ADD 40-aphlict /etc/init.simple/40-aphlict
ADD 50-cronie /etc/init.simple/50-cronie
ADD php-fpm.conf /etc/php5/fpm/php-fpm.conf
ADD php.ini /etc/php5/fpm/php.ini

# [chmod] init scripts
RUN chmod -R 755 /etc/init.simple

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
