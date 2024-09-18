#!/bin/sh
# This shell script is used to start a MongoSync service.  It will start the service that will sync the source
# to the destination.
# Author:  Bill Goff
# date: 18 Sep 2024

# This function is used to build the standard hosts.  It will take a string of
# comma separated hosts, and append the ports to them.
# Input: 
#		$1:  machine1, machine2, machine3
#		$2:  27017  
# output:
#	machine1:27017,machine2:27017,machine3:27017  
function buildHostsStrings ()
{
	awk_ndx=1
	sh_ndx=0
	while [ 1 -eq 1 ]; do
		source=`echo $1 | awk '{ print $n }' n=$awk_ndx FS=","`
		[ "$source" = "" ] && break
		sources[$sh_ndx]=$source":"$2
		awk_ndx=`expr $awk_ndx + 1`
		sh_ndx=`expr $sh_ndx + 1`
	done

	URLs="$(IFS=,; echo "${sources[*]}")"

	echo $URLs
	#echo all values = ${sources[@]}
	#for a in "${sources[@]}"; do
	#       echo $a
	#done
}

echo "Enter Source User: "
read sourceUser

stty -echo
printf "Source Password: "
read sourcePassword
stty echo
printf "\n"

echo "Enter Destination User: "
read destUser

stty -echo
printf "Destination Password: "
read destPassword
stty echo
printf "\n"

echo "Enter MongoSync Port you wish to use (27182 - 27200): "
read mongoSyncPort

echo "Enter path used to for logging (/home/<user>/mongoSync): "
read logPath

echo "Enter Source URL type (srv [1] or standard [2]):"
read sourceType

echo sourceType
if [ $sourceType == 'srv' ] || [ $sourceType == '1' ]; then
	echo 'source url type is SRV'
	echo "ENTER Sources (<machine>):  "
	read sourceMongoHosts
	sourceMongoHosts=$(tr -d ' ' <<< "$sourceMongoHosts")
	sourceUrl="mongodb+srv://"$sourceUser":"$sourcePassword"@"$sourceMongoHosts"/"

elif [ $sourceType == 'standard' ] || [ $sourceType == '2' ]; then
	echo 'source url type is standard '
	echo "Enter Source port (27017): "
	read sourcePort
	sourcePort=$(tr -d ' ' <<< "$sourcePort")

	echo "ENTER Sources (<machine>,<machine>, ...>):  "
	read sourceMongoHosts
	sourceMongoHosts=$(tr -d ' ' <<< "$sourceMongoHosts")
	sourceMongoHosts=$(buildHostsStrings $sourceMongoHosts $sourcePort)

 	sourceUrl="mongodb://"$sourceUser":"$sourcePassword"@"$sourceMongoHosts"/"
else
	echo 'unable to figure out the source url type '
	exit 2
fi

echo "Enter Destination URL Type  (srv [1] or standard [2]):"
read destType

if [ $destType == 'srv' ] || [ $destType == '1' ]; then
	echo 'destination  url type is SRV'
	echo "ENTER Destinations (<machine>):  "
	read destMongoHosts
	destMongoHosts=$(tr -d ' ' <<< "$destMongoHosts")
	destUrl="mongodb+srv://"$destUser":"$destPassword"@"$destMongoHosts"/"
        
elif [ $destType == 'standard' ] || [ $destType == '2' ]; then
	echo 'destination  url type is standard'
	echo "Enter Destination Port (27017): "
	read destPort
	destPort=$(tr -d ' ' <<< "$destPort")

	echo "ENTER Destinations (<machine>,<machine>, ...>):  "
	read destMongoHosts
	destMongoHosts=$(tr -d ' ' <<< "$destMongoHosts")
	destMongoHosts=$(buildHostsStrings $destMongoHosts $destPort)
	destUrl="mongodb://"$destUser":"$destPassword"@"$destMongoHosts"/"

else
	echo 'unable to figure out the destination url type '
	exit 2
fi

echo "Support Older Versions (Use if running mongoSync on MongoDB 5 or below), yes [1], no [2]: "
read supportOlderVersions

echo "Attempting to sync: "$sourceMongoHosts" to "$destMongoHosts

echo "Starting MongoSync Service on port: "$mongoSyncPort
echo $sourceUrl
echo $destUrl

if [ $supportOlderVersions == 'yes' ] || [ $supportOlderVersions == '1']; then
	echo "MongoSync will support older verisons, starting MongoSync Service on port: " $mongoSyncPort
	mongosync --port $mongoSyncPort --logPath $logPath --verbosity debug --enableFeatures supportOlderVersions --cluster0 $sourceUrl --cluster1 $destUrl
elif [ $supportOlderVersions == 'no' ] || [ $supportOlderVersions == '2']; then
	echo "MongoSync will only support version 6 and above, starting MongoSync Service on port: " $mongoSyncPort
	mongosync --port $mongoSyncPort --logPath $logPath --verbosity debug --cluster0 $sourceUrl --cluster1 $destUrl
else
	echo 'Unable to determine if you want to support older versions!'
	exit 2
fi
