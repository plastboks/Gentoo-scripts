#!/bin/bash

PATH="https://raw.githubusercontent.com/plastboks/gentoo-scripts/master"

LIST=(
    "0.partition.sh"
    "1.stage3.sh"
    "2.install.base.sh"
    "3.chroot.sh"
)

for elem in "${LIST[@]}"; do
    /usr/bin/wget $PATH/$elem
    /bin/chmod +x $elem
done
