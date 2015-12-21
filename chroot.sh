#!/bin/bash

USELINE='USE="bindist mmx sse sse2 libkms crypt dynamic symlink dir sqlite acl nls branding bash-completion smartcard syslog btrfs lvm ext4 usb gpg "'
XUSE=" xa X xkb gtk xcb xft apng"


# - Get some data before the display goes to sleep.

read -p "=> Enter hostname: " -r HOSTNAME
read -p "=> Enter username: " -r USER


# - Sync emerge

emerge-webrsync
emerge --sync


# - Edit use flags

sed -i.bak "/^USE/c$USELINE" /etc/portage/make.conf


# - Set profile

eselect profile set 2


# - Install some software

emerge \
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
       sys-boot/efibootmgr \
       sys-apps/pciutils \
       app-portage/layman \
       dev-vcs/git \
       sys-fs/btrfs-progs \
       sys-apps/util-linux \
       net-misc/ntp \
       app-portage/eix

eix-update


# - Add software to boot

rc-update add syslog-ng default
rc-update add cronie default
rc-update add sshd default
rc-update add lvm boot
rc-update add ntp-client default


# - Set timezone and locale

echo "Europe/Oslo" > /etc/timezone
emerge --config sys-libs/timezone-data

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
eselect locale set 243
echo 'LC_COLLATE="C"' >> /etc/env.d/02locale

env-update
source /root/.exports
source /root/.bashrc


# - Install kernel

echo sys-kernel/gentoo-sources >> /etc/portage/package.keywords
emerge sys-kernel/gentoo-sources

if [ -f /root/.config ]; then
    cp /root/.config /usr/src/linux/
fi

cd /usr/src/linux
make menuconfig
make -j3 && make modules_install
make install


# - Modifying fstab

sed -i.bak '/fd0/d' /etc/fstab
sed -i '/cdrom/d' /etc/fstab
sed -i '/BOOT/d' /etc/fstab

if [[ -z "$FS" ]]; then
    FS="ext4"
fi

BOOT_LINE="UUID=$BOOT_UUID /boot ext2 noauto,noatime 1 2"
ROOT_LINE="/dev/mapper/gentoo-root / $FS noatime 0 1"
SWAP_LINE="/dev/mapper/gentoo-swap none swap sw 0 0"
HOME_LINE="/dev/mapper/gentoo-home /home $FS noatime 0 2"

echo $BOOT_LINE >> /etc/fstab
sed -i "/\/dev\/ROOT/c$ROOT_LINE" /etc/fstab
sed -i "/\/dev\/SWAP/c$SWAP_LINE" /etc/fstab
echo $HOME_LINE >> /etc/fstab

perl -pi -e 's/(issue_discards) = 0/$1 = 1/' /etc/lvm/lvm.conf


# - Hostname

echo "HOSTNAME=$HOSTNAME" > /etc/conf.d/hostname
rc-update add hostname default
sed -i.bak "/127.0.0.1/c\127.0.0.1    $HOSTNAME localhost" /etc/hosts


# - Network

INTERFACE=`ip addr | grep "2: " | awk '$0=$2' | sed 's/://g'`
echo "config_$INTERFACE="dhcp"" > /etc/conf.d/net
cd /etc/init.d
ln -s net.lo net.$INTERFACE
rc-update add net.$INTERFACE default


# - Add user

useradd -m -g users -G wheel -s /bin/bash $USER
passwd $USER
passwd -l root
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel


# - Bootloader Section

# - Install boot loader

mkdir -p /boot/efi/boot
cp /boot/vmlinuz-* /boot/efi/boot/bootx64.efi

genkernel --lvm --luks --mdadm --install initramfs

INITRAMFS=$(basename `ls /boot/initramfs-*`)

#efibootmgr -c -d $DEVICE -p 2 -L "Gentoo" \
#    -l "\efi\boot\bootx64.efi" \
#    initrd="\\$INITRAMFS"

#grub2-mkimage -d /usr/lib64/grub/x86_64-efi \
#    -O x86_64-efi \
#    -p "" \
#    -o /boot/efi/efi/boot/bootx64.efi part_gpt btrfs fat ext2 normal \
#        crypto lvm chain boot configfile linux multiboot efi_gop linux


echo GRUB_CMDLINE_LINUX="dolvm" >> /etc/default/grub
grub2-install $DEVICE

if [[ $USE_LUKS -eq 1 ]]; then
  perl -pi -e 's/^(GRUB_CMDLINE_LINUX|GRUB_DISABLE_LINUX_UUID)/#$1/' /etc/default/grub
  echo GRUB_CMDLINE_LINUX=\"dolvm crypt_root=UUID=$ROOT_UUID\" >> /etc/default/grub
  echo GRUB_DISABLE_LINUX_UUID=true >> /etc/default/grub
fi

grub2-mkconfig -o /boot/grub/grub.cfg


# - Cleaning up some .bashrc lines

sed -i.bak '/PS1/d' /root/.bashrc
sed -i.bak '/exports/d' /root/.bashrc
