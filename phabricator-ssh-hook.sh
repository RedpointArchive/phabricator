#!/bin/sh

# NOTE: Replace this with the username that you expect users to connect with.
VCSUSER="git"

# NOTE: Replace this with the path to your Phabricator directory.
ROOT="/srv/phabricator/phabricator"

if [ "$1" != "$VCSUSER" ];
then
  exit 1
fi

exec "$ROOT/bin/ssh-auth" $@
