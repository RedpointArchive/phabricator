#!/bin/bash

set -e
set -x

# Add repositories
zypper --non-interactive ar http://download.opensuse.org/repositories/devel:/languages:/php/openSUSE_Leap_42.1/ php
zypper --non-interactive ar http://download.opensuse.org/repositories/home:/marec2000:/nodejs/openSUSE_Leap_42.1/ nodejs
zypper --non-interactive ar http://download.opensuse.org/repositories/devel:/tools:/scm/openSUSE_Leap_42.1/ scm

# Install requirements
zypper --gpg-auto-import-keys --non-interactive in --force-resolution nginx php-fpm php5-mbstring php5-mysql php5-curl php5-pcntl php5-gd php5-openssl php5-ldap php5-fileinfo php5-posix php5-json php5-iconv php5-ctype php5-zip php5-sockets which python-Pygments nodejs ca-certificates ca-certificates-mozilla ca-certificates-cacert sudo subversion mercurial php5-xmlwriter nodejs-ws git php5-opcache ImageMagick postfix glibc-locale

# Build and install APCu
zypper --non-interactive install --force-resolution autoconf automake binutils cpp cpp48 gcc gcc48 glibc-devel libasan0 libatomic1 libcloog-isl4 libgomp1 libisl10 libitm1 libltdl7 libmpc3 libmpfr4 libpcre16-0 libpcrecpp0 libpcreposix0 libstdc++-devel libstdc++48-devel libtool libtsan0 libxml2-devel libxml2-tools linux-glibc-devel m4 make ncurses-devel pcre-devel php5-devel php5-pear php5-zlib pkg-config readline-devel tack xz-devel zlib-devel
printf "\n" | pecl install apcu-4.0.10
#zypper --non-interactive remove --force-resolution autoconf automake binutils cpp cpp48 gcc gcc48 glibc-devel libasan0 libatomic1 libcloog-isl4 libgomp1 libisl10 libitm1 libltdl7 libmpc3 libmpfr4 libpcre16-0 libpcrecpp0 libpcreposix0 libstdc++-devel libstdc++48-devel libtool libtsan0 libxml2-devel libxml2-tools linux-glibc-devel m4 ncurses-devel pcre-devel php5-devel php5-pear pkg-config readline-devel tack xz-devel zlib-devel

# Remove cached things that pecl left in /tmp/
rm -rf /tmp/*

# Install a few extra things
zypper --non-interactive install --force-resolution mariadb-client vim vim-data

# Force reinstall cronie
zypper --non-interactive install -f cronie

# Move preflight files to their locations
cd /preflight
mv nginx.conf /etc/nginx/nginx.conf
mv server-http.conf /etc/nginx/disabled-server-http.conf
mv server-https-letsencrypt.conf /etc/nginx/disabled-server-https-letsencrypt.conf
mv server-https-manual.conf /etc/nginx/disabled-server-https-manual.conf
mv fastcgi.conf /etc/nginx/fastcgi.conf
mkdir /etc/init.simple
mv 15-https /etc/init.simple/15-https
mv 25-nginx /etc/init.simple/25-nginx
mv 25-php-fpm /etc/init.simple/25-php-fpm
mv 20-postfix /etc/init.simple/20-postfix
mv 10-boot-conf /etc/init.simple/10-boot-conf
mv 35-phd /etc/init.simple/35-phd
mv 40-aphlict /etc/init.simple/40-aphlict
mv 50-cronie /etc/init.simple/50-cronie
mv php-fpm.conf /etc/php5/fpm/php-fpm.conf
mv php.ini /etc/php5/fpm/php.ini
mkdir /etc/phabricator-ssh
mv sshd_config.phabricator /etc/phabricator-ssh/sshd_config.phabricator
mv 45-phabricator-ssh /etc/init.simple/45-phabricator-ssh
mv phabricator-ssh-hook.sh /etc/phabricator-ssh/phabricator-ssh-hook.sh
mv bake /bake
rm setup.sh
cd /
rmdir /preflight # This should now be empty; it's an error if it's not.

# Create users and groups
echo "nginx:x:497:495:user for nginx:/var/lib/nginx:/bin/false" >> /etc/passwd
echo "nginx:!:495:" >> /etc/group
echo "git:x:2000:2000:user for phabricator:/srv/phabricator:/bin/bash" >> /etc/passwd
echo "wwwgrp-phabricator:!:2000:nginx" >> /etc/group

# Set up the Phabricator code base
mkdir /srv/phabricator
chown git:wwwgrp-phabricator /srv/phabricator
cd /srv/phabricator
sudo -u git git clone https://www.github.com/phacility/libphutil.git /srv/phabricator/libphutil
sudo -u git git clone https://www.github.com/phacility/arcanist.git /srv/phabricator/arcanist
sudo -u git git clone https://www.github.com/phacility/phabricator.git /srv/phabricator/phabricator
sudo -u git git clone https://www.github.com/PHPOffice/PHPExcel.git /srv/phabricator/PHPExcel
cd /

# Clone Let's Encrypt
git clone https://github.com/letsencrypt/letsencrypt /srv/letsencrypt
cd /srv/letsencrypt
./letsencrypt-auto-source/letsencrypt-auto --help
cd /

# Install PHPExcel
echo '' >> /etc/php5/fpm/php-fpm.conf
echo 'php_value[include_path] = "/srv/phabricator/PHPExcel/Classes"' >> /etc/php5/fpm/php-fpm.conf

# [chmod] init scripts
chmod -R 755 /etc/init.simple

# Move the default SSH to port 24
echo "" >> /etc/ssh/sshd_config
echo "Port 24" >> /etc/ssh/sshd_config

# Configure Phabricator SSH service
chown root:root /etc/phabricator-ssh/*

# Workaround for https://gist.github.com/porjo/35ea98cb64553c0c718a
chmod u+s /usr/sbin/postdrop
chmod u+s /usr/sbin/postqueue

