#!/bin/sh

HOSTNAME=`cat /hostname`

hdparm -z /dev/sda
mdev -s

mkdir mnt
mount /dev/sda1 mnt
mount -t sysfs sys mnt/sys
mount -t proc proc mnt/proc
cp -R /dev/* mnt/dev

cp /doInChroot.sh mnt
chroot mnt sh /doInChroot.sh $HOSTNAME
rm mnt/doInChroot.sh

umount mnt/sys
umount mnt/proc
umount mnt

echo "Done post-image tasks"
