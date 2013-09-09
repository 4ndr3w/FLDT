#!/bin/sh

HOSTNAME_SERVER="10.0.0.1"

MACADDR=`ifconfig | grep "eth0" | tr -s ' ' | cut -d ' ' -f5`
wget -O hostname http://$HOSTNAME_SERVER/getHostname.php?mac=$MACADDR 2> /dev/null
HOSTNAME="`cat hostname`"

echo "I am $HOSTNAME with MAC address $MACADDR"

echo ""
echo "Restoring partition table"
dd if=/ubermix.mbr.bin of=/dev/sda bs=512 count=1
#Re-read partition table
hdparm -z /dev/sda
mdev -s

echo "Imaging of /dev/sda will start after udp-sender starts broadcasting"
udp-receiver | partclone.extfs -r -s - -o /dev/sda1 -L /partclone.log

mkdir mnt
# Setup mnt enviorment for chroots
mount /dev/sda1 mnt
mount -t sysfs sys mnt/sys
mount -t proc proc mnt/proc
mount --move /dev /mnt/dev


echo "Creating USER partiton"
chroot /mnt sh -c "mke2fs -t ext4 -j -L USER /dev/sda2"
chroot /mnt sh -c "tune2fs -c 0 -i 0 -U e796ba9e-4464-421e-81bd-70e84383cca7 /dev/sda2"

echo "Creating HOME partition"
chroot /mnt sh -c "mke2fs -t ext4 -j -L HOME /dev/sda3 >>/user.log"
chroot /mnt sh -c "tune2fs -c 0 -i 0 -U a507e872-1bd9-4ca1-9f7b-a84b1c145c33 /dev/sda3"

mkdir /homemnt
mount /dev/sda3 /homemnt
cp -a /mnt/home/user /homemnt

echo "Installing GRUB"
chroot /mnt sh -c "grub-mkdevicemap"
chroot /mnt sh -c "grub-install /dev/sda"

chroot /mnt sh -c "chage -d 0 user"


mv /mnt/usr/local/bin/update-hostname /mnt/usr/local/bin/update-hostname.back

# Set hostname
echo "$HOSTNAME" > /mnt/etc/hostname

#Rebuild /etc/hosts
echo "127.0.0.1 localhost" > /mnt/etc/hosts
echo "127.0.1.1 $HOSTNAME" >> /mnt/etc/hosts
echo "" >> /mnt/etc/hosts
echo "::1 ip6-localhost" >> /mnt/etc/hosts
echo "fe00::0 ip6-localnet" >> /mnt/etc/hosts
echo "ff00::0 ip6-mcastprefix" >> /mnt/etc/hosts
echo "ff02::1 ip6-allnodes" >> /mnt/etc/hosts
echo "ff02::1 ip6-allrouters" >> /mnt/etc/hosts

#Turn off autologin
echo "[SeatDefaults]" > /mnt/etc/lightdm/lightdm.conf
echo "greeter-session=unity-greeter" >> /mnt/etc/lightdm/lightdm.conf
echo "user-session=ubuntu-2d" >> /mnt/etc/lightdm/lightdm.conf

# Disable network control panel (proxy settings)
rm -f /mnt/usr/lib/control-center-1/panels/libnetwork.so
rm -f /mnt/usr/share/applications/gnome-network-panel.desktop


umount /mnt/proc
umount /mnt/sys
umount /mnt
umount /homemnt

echo "Done imaging"
