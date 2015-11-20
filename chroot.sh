#!/bin/bash

source /etc/profile

emerge-webrsync
emerge --sync

emerge vim \
        cryptsetup \
        app-admin/syslog-ng \
        sys-process/cronie \
        net-misc/netifrc \
        sys-apps/mlocate \
        net-misc/dhcpcd \
        sys-kernel/gentoo-sources \
        sys-kernel/linux-firmware \
        sys-boot/grub

rc-update add syslog-ng default
rc-update add cronie default
rc-update add sshd default

echo "Europe/Oslo" > /etc/timezone
emerge --config sys-libs/timezone-data

# cd /usr/src/linux
# make menuconfig
# make && make modules_install
# make install


mkdir -p /boot/efi/boot
cp /boot/vmlinuz-* /boot/efi/boot/bootx64.efi

emerge --ask genkernel
genkernel --lvm --luks --install initramfs
