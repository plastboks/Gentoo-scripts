#!/bin/bash

emerge-webrsync
emerge --sync
emerge vim

echo '#USE="bindist mmx sse sse2 libkms xa X xkb gtk xcb xft dir sqlite apng crypt"' >> /etc/portage/make.conf
vi /etc/portage/make.conf

eselect profile set 2

emerge sys-fs/cryptsetup\
       app-admin/syslog-ng \
       sys-process/cronie \
       net-misc/netifrc \
       sys-apps/mlocate \
       net-misc/dhcpcd \
       sys-kernel/linux-firmware \
       sys-boot/grub \
       sys-apps/pciutils \
       app-portage/eix

eix-update

rc-update add syslog-ng default
rc-update add cronie default
rc-update add sshd default

echo "Europe/Oslo" > /etc/timezone
emerge --config sys-libs/timezone-data
  
echo sys-kernel/gentoo-sources >> /etc/portage/package.keywords
emerge --ask sys-kernel/gentoo-sources
cd /usr/src/linux
make menuconfig
make && make modules_install
make install

mkdir -p /boot/efi/boot
cp /boot/vmlinuz-* /boot/efi/boot/bootx64.efi

emerge --ask genkernel
genkernel --lvm --luks --mdadm --install initramfs
