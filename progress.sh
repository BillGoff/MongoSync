#!/bin/sh

printf "enter port to connect to Mongo Sync At:  "
read mongoSyncPort

echo "Getting Progress from "$mongoSyncPort
curl localhost:$mongoSyncPort/api/v1/progress