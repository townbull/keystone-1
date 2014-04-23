#!/bin/bash

TOTALDOMAIN=10
TOTALUSERINADOMAIN=10
TOTALPROJINADOMAIN=10
EXECTIME=1

# Keystone servers with capability of 2 to the power of each number
KS0="10.245.122.97"
KS1="10.245.122.98"
KS2="10.245.122.99"
KS3="10.245.123.32"
KS4="10.245.123.54"

# Database server for experiment result storage
DB="10.245.122.14"

if [ $1 == "-a" ]
then
  /usr/bin/mysql -uroot -padmin -h$DB -A -e "create table dt_exp_results \
      (id varchar(16) NOT NULL PRIMARY KEY, Keystone_IP varchar(16) NOT NULL, \
      user_domain_name varchar(16) NOT NULL, user_name varchar(16) NOT NULL, \
      project_domain_name varchar(16) NOT NULL, \
      project_name varchar(16) NOT NULL, resp_time INT);"
  echo "Table dt_exp_results successfully added in DB server: $DB."
  exit 0
fi

if [ $# -gt 3 ] || [ $# -lt 2 ]
then
    echo "USAGE: $0 [-a|<keystone server>] -[c|i] [<exec times>]"
    echo "-a: add table dt_exp_results in DB server: $DB"
    echo "-i: intra-domain requests"
    echo "-c: cross-domain requests"
    exit -1
elif [ $# -eq 3 ]
then
    EXECTIME=$3
fi

KSX="KS$1"
KSX=${!KSX}
echo $KSX
#exit 0

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
        declare -a RESULT
        while [ $EXECCOUNTER -lt $EXECTIME ]
        do
            # Run the requests as subshells in the background
            (
                # Intra-domain request data
                if [ $2 == "-i" ]
                then
                    REQ_DATA="{\"auth\":{\"identity\":{\"methods\":[\"password\"],\"password\":{\"user\":{\"domain\":{\"name\":\"d$DOMAIN\"},\"name\":\"$USER\",\"password\":\"admin\"}}},\"scope\":{\"project\":{\"domain\":{\"name\":\"d$DOMAIN\"},\"name\":\"$PROJ\"}}}}"
                    #echo $'\n==========================='
                    #echo "REQ_DATA: "$REQ_DATA
                    #echo $'==========================='

                    START=$(($(date +%s%N)/1000000))
                    KSTIME=$(curl -si http://$KSX:5000/v3/auth/tokens -X POST \
                    -H "Content-Type: application/json" -H "Accept: application/json" -d \
                    $REQ_DATA | grep "token" | /opt/stack/keystone/jq ".time")
                    END=$(($(date +%s%N)/1000000))
                    TIME=$(($END-$START))
                    /usr/bin/mysql -uroot -padmin -h$DB -A -e "use osacdt;\
                    insert into dt_exp_results2 (id, Keystone_IP, user_domain_name, user_name, project_domain_name, project_name, start_time, end_time, resp_time, kstime) \
                    values (\"$1-I$EXECTIME-$EXECCOUNTER-$DCOUNTER$UPCOUNTER\", \"$KSX\", \"d$DOMAIN\", \"$USER\", \"d$DOMAIN\", \"$PROJ\",\"$START\", \"$END\", \"$TIME\", \"$KSTIME\");"
                fi

                # Cross-domain request data
                if [ $2 == "-c" ]
                then
                    REQ_DATA="{\"auth\":{\"identity\":{\"methods\":[\"password\"],\"password\":{\"user\":{\"domain\":{\"name\":\"d$DOMAIN\"},\"name\":\"$USER\",\"password\":\"admin\"}}},\"scope\":{\"project\":{\"domain\":{\"name\":\"d$NEXTDOMAIN\"},\"name\":\"$CPROJ\"}}}}"
                    #echo $'\n==========================='
                    #echo "CREQ_DATA: $CREQ_DATA"
                    #echo $'==========================='
                    
                    START=$(($(date +%s%N)/1000000))
                    KSTIME=$(curl -si http://$KSX:5000/v3/auth/tokens -X POST \
                    -H "Content-Type: application/json" -H "Accept: application/json" -d \
                    $REQ_DATA | grep "token" | /opt/stack/keystone/jq ".time")
                    END=$(($(date +%s%N)/1000000))
                    TIME=$(($END-$START))
                    /usr/bin/mysql -uroot -padmin -h$DB -A -e "use osacdt;\
                    insert into dt_exp_results2 (id, Keystone_IP, user_domain_name, user_name, project_domain_name, project_name, start_time, end_time, resp_time, kstime) \
                    values (\"$1-C$EXECTIME-$EXECCOUNTER-$DCOUNTER$UPCOUNTER\", \"$KSX\", \"d$DOMAIN\", \"$USER\", \"d$NEXTDOMAIN\", \"$CPROJ\",\"$START\", \"$END\", \"$TIME\", \"$KSTIME\");"
                fi
                
            )&

            EXECCOUNTER=`expr $EXECCOUNTER + 1`
        done

        UPCOUNTER=`expr $UPCOUNTER + 1`
    done

    DCOUNTER=`expr $DCOUNTER + 1`
done

echo "Successfully sent token requests to $KSX for $DCOUNTER domains"
exit 0
