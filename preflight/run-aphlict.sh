#!/bin/bash

set -e
set -x

# Source configuration
source /config.saved

if [ ! -f /baked ]; then
  # Touch log file and PID file to make sure they're writable
  touch /var/log/aphlict.log
  chown "$PHABRICATOR_VCS_USER:wwwgrp-phabricator" /var/log/aphlict.log

  # Copy ws module from global install
  cp -Rv /usr/lib/node_modules /srv/phabricator/phabricator/support/aphlict/server/
  chown -Rv "$PHABRICATOR_VCS_USER:wwwgrp-phabricator" /srv/phabricator/phabricator/support/aphlict/server/node_modules

  # Configure the Phabricator notification server
  cat >/srv/aphlict.conf <<EOF
{
  "servers": [
    {
      "type": "client",
      "port": 22280,
      "listen": "127.0.0.1",
      "ssl.key": null,
      "ssl.cert": null,
      "ssl.chain": null
    },
    {
      "type": "admin",
      "port": 22281,
      "listen": "127.0.0.1",
      "ssl.key": null,
      "ssl.cert": null,
      "ssl.chain": null
    }
  ],
  "logs": [
    {
      "path": "/dev/stdout"
    }
  ],
  "pidfile": "/run/watch/aphlict"
}
EOF

  # Aphlict needs write access to this directory
  chmod a+rwX /run/watch
fi

if [ ! -f /is-baking ]; then
  # Start the Phabricator notification server
  pushd /srv/phabricator/phabricator
  sudo -u "$PHABRICATOR_VCS_USER" bin/aphlict start --config=/srv/aphlict.conf
  popd

  set +e
  set +x

  PIDFILE=/run/watch/aphlict

  COUNT=0
  while [ ! -f $PIDFILE ]; do
    echo "Waiting for $PIDFILE to appear..."
    sleep 1
    COUNT=$[$COUNT+1]
    if [ $COUNT -gt 60 ]; then
      exit 1
    fi
  done

  PID=$(cat $PIDFILE)
  while s=`ps -p $PID -o s=` && [[ "$s" && "$s" != 'Z' ]]; do
    sleep 1
  done

  exit 0
fi
