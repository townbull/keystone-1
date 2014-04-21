#!/bin/bash

pid=$(pgrep -f keystone-all)
kill $pid

nohup /opt/stack/keystone/bin/keystone-all \
    --config-file /etc/keystone/keystone.conf \
    --log-config /etc/keystone/logging.conf -d --debug 2>&1 > /dev/null & 
echo $! >/opt/stack/status/stack/key.pid
cat /opt/stack/status/stack/key.pid

exit 0
