#!/bin/bash

# A simple Gentoo partition script.

FS="ext4"
BOOT_PART="/dev/disk/by-partlabel/boot"
LVM_PART="/dev/disk/by-partlabel/gentoodisk"
LVM_SWAP="/dev/mapper/gentoo-swap"
LVM_ROOT="/dev/mapper/gentoo-root"
LVM_HOME="/dev/mapper/gentoo-home"

BUILD="latest-stage3-amd64.txt"
SERVER="http://trumpetti.atm.tut.fi/gentoo/releases/amd64/autobuilds"
LATEST=`curl -s $SERVER/$BUILD | tail -n 1 | awk '$0=$1'`

USE_LUKS=0

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

if [[ $USE_LUKS -eq 1 ]]; then
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


# - Fetch stage3 file and extract

cd /mnt/gentoo
wget $SERVER/$LATEST
tar xvjpf stage3-*.tar.bz2 --xattrs
rm stage3-*.tar.bz2


# - Setup mirrors

mkdir /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf

#mirrorselect -i -o >> /mnt/gentoo/etc/portage/make.conf
#mirrorselect -i -r -o >> /mnt/gentoo/etc/portage/make.conf

cp -L /etc/resolv.conf /mnt/gentoo/etc/

mount -t proc proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev

rm /dev/shm && mkdir /dev/shm
mount -t tmpfs -o nosuid,nodev,noexec shm /dev/shm
chmod 1777 /dev/shm


# - Copying some files over to chroot env.

ROOT_UUID=`udevadm info --query=all --name=$DEVICE"3" | grep ID_FS_UUID | sed 's//E: ID_FS_UUID/g'`

cat > /mnt/gentoo/root/.exports <<DELIM
FS=$FS
USE_LUKS=$USE_LUKS
LUKS_PART=$LUKS_PART
DEVICE=$DEVICE
ROOT_UUID=$ROOT_UUID
DELIM

cat > /mnt/gentoo/root/.bashrc <<DELIM
source /etc/profile
source ~/.exports
export PS1="[(chroot)]# "
DELIM

cd ~

if [ -f chroot.sh ]; then
    cp chroot.sh /mnt/gentoo/root/
fi
if [ -f .config ]; then
    cp .config /mnt/gentoo/root/
fi


# - Enter chroot

printf "=> Chrooting into /mnt/gentoo \n"
chroot /mnt/gentoo /bin/bash
