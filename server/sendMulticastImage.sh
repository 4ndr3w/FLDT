#!/bin/sh

IMAGE_NAME="$1"

if [ "$1" = "" ]; then
	echo "Usage: sendMulticastImage.sh IMAGE_NAME"
	exit
fi

for f in `find /images/$IMAGE_NAME/sd* -type f | sort -nr`
do
	echo "Starting multicast for $f"
	udp-sender < $f
done
