#!/bin/bash

set -x

source /config.saved

if [ "$SSL_TYPE" == "letsencrypt" ]; then
  while [ 0 -eq 0 ]; do
    if [ "$SSL_DOMAINS" != "" ]; then
      /srv/letsencrypt/letsencrypt-auto certonly --text --non-interactive --keep --debug  --agree-tos --webroot -w /srv/letsencrypt-webroot --email $SSL_EMAIL -d $PHABRICATOR_HOST,$SSL_DOMAINS
      if [ -f /config/letsencrypt/live/$PHABRICATOR_HOST ]; then
        break
      fi
      if [ $? -ne 0 ]; then
        sleep 10
        continue
      fi
    elif [ "$PHABRICATOR_CDN" != "" ]; then
      /srv/letsencrypt/letsencrypt-auto certonly --text --non-interactive --keep --debug  --agree-tos --webroot -w /srv/letsencrypt-webroot --email $SSL_EMAIL -d $PHABRICATOR_HOST,$PHABRICATOR_CDN
      if [ -f /config/letsencrypt/live/$PHABRICATOR_HOST ]; then
        break
      fi
      if [ $? -ne 0 ]; then
        sleep 10
        continue
      fi
    else
      /srv/letsencrypt/letsencrypt-auto certonly --text --non-interactive --keep --debug  --agree-tos --webroot -w /srv/letsencrypt-webroot --email $SSL_EMAIL -d $PHABRICATOR_HOST
      if [ -f /config/letsencrypt/live/$PHABRICATOR_HOST ]; then
        break
      fi
      if [ $? -ne 0 ]; then
        sleep 10
        continue
      fi
    fi
    break
  done

  rm /config/letsencrypt/installed
  ln -s /config/letsencrypt/live/$PHABRICATOR_HOST /config/letsencrypt/installed

  if [ -e $SCRIPT_AFTER_LETS_ENCRYPT ]; then
    echo "Applying post-letsencrypt script..."
    $SCRIPT_AFTER_LETS_ENCRYPT
  fi

  echo "Reloading nginx..."
  /usr/sbin/nginx -t -c /app/nginx.ssl.conf && /usr/sbin/nginx -t -c /app/nginx.conf && /usr/sbin/nginx -s reload
fi
