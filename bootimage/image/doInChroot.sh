#!/bin/shs

# Set hostname
echo $1 > /etc/hostname

#Rebuild /etc/hosts
echo "127.0.0.1 localhost" > /etc/hosts
echo "127.0.1.1 $1" >> /etc/hosts
echo "" >> /etc/hosts
echo "::1 ip6-localhost" >> /etc/hosts
echo "fe00::0 ip6-localnet" >> /etc/hosts
echo "ff00::0 ip6-mcastprefix" >> /etc/hosts
echo "ff02::1 ip6-allnodes" >> /etc/hosts
echo "ff02::1 ip6-allrouters" >> /etc/hosts

#Force password change
chage -d 0 andrew

update-grub

exit;
