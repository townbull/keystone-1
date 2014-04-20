#!/bin/bash

TOTALDOMAIN=10
TOTALUSERINADOMAIN=10
TOTALPROJINADOMAIN=10
EXECTIME=1

if [ $# -gt 3 ] || [ $# -lt 2 ]
then
    echo "USAGE: $0 <keystone server> -[c|i] [<exec times>]"
    echo "-i: intra-domain requests"
    echo "-c: cross-domain requests"
    exit -1
elif [ $# -eq 3 ]
then
    EXECTIME=$3
fi

DCOUNTER=0
# outer while loop creating domains
while [ $DCOUNTER -lt $TOTALDOMAIN ]
do

    if [ $DCOUNTER -lt 10 ]
    then
        DOMAIN="0$DCOUNTER"
    elif [ $DCOUNTER -lt 100 ]
    then
        DOMAIN="$DCOUNTER"
    else
        echo "DCounter overflow!"
        exit -1
    fi

    #DID=$(openstack domain show "d$DOMAIN" | grep id | cut -d"|" -f3 | \
    #    sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    #echo $DID
    #DCOUNTER=`expr $DCOUNTER + 1`
    #continue

    NEXTDOMAIN=$(echo "($DCOUNTER+1) % $TOTALDOMAIN" | bc)
    if [ $NEXTDOMAIN -lt 10 ]
    then
        NEXTDOMAIN="0$NEXTDOMAIN"
    fi
    #echo "$NEXTDOMAIN"
    #break
    
    #NEXTDID=$(openstack domain show "d$NEXTDOMAIN" | grep id | cut -d"|" -f3 | \
    #    sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    UPCOUNTER=0

    # inner while loop creating users and projects
    while [ $UPCOUNTER -lt $TOTALUSERINADOMAIN ]
    do
        
        if [ $UPCOUNTER -lt 10 ]
        then
            USER="u$DOMAIN""0$UPCOUNTER"
            PROJ="p$DOMAIN""0$UPCOUNTER"
            # Cross-domain project
            CPROJ="p$NEXTDOMAIN""0$UPCOUNTER"
        elif [ $UPCOUNTER -lt 100 ]
        then
            USER="u$DOMAIN""$UPCOUNTER"
            PROJ="p$DOMAIN""$UPCOUNTER"
            # Cross-domain project
            CPROJ="p$NEXTDOMAIN""$UPCOUNTER"
        else
            echo "UPCounter overflow!"
            break
        fi

        # run curl command for $EXECTIME times
        EXECCOUNTER=0
        while [ $EXECCOUNTER -lt $EXECTIME ]
        do

            # Run the requests as subshells in the background
            (
            # Intra-domain request data
            if [ $2 == "-i" ]
            then
                REQ_DATA="{\"auth\":{\"identity\":{\"methods\":[\"password\"],\"password\":{\"user\":{\"domain\":{\"name\":\"d$DOMAIN\"},\"name\":\"$USER\",\"password\":\"admin\"}}},\"scope\":{\"project\":{\"domain\":{\"name\":\"d$DOMAIN\"},\"name\":\"$PROJ\"}}}}"
                echo $'\n==========================='
                echo "REQ_DATA: "$REQ_DATA
                echo $'==========================='

                curl -si http://$1:5000/v3/auth/tokens -X POST \
                -H "Content-Type: application/json" -H "Accept: application/json" -d \
                $REQ_DATA 2>&1 > /dev/null 
            fi

            # Cross-domain request data
            if [ $2 == "-c" ]
            then
                CREQ_DATA="{\"auth\":{\"identity\":{\"methods\":[\"password\"],\"password\":{\"user\":{\"domain\":{\"name\":\"d$DOMAIN\"},\"name\":\"$USER\",\"password\":\"admin\"}}},\"scope\":{\"project\":{\"domain\":{\"name\":\"d$NEXTDOMAIN\"},\"name\":\"$CPROJ\"}}}}"
                echo $'\n==========================='
                echo "CREQ_DATA: $CREQ_DATA"
                echo $'==========================='
                
                START=$(($(date +%s%N)/1000000))
                curl -si http://$1:5000/v3/auth/tokens -X POST \
                -H "Content-Type: application/json" -H "Accept: application/json" -d \
                $CREQ_DATA 2>&1 > /dev/null
                END=$(($(date +%s%N)/1000000))
                #echo '{"time":5}'
                TIME=$(($END-$START))
                echo '{"time":'$TIME'}'

                fi
            )&

            EXECCOUNTER=`expr $EXECCOUNTER + 1`
        done
               
        UPCOUNTER=`expr $UPCOUNTER + 1`
    done

    DCOUNTER=`expr $DCOUNTER + 1`
done

echo "Successfully sent token requests to $1 for $DCOUNTER domains"
exit 0
