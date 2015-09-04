#!/bin/bash
#
# This is an ugly and simple shortcut for installing various software
# 
# The script should be considered as a reference only.
# 


PACKAGES=""


#############
# X related #
#############
printf "\n"
read -p "Install xorg [y/N]" -n 1 -r
if [[ $REPLY =~ [Yy]$ ]]; then
    PACKAGES="$PACKAGES \
        x11-base/xorg-server \
        x11-apps/xinit \
        xrdb \
        xautolock \
        xdg-user-dirs \
        arandr \
        xrandr"
fi

########
# i3wm #
########
printf "\n"
read -p "Install i3 and friends [y/N]" -n 1 -r
if [[ $REPLY =~ [Yy]$ ]]; then
    PACKAGES="$PACKAGES \
        i3 \
        x11-terms/rxvt-unicode \
        x11-misc/urxvt-perls \
        x11-misc/urxvt-font-size \
        x11-terms/xterm \
        x11-misc/xcompmgr \
        x11-misc/autocutsel \
        x11-themes/gnome-themes-standard \
        x11-themes/gtk-engines \
        media-gfx/feh \
        x11-misc/dmenu"
fi

#########
# Fonts #
#########
printf "\n"
read -p "Install free fonts [y/N]" -n 1 -r
if [[ $REPLY =~ [Yy]$ ]]; then
    PACKAGES="$PACKAGES \
        media-fonts/freefonts \
        media-fonts/dejavu \
        media-fonts/libertine \
        x11-themes/faenza-icon-theme \
        media-fonts/liberation-fonts"
fi

######################
# Misc network tools #
######################
printf "\n" #
read -p "Install ssh, encryption and sync utils [y/N]" -n 1 -r
if [[ $REPLY =~ [Yy]$ ]]; then
    PACKAGES="$PACKAGES \
        sys-fs/sshfs-fuse \
        net-misc/unison \
        net-misc/rsync \
        sys-fs/encfs \
        dev-libs/openssl \
        sys-libs/zlib"
fi

###########
# VARIOUS #
###########
printf "\n" # various
read -p "Install other various cli tools [y/N]" -n 1 -r
if [[ $REPLY =~ [Yy]$ ]]; then
    PACKAGES="$PACKAGES \
        media-video/cclive \
        net-misc/livestreamer \
        media-libs/quvi \
        media-libs/libquvi \
        dev-vcs/git \
        sys-process/htop \
        app-misc/tmux \
        www-client/links \
        net-fs/nfs-utils \
        net-misc/socat \
        sys-apps/findutils \
        app-arch/unrar \
        app-arch/unzip"
fi

####################
# Smart card utils #
####################
printf "\n" #
read -p "Install Smart card utils [y/N]" -n 1 -r
if [[ $REPLY =~ [Yy]$ ]]; then
    PACKAGES="$PACKAGES \
        sys-apps/pcsc-tools \
        app-crypt/ccid"
fi

sudo emerge $PACKAGES

exit
