#!/bin/bash

# Source configuration
source /config.saved

if [ "$DISABLE_IOMONITOR" != "true" ]; then
  if [ ! -f /is-baking ]; then
    # Run IO monitor
    /opt/iomonitor/iomonitor
  else
    while [ 0 -eq 0 ]; do
      sleep 10000
    done
  fi
else
  while [ 0 -eq 0 ]; do
    sleep 10000
  done
fi