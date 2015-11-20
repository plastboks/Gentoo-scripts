#!/bin/bash

# A simple Gentoo post stage script

mirrorselect -i -o >> /mnt/gentoo/etc/portage/make.conf
mirrorselect -i -r -o >> /mnt/gentoo/etc/portage/make.conf

cp -L /etc/resolv.conf /mnt/gentoo/etc/

mount -t proc proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev

rm /dev/shm && mkdir /dev/shm
mount -t tmpfs -o nosuid,nodev,noexec shm /dev/shm
chmod 1777 /dev/shm

printf "=> Chrooting into gentoo \n"
echo "source /etc/profile" > /mnt/gentoo/root/.bashrc
echo "export PS1='(chroot) $PS1'" >> /mnt/gentoo/root/.bashrc
chroot /mnt/gentoo /bin/bash
