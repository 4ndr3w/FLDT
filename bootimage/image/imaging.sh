#!/bin/sh

TARGET_DISK="sda"
HOSTNAME_SERVER="10.0.0.3"

MACADDR=`ifconfig | grep "eth0" | tr -s ' ' | cut -d ' ' -f5`
wget -O hostname http://$HOSTNAME_SERVER/getHostname.php?mac=$MACADDR 2> /dev/null

echo "I am `cat hostname` with MAC address $MACADDR"

echo ""
echo "Imaging of /dev/$TARGET_DISK will start after udp-sender starts broadcasting"

udp-receiver | gunzip -cf | dd of=/dev/$TARGET_DISK bs=1M

echo "Done imaging"

exec sh /doAfterImage.sh $TARGET_DISK $HOSTNAME

