#!/bin/sh
# This script is used to update an entry in the rs_config collection within the slserver/cslserver to the new shard location.
# Author: bgoff
# Since : 24 Nov 2024
 
echo "Which shard id to update (shardrs01, shardrs02, ...):"
read shardrsToUpdate

echo "Where is the new shard (shard04.v1iva.mongodb.net, ...):"
read shardLocation

echo "enter colleciton to update (slserver, cslserver):"
read database

echo "srv destination servers (<machine>):"
read destSource

stty -echo
printf "Destination mongosync Password: "
read destPassword
stty echo
printf "\n"

cmd="db.rs_config.updateOne({\"_id\": \"$shardrsToUpdate\" },{ \\\$set : {\"db_config.host\": \"$shardLocation\" }})"

echo $cmd

dest="mongodb+srv://mongosync:"$destPassword"@"$destSource"/"$database

echo $dest

mongosh $dest << EOF
$cmd
EOF
