#!/bin/bash

set -e
set -x

export SYSTEMD_NO_WRAP=true
/etc/init.d/postfix start
PIDFILE=/var/spool/postfix/pid/master.pid

set +e
set +x

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