#!/bin/sh

cd image
chmod 777 init
rm ../images/*
rm -r support
cp -R ../support .

for FILE in `find ../scripts -type f`
do
	BASEFILE=`basename $FILE`
	echo "Building $BASEFILE.img"
	cp $FILE image.sh
	chmod 777 image.sh
	find . | cpio -o -H newc | gzip -fc > ../images/$BASEFILE.img
	echo "Done"
done

echo "All images created"
