#!/bin/bash

set -e
set -x

/app/startup/10-boot-conf
/app/startup/15-https-conf

supervisord -c /app/supervisord.conf

