#!/bin/bash


# Keystone servers with capability of 2 to the power of each number
KS0="10.245.122.97"
KS1="10.245.122.98"
KS2="10.245.122.99"
KS3="10.245.123.32"
KS4="10.245.123.54"

# Database server for experiment result storage
HOST="10.245.122.14"
DB="osacdt2"

ksx=$1

    ext=10
    while [ $ext -ge 1 ]
    do
        # execute intra-domain experiment
        /opt/stack/keystone/run_exp_seq.sh $ksx -i $ext
	echo "Result of $ksx-I$ext-xx sent to $HOST:$DB." 
        
        # execute cross-domain experiment
        /opt/stack/keystone/run_exp_seq.sh $ksx -c $ext
	echo "Result of $ksx-C$ext-xx sent to $HOST:$DB." 
        ext=`expr $ext - 1`
    done

echo "Batch teses ends at: $(date +%Y%m%d-%T)"
exit 0
