#!/bin/bash

BUILD="latest-stage3-amd64.txt"
SERVER="http://trumpetti.atm.tut.fi/gentoo/releases/amd64/autobuilds"
LATEST=`curl -s $SERVER/$BUILD | tail -n 1 | awk '$0=$1'`

cd /mnt/gentoo

wget $SERVER/$LATEST

tar xvjpf stage3-*.tar.bz2 --xattrs
