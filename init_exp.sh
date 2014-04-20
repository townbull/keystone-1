#!/bin/bash

source switchenv admin

TOTALDOMAIN=10
TOTALUSERINADOMAIN=10
TOTALPROJINADOMAIN=10

if [ $# -ne 1 ]
then
    echo "USAGE: $0 -[r|d|u|a]"
    exit -1
fi

if [ $1 == "-r" ]
then
    RCOUNTER=0
    # creating roles
    while [ $RCOUNTER -lt 10 ]
    do
        openstack role create "r$RCOUNTER"
        echo "r$RCOUNTER created."
        RCOUNTER=`expr $RCOUNTER + 1`
    done
    echo "Successfully added $RCOUNTER roles."
    exit 0
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

    if [ $1 == "-d" ]
    then
        openstack domain create "d$DOMAIN"
        echo "d$DOMAIN created."
    fi
    DID=$(openstack domain show "d$DOMAIN" | grep id | cut -d"|" -f3 | \
        sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
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
    
    NEXTDID=$(openstack domain show "d$NEXTDOMAIN" | grep id | cut -d"|" -f3 | \
        sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # Add Domain Trust (PAT--Type gamma trust) NEXTDOMAIN trusts DOMAIN in MySQL DB
    if [ $1 == "-t" ]
    then
        /usr/bin/mysql -A -e "use keystone; insert into domain_trust \
        (trustor_domain_id, trustee_domain_id, extra) value ('$NEXTDID','$DID','{}');"
        echo "d$NEXTDOMAIN trusts d$DOMAIN is added."
        DCOUNTER=`expr $DCOUNTER + 1`
        continue
    fi

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
        
        if [ $1 == "-u" ]
        then
            openstack user create --domain "d$DOMAIN" --password "admin" "$USER"
            openstack user set --password "admin" "$USER"
            openstack project create --domain "d$DOMAIN" "$PROJ"
            echo "ADDED: $USER $PROJ in d$DOMAIN (id=$DID)"
        fi

        if [ $1 == "-a" ]
        then
            # Assign userx to rolex in projectx
            openstack role add --user "$USER" --project "$PROJ" "r$UPCOUNTER"
            echo "$USER is assigned to r$UPCOUNTER in $PROJ"
        fi

        if [ $1 == "-c" ]
        then
            # Assign userx to rolex in projectx of the next domain
            openstack role add --user "$USER" --project "$CPROJ" "r$UPCOUNTER"
            echo "$USER is assigned to r$UPCOUNTER in $CPROJ"
        fi
        
        UPCOUNTER=`expr $UPCOUNTER + 1`

    done

    DCOUNTER=`expr $DCOUNTER + 1`

done

case $1 in
    "-d") echo "Successfully added $DCOUNTER domains";;
    "-t") echo "Successfully added domain trust relations for $DCOUNTER domains";;
    "-u") echo "Successfully added users and projects in $DCOUNTER domains";;
    "-a") echo "Successfully added roles in $DCOUNTER domains";;
    "-c") echo "Successfully added cross-domain roles in $DCOUNTER domains";;
esac
    
exit 0
