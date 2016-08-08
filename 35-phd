#!/bin/bash

if [ ! -f /is-baking ]; then
  # Reload configuration
  source /config.saved

  if [ "$SCRIPT_BEFORE_DAEMONS" != "" ]; then
    pushd /srv/phabricator/phabricator
    $SCRIPT_BEFORE_DAEMONS
    popd
  fi

  # Start the Phabricator daemons
  pushd /srv/phabricator/phabricator
  sudo -u "$PHABRICATOR_VCS_USER" bin/phd start

  if [ "$SCRIPT_AFTER_DAEMONS" != "" ]; then
    pushd /srv/phabricator/phabricator
    $SCRIPT_AFTER_DAEMONS
    popd
  fi

  popd
fi