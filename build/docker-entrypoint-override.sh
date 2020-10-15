#!/bin/sh

# Exit immediately if a command error or non-zero return occurs.
set -e

# Read haproxy.cfg content from HAPROXY_CFG environment variable
if [ ! -z "$HAPROXY_CONFIG" ]; then
  printf "%s" "$HAPROXY_CONFIG" | tee /usr/local/etc/haproxy/ecs_haproxy.cfg
fi

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- haproxy "$@"
fi

if [ "$1" = 'haproxy' ]; then
	shift # "haproxy"
	# if the user wants "haproxy", let's add a couple useful flags
	#   -W  -- "master-worker mode" (similar to the old "haproxy-systemd-wrapper"; allows for reload via "SIGUSR2")
	#   -db -- disables background mode
	set -- haproxy -db "$@" # removed -W 
fi

exec "$@"