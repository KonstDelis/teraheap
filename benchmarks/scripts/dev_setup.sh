#!/usr/bin/env bash

###################################################
#
# file: dev_setup.sh
#
# @Author:   Iacovos G. Kolokasis
# @Version:  28-03-2021 
# @email:    kolokasis@ics.forth.gr
#
# Prepare the devices for the experiments
#
###################################################

# Device for shuffle
DEVICE_SHFL="nvme1n1"
# Device for TeraCache
DEVICE_TC="nvme2n1p"
# File size for TeraCache
TC_FILE_SZ="800"

# Check if the last command executed succesfully
#
# if executed succesfully, print SUCCEED
# if executed with failures, print FAIL and exit
check () {
    if [ $1 -ne 0 ]
    then
        echo -e "  $2 \e[40G [\e[31;1mFAIL\e[0m]"
        exit
    else
        echo -e "  $2 \e[40G [\e[32;1mSUCCED\e[0m]"
    fi
}

# Print error/usage script message
usage() {
    echo
    echo "Usage:"
    echo -n "      $0 [option ...] [-k][-h]"
    echo
    echo "Options:"
    echo "      -f  Run experiments with fastmap"
    echo "      -d  Unmount devices"
    echo "      -h  Show usage"
    echo

    exit 1
}

destroy() {
	if [ $1 ]
	then
		sudo umount /mnt/spark
		# Check if the command executed succesfully
		retValue=$?
		message="Unmount $DEVICE_SHFL" 
		check ${retValue} "${message}"

		rm -rf /mnt/fmap/file.txt
		# Check if the command executed succesfully
		retValue=$?
		message="Remove TeraCache file" 
		check ${retValue} "${message}"
	fi

}

# Check for the input arguments
while getopts "fdh" opt
do
    case "${opt}" in
		f)
			FASTMAP=true
			;;
		d)
			DESTROY=true
			;;
        h)
            usage
            ;;
        *)
            usage
            ;;
    esac
done

# Unmount TeraCache device
if [ $DESTROY ]
then
	destroy $FASTMAP
	exit
fi

# Setup TeraCache device
if [ $FASTMAP ]
then
	# Setup disk for shuffle
	sudo mount /dev/$DEVICE_SHFL /mnt/spark
	# Check if the command executed succesfully
	retValue=$?
	message="Mount $DEVICE_SHFL for shuffle" 
	check ${retValue} "${message}"

	sudo chown kolokasis /mnt/spark
	# Check if the command executed succesfully
	retValue=$?
	message="Change ownerships /mnt/spark" 
	check ${retValue} "${message}"

	sudo chown kolokasis /mnt/fmap
	# Check if the command executed succesfully
	retValue=$?
	message="Change ownerships /mnt/fmap" 
	check ${retValue} "${message}"

	cd /mnt/fmap

	# if the file does not exist then create it
	if [ ! -f file.txt ]
	then
		fallocate -l ${TC_FILE_SZ}G file.txt
		retValue=$?
		message="Create ${TC_FILE_SZ}G file for TeraCache" 
		check ${retValue} "${message}"
	fi
	cd -
else
	sudo mount /dev/$DEVICE_TC /mnt/spark
	# Check if the command executed succesfully
	retValue=$?
	message="Mount $DEVICE_TC for shuffle and TeraCache" 
	check ${retValue} "${message}"

	sudo chown kolokasis /mnt/spark
	# Check if the command executed succesfully
	retValue=$?
	message="Change ownerships /mnt/spark" 
	check ${retValue} "${message}"

	cd /mnt/spark

	# if the file does not exist then create it
	if [ ! -f file.txt ]
	then
		fallocate -l ${TC_FILE_SZ}G file.txt
		# Check if the command executed succesfully
		retValue=$?
		message="Create ${TC_FILE_SZ}G file for TeraCache" 
		check ${retValue} "${message}"
	fi
	cd -
fi

exit
