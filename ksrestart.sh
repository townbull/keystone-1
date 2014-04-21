#!/bin/bash

pid=$(pgrep -f keystone-all)
sudo kill $pid

/opt/stack/keystone/bin/keystone-all \
    --config-file /etc/keystone/keystone.conf \
    --log-config /etc/keystone/logging.conf -d --debug & 
echo $! >"/opt/stack/status/stack/key.pid"
cat "/opt/stack/status/stack/key.pid"

echo "done"
