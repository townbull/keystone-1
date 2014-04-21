#!/bin/bash

kill $(cat "/opt/stack/status/stack/key.pid")

/opt/stack/keystone/bin/keystone-all \
    --config-file /etc/keystone/keystone.conf \
    --log-config /etc/keystone/logging.conf -d --debug 2>&1  > /dev/null & 
echo $! >/opt/stack/status/stack/key.pid
