#!/bin/bash


# set variables
DIRECTORY=$1
YOURIP=$2
SCANRANGE=$3


echo "."
echo "Locating directory"
echo "."

# check for directory
if [ ! -d "$DIRECTORY" ]; then echo "Error: Directory not found"; exit 0; fi

# checking if the hostips file is already populated
if [ -f "$DIRECTORY/hostips" ]; then echo "Error: hostips file already exists"; exit 0; fi

# run initial nmap scan
echo "Starting host ip detection"
echo "."
nmap -sn -n --exclude $YOURIP $SCANRANGE > $DIRECTORY/temp12345

# pull out IPs and add them to the hostips file
echo "Writing ips to $DIRECTORY/hostips"
cat $DIRECTORY/temp12345 | grep -E -o '(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)' > $DIRECTORY/hostips 

# clean up temp file
echo "."
echo "Cleaning up temp file"
rm -f $DIRECTORY/temp12345

# initialize the file system
echo "."
echo "Initializing the file system"
for HOST in `cat   $DIRECTORY/hostips`; do mkdir $DIRECTORY/$HOST; mkdir $DIRECTORY/$HOST/nmap; done


# get architectures
echo "."
echo "Getting host Architectures"
for HOST in `cat $DIRECTORY/hostips`; do echo "."; echo "Getting architecture for $HOST"; getArch.py -target $HOST > $DIRECTORY/$HOST/arch$HOST; echo "     Done"; done

# beginning enum4linux
echo "."
for HOST in `cat $DIRECTORY/hostips`; do echo "Beginning enum4linux on $HOST"; echo "."; enum4linux -a $HOST > $DIRECTORY/$HOST/enum4linux$HOST; echo "."; echo "Enum4linux completed for $HOST"; echo "."; done

# use smbclient
#echo "."
#for HOST in `cat $DIRECTORY/hostips`; do echo "Running smbclient on $HOST"; echo "."; smbclient -L $HOST > $DIRECTORY/$HOST/smbclient$HOST; echo "."; echo "Finished running smbclient on $HOST"; echo "."; done

# use smbclient.py
#echo "."
#for HOST in `cat $DIRECTORY/hostips`; do echo "Running smbclient.py on $HOST"; echo "."; smbclient.py $HOST > $DIRECTORY/$HOST/smbclientpy$HOST; echo "."; echo "Finished running smbclient.py on $HOST"; echo "."; done

# use samrdump.py
echo "."
for HOST in `cat $DIRECTORY/hostips`; do echo "Running samrdump.py on $HOST to ask for username list"; echo "."; samrdump.py -debug $HOST > $DIRECTORY/$HOST/samrdumppy$HOST; echo "."; echo "Finished asking for username list on $HOST"; echo "."; done

# use lookupsid.py
echo "."
for HOST in `cat $DIRECTORY/hostips`; do echo "Running lookupsid.py on $HOST to bruteforce usernames"; echo "."; lookupsid.py $HOST > $DIRECTORY/$HOST/lookupsid.py$HOST; echo "."; echo "Finished bruteforcing usernames on $HOST"; echo "."; done

# beginning agressive scanning
echo "Beginning aggressive scans"
echo "."
for HOST in `cat   $DIRECTORY/hostips`; do echo "Beginning agressive scan for $HOST"; echo "."; nmap -sT -A $HOST -oA $DIRECTORY/$HOST/nmap/nmap-A-$HOST; echo "."; echo "Agressive scan completed for $HOST"; done
echo "."
echo "Agressive scans completed"

# bye :)
echo "."
echo "."
echo "."
echo "Done!"
