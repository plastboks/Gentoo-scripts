#!/bin/bash

# A simple Gentoo partition script.

FS="ext4"
DEVICE=$1
BOOT_PART="/dev/disk/by-partlabel/boot"
SWAP_PART="/dev/disk/by-partlabel/swap"
LVM_PART="/dev/disk/by-partlabel/gentdsk"
CRYPT_NAME="crypt"

sgdisk $DEVICE --attributes=1:set:2 # GPT
sgdisk -o \
    -n 1:0:+32M -t l:ef02 -c 1:bios \
    -n 2:0:+512M -c 2:boot \
    -n 3:0:+2048M -c 3:swap -t l:swap \
    -N=4 -c 4:gentdsk \
    -p $DEVICE

sleep 2

cryptsetup \
    --cipher aes-xts-plain64 \
    --key-size 512 \
    --hash sha512 \
    --iter-time 5000 \
    --verify-passphrase \
    luksFormat $LVM_PART

cryptsetup luksOpen $LVM_PART $CRYPT_NAME

pvcreate /dev/mapper/$CRYPT_NAME
vgcreate gentoo /dev/mapper/$CRYPT_NAME
lvcreate --name root --extents 20%FREE gentoo
lvcreate --name home --extents 100%FREE gentoo

LVM_ROOT="/dev/mapper/gentoo-root"
LVM_HOME="/dev/mapper/gentoo-home"

mkfs.ext2 $BOOT_PART
mkfs.$FS $LVM_ROOT
mkfs.$FS $LVM_HOME

mkswap $SWAP_PART
swapon $SWAP_PART
mount $LVM_ROOT /mnt/gentoo
mkdir /mnt/gentoo/boot
mount $BOOT_PART /mnt/gentoo/boot
mkdir /mnt/gentoo/home
mount $LVM_HOME /mnt/gentoo/home

