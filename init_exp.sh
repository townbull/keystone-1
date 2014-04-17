#!/bin/bash

source switchenv admin

COUNTER=0

while :
do
    USER="u"

	if [ $COUNTER -lt 10 ]
	then
	    DOMAIN="d0$COUNTER"
        #USER="u0$COUNTER"
	elif [ $COUNTER -lt 100 ]
	then
	    DOMAIN="d$COUNTER"
	else
	    echo "Counter overflow!"
	    exit -1
	fi
	echo "ADDED: $DOMAIN"
	COUNTER=`expr $COUNTER + 1`
	if [ $COUNTER -eq 100 ]
	then
	    echo "Successfully added 100 domains"
	    exit 0
done