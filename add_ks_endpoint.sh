#!/bin/bash

if [ $# -ne 1 ]
then
    echo "Usage: $0 <KS IP Address>"
    exit -1
fi

source ~/devstack/openrc admin admin
SVCID=$(openstack service list | grep keystone | cut -d'|' -f2 | \
  sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
keystone --os-user admin endpoint-create --region=RegionOne \
    --publicurl=http://$1:5000/v3 \
    --internalurl=http://$1:5000/v3 \
    --adminurl=http://$1:35357/v3 --service-id=$SVCID

exit 0
