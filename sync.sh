#!/bin/sh
# This script is used to start the MongoSync.  You will need to supply the port and the older verions flag.

printf "enter port to connect to Mongo Sync At:  "
read mongoSyncPort

echo "Support Older Versions (Use if running mongoSync on MongoDB 5 or below), yes [1], no [2]: "
read supportOlderVersions


echo "Syncing using "$mongoSyncPort
if [ $supportOlderVersions == 'yes' ] || [ $supportOlderVersions == '1' ]; then
	curl localhost:$mongoSyncPort/api/v1/start -XPOST --data '{ "source": "cluster0", "destination" : "cluster1", "supportOlderVersions": true }'

elif [ $supportOlderVersions == 'no' ] || [ $supportOlderVersions == '2' ]; then
	curl localhost:$mongoSyncPort/api/v1/start -XPOST --data '{ "source": "cluster0", "destination" : "cluster1" }'

else
	echo 'Unable to determine if you want to support older versions!'
	exit 2
fi
