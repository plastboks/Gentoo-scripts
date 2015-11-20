#!/bin/bash

# A simple Gentoo partition script.

FS="ext4"
BOOT_PART="/dev/disk/by-partlabel/boot"
SWAP_PART="/dev/disk/by-partlabel/swap"
LVM_PART="/dev/disk/by-partlabel/gentoodisk"
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
    -n 3:0:+2048M -c 3:swap -t l:swap \
    -N=4 -c 4:gentoodisk \
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
lvcreate --name root --extents 20%FREE gentoo
lvcreate --name home --extents 100%FREE gentoo

# -- Filesystems

mkfs.ext2 $BOOT_PART
mkfs.$FS $ROOT_PART
mkfs.$FS $HOME_PART
mkswap $SWAP_PART

# -- Mount

swapon $SWAP_PART
mount $LVM_ROOT /mnt/gentoo
mkdir /mnt/gentoo/boot
mount $BOOT_PART /mnt/gentoo/boot
mkdir /mnt/gentoo/home
mount $LVM_HOME /mnt/gentoo/home
