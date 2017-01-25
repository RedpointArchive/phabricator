#!/bin/bash

set -e
set -x

source /config.saved

if [ "$SSL_TYPE" == "letsencrypt" ]; then
  if [ "$PHABRICATOR_CDN" != "" ]; then
    /srv/letsencrypt/letsencrypt-auto certonly --text --non-interactive --keep --debug --agree-tos --webroot -w /srv/letsencrypt-webroot --email $SSL_EMAIL -d $PHABRICATOR_HOST,$PHABRICATOR_CDN
  else
    /srv/letsencrypt/letsencrypt-auto certonly --text --non-interactive --keep --debug --agree-tos --webroot -w /srv/letsencrypt-webroot --email $SSL_EMAIL -d $PHABRICATOR_HOST
  fi

  rm /config/letsencrypt/installed
  ln -s /config/letsencrypt/live/$PHABRICATOR_HOST /config/letsencrypt/installed

  if [ -e $SCRIPT_AFTER_LETS_ENCRYPT ]; then
    echo "Applying post-letsencrypt script..."
    $SCRIPT_AFTER_LETS_ENCRYPT
  fi

  echo "Reloading nginx..."
  /usr/local/nginx/sbin/nginx -t && /usr/local/nginx/sbin/nginx -s reload
fi