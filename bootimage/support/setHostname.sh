#!/bin/sh
if [ "$1" != "" ]
then

	# Set hostname
	echo "$1" > /mnt/etc/hostname

	#Rebuild /etc/hosts
	echo "127.0.0.1 localhost" > /mnt/etc/hosts
	echo "127.0.1.1 $1" >> /mnt/etc/hosts
	echo "" >> /mnt/etc/hosts
	echo "::1 ip6-localhost" >> /mnt/etc/hosts
	echo "fe00::0 ip6-localnet" >> /mnt/etc/hosts
	echo "ff00::0 ip6-mcastprefix" >> /mnt/etc/hosts
	echo "ff02::1 ip6-allnodes" >> /mnt/etc/hosts
	echo "ff02::1 ip6-allrouters" >> /mnt/etc/hosts
	
fi