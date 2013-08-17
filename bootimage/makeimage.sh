#!/bin/sh

echo "Building initrd.img"
cd image
chmod 777 init
chmod 777 imaging.sh

find . | cpio -o -H newc | gzip -fc > ../initrd.img

echo "Done. Copy initrd.img to your PXE server"
