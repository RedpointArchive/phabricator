#!/bin/bash

set -e
set -x

# Move preflight files to their locations
mkdir /app
mkdir /app/startup
cd /preflight

mv nginx.conf /app/nginx.conf
mv nginx.ssl.conf /app/nginx.ssl.conf
mv server-https-letsencrypt.conf /app/disabled-server-https-letsencrypt.conf
mv server-https-manual.conf /app/disabled-server-https-manual.conf

mv fastcgi.conf /app/fastcgi.conf

mv run-phd.sh /app/run-phd.sh
mv run-ssh.sh /app/run-ssh.sh
mv run-aphlict.sh /app/run-aphlict.sh
mv run-iomonitor.sh /app/run-iomonitor.sh
mv run-postfix.sh /app/run-postfix.sh

mv letsencrypt.sh /app/letsencrypt.sh

mv 10-boot-conf /app/startup/10-boot-conf
mv 15-https-conf /app/startup/15-https-conf

mv php-fpm.conf /etc/php5/fpm/php-fpm.conf.template
mv php.ini /etc/php5/fpm/php.ini

mv supervisord.conf /app/supervisord.conf
mv init.sh /app/init.sh

mkdir -pv /run/watch
mkdir /etc/phabricator-ssh
mv sshd_config.phabricator /etc/phabricator-ssh/sshd_config.phabricator.template
mv phabricator-ssh-hook.sh /etc/phabricator-ssh/phabricator-ssh-hook.sh.template
mv bake /bake
mkdir /opt/iomonitor
mv iomonitor /opt/iomonitor
rm setup.sh
cd /
ls /preflight
rmdir /preflight # This should now be empty; it's an error if it's not.

# Install PHPExcel
echo '' >> /etc/php5/fpm/php-fpm.conf
echo 'php_value[include_path] = "/srv/phabricator/PHPExcel/Classes"' >> /etc/php5/fpm/php-fpm.conf

# Move the default SSH to port 24
echo "" >> /etc/ssh/sshd_config
echo "Port 24" >> /etc/ssh/sshd_config

# Configure Phabricator SSH service
chown root:root /etc/phabricator-ssh/*

# Workaround for https://gist.github.com/porjo/35ea98cb64553c0c718a
chmod u+s /usr/sbin/postdrop
chmod u+s /usr/sbin/postqueue

