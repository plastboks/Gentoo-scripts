#!/bin/bash

USELINE='USE="bindist mmx sse sse2 libkms crypt xa X xkb gtk xcb xft dir sqlite apng acl nls"'


# - Sync emerge

emerge-webrsync
emerge --sync


# - Edit use flags

sed -i.bak "/^USE/c$USELINE" /etc/portage/make.conf


# - Set profile

eselect profile set 2


# - Install some software

emerge --ask \
       app-editors/vim \
       sys-fs/cryptsetup\
       app-admin/syslog-ng \
       app-admin/sudo \
       sys-process/cronie \
       net-misc/netifrc \
       sys-apps/mlocate \
       net-misc/dhcpcd \
       sys-kernel/linux-firmware \
       sys-kernel/genkernel \
       sys-fs/lvm2 \
       sys-boot/grub \
       sys-apps/pciutils \
       app-portage/eix

eix-update


# - Add software to boot

rc-update add syslog-ng default
rc-update add cronie default
rc-update add sshd default
rc-update add lvm boot


# - Set timezone and locale

echo "Europe/Oslo" > /etc/timezone
emerge --config sys-libs/timezone-data

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
eselect locale set 243
echo 'LC_COLLATE="C"' >> /etc/env.d/02locale

env-update && source /etc/profile
export PS1="[(chroot)]# "


# - Install kernel

echo sys-kernel/gentoo-sources >> /etc/portage/package.keywords
emerge --ask sys-kernel/gentoo-sources
cd /usr/src/linux
make menuconfig
make && make modules_install
make install


# - Install boot loader

mkdir -p /boot/efi/boot
cp /boot/vmlinuz-* /boot/efi/boot/bootx64.efi

genkernel --lvm --luks --mdadm --install initramfs


# - Modifying fstab

sed -i '/fd0/d' /etc/fstab
sed -i '/cdrom/d' /etc/fstab

sed -i 's/BOOT/disk\/by-partlabel\/boot/g' /etc/fstab
sed -i 's/SWAP/mapper\/gentoo-swap/g' /etc/fstab
sed -i 's/ROOT/mapper\/gentoo-root/g' /etc/fstab
echo "$LVM_HOME   /home            ext4    noatime              0 2" >> /etc/fstab

perl -pi -e 's/(issue_discards) = 0/$1 = 1/' /etc/lvm/lvm.conf


# - Hostname

read -p "=> Enter hostname: " -r
HOSTNAME=$REPLY
echo "$HOSTNAME" > /etc/hostname
sed -i.bak "/127.0.0.1/c\127.0.0.1    $HOSTNAME localhost" /etc/hosts


# - Network

INTERFACE=`ip addr | grep "2: " | awk '$0=$2' | sed 's/://g'`
echo "config_$INTERFACE="dhcp"" > /etc/conf.d/net
cd /etc/init.d
ln -s net.lo net.$INTERFACE
rc-update add net.$INTERFACE default


# - Add user

read -p "=> Enter username: " -r
useradd -m -g users -G wheel -s /bin/bash $REPLY
passwd $REPLY
passwd -l root
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel


# - Bootloader

echo GRUB_CMDLINE_LINUX="dolvm" >> /etc/default/grub
read -p "=> Enter grub install disk: " -r
GRUBDISK=$REPLY
grub2-install $GRUBDISK
grub2-mkconfig -o /boot/grub/grub.cfg
