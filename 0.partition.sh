#!/bin/bash

# A simple Gentoo partition script.

FS="ext4"
BOOT_PART="/dev/disk/by-partlabel/boot"
LVM_PART="/dev/disk/by-partlabel/gentoodisk"
LVM_SWAP="/dev/mapper/gentoo-swap"
LVM_ROOT="/dev/mapper/gentoo-root"
LVM_HOME="/dev/mapper/gentoo-home"

while test $# -gt 0; do
  OPTION=$1
  shift

  case "$OPTION" in
    --btrfs)
      FS="btrfs"
      FS_OPTIONS="defaults,noatime"
      FS_SSD_OPTIONS="discard,ssd"
      ;;
    --luks)
      USE_LUKS=1
      ;;
    -*)
      echo "Unrecognized option $OPTION"
      exit
      ;;
    *)
      DEVICE=$OPTION
      ;;
  esac
done

if [ "x$DEVICE" = "x" ]; then
  echo "Usage: $0 <options> <device>"
  cat<<"EOF"

A simple Gentoo partition script

  --btrfs                  Use BTRFS as root filesystem (Default ext4)
  --luks                   Enable LUKS encryption (Default off)

EOF
  exit
fi

umount /mnt/gentoo/boot
umount /mnt/gentoo/home
umount /mnt/gentoo
vgremove -f gentoo

# -- Partitioning

sgdisk $DEVICE --attributes=1:set:2 # GPT
sgdisk -o \
    -n 1:0:+2M -t l:ef02 -c 1:bios \
    -n 2:0:+128M -c 2:boot \
    -N=3 -c 3:gentoodisk \
    -p $DEVICE

sleep 2

# -- LUKS

if [ "x$USE_LUKS" != "x" ]; then
  LUKS_PART=$LVM_PART
  LVM_PART="/dev/mapper/crypt"

  cryptsetup \
    --cipher aes-xts-plain64 \
    --key-size 512 \
    --hash sha512 \
    --iter-time 5000 \
    --verify-passphrase \
    luksFormat $LUKS_PART

  cryptsetup \
    luksOpen $LUKS_PART crypt
fi

# -- LVM

pvcreate $LVM_PART
vgcreate gentoo $LVM_PART
lvcreate --name swap --size 2048M gentoo
lvcreate --name root --extents 35%FREE gentoo
lvcreate --name home --extents 100%FREE gentoo

# -- Filesystems

printf "=> Making swap part: \n" $LVM_SWAP
mkswap $LVM_SWAP

printf "=> Making boot part: \n" $BOOT_PART
mkfs.ext2 $BOOT_PART

printf "=> Making root part: \n" $LVM_ROOT
mkfs.$FS $LVM_ROOT

printf "=> Making home part: \n" $LVM_HOME
mkfs.$FS $LVM_HOME

# -- Mount

swapon $LVM_SWAP
mount $LVM_ROOT /mnt/gentoo
mkdir /mnt/gentoo/boot
mount $BOOT_PART /mnt/gentoo/boot
mkdir /mnt/gentoo/home
mount $LVM_HOME /mnt/gentoo/home
