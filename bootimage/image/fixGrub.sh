#!/bin/sh

mount -t devtmpfs none /mnt/dev
mount -t proc proc /mnt/proc
mount -t sysfs sys /mnt/sys

chroot /mnt sh -c "grub-mkdevicemap"
chroot /mnt sh -c "grub-install /dev/sda --force"

umount /mnt/dev
umount /mnt/sys
umount /mnt/proc
