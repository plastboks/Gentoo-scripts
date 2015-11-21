#!/bin/bash

PATH="https://raw.githubusercontent.com/plastboks/gentoo-scripts/master"
LATEST=`curl -s $PATH/"config/latest.txt" | tail -n 1 | awk '$0=$1'`
LIST=(
    "prechroot.sh"
    "chroot.sh"
)

for elem in "${LIST[@]}"; do
    /usr/bin/wget $PATH/$elem
    /bin/chmod +x $elem
done

/usr/bin/wget $PATH/"config/$LATEST"
mv $LATEST .config
