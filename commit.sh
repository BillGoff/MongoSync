#!/bin/sh

printf "enter port to connect to Mongo Sync At:  "
read mongoSyncPort

echo "committing "$mongoSyncPort

curl localhost:$mongoSyncPort/api/v1/commit -XPOST --data '{ }'