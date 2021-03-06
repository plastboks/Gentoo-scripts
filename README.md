Gentoo Scripts
==============

This is just a small repository for me to keep the installation process of Gentoo Linux as quick as possible.
There is nothing here meant to be taken seriously.

Download
========
`wget -O - https://raw.githubusercontent.com/plastboks/Gentoo-scripts/master/fetch.sh | bash`

Links
=====
* [prechroot.sh](prechroot.sh) - Partitioning and downloading stage3
* [chroot.sh](chroot.sh) - Install kernel, basic programs, bootloader, and user (etc...)


Thinkpad X220
=============
Some special kernel parameters for the X220

* Intel Gigabit Ethernet: (CONFIG_E1000E)
* Intel WLAN: (CONFIG_IWLAGNI)
* Intel HD Graphic: (CONFIG_DRM_I915I)
* TPM Chip (CONFIG_TCG_TIS)

Resources
=========
* [LVM](https://wiki.gentoo.org/wiki/LVM#Kernel)
* [Disks](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks)
* [Stage3](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage)
* [Base](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base)
* [Kernel](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Kernel)
* [System](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/System)
* [Tools](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Tools)
* [Bootloader](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Bootloader)
* [CheatSheet](https://wiki.gentoo.org/wiki/Gentoo_Cheat_Sheet)
