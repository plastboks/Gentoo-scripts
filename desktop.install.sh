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
read -p "Install xorg [y/N] " -n 1 -r
if [[ $REPLY =~ [Yy]$ ]]; then
    PACKAGES="$PACKAGES \
        x11-base/xorg-server \
        x11-apps/xinit \
        xrdb \
        xautolock \
        xdg-user-dirs \
        x11-apps/xset \
        x11-apps/setxkbmap \
        arandr \
        xrandr"
fi

########
# i3wm #
########
printf "\n"
read -p "Install i3 and friends [y/N] " -n 1 -r
if [[ $REPLY =~ [Yy]$ ]]; then
    PACKAGES="$PACKAGES \
        x11-wm/i3 \
        x11-misc/i3status \
        x11-misc/i3lock \
        x11-terms/rxvt-unicode \
        x11-misc/urxvt-perls \
        x11-misc/urxvt-font-size \
        x11-terms/xterm \
        x11-misc/xcompmgr \
        x11-misc/autocutsel \
        x11-themes/gnome-themes-standard \
        x11-themes/gtk-engines \
        x11-misc/dunst \
        x11-misc/redshift \
        x11-misc/xcompmgr \
        media-gfx/feh \
        x11-misc/dmenu"
fi

##########
# Editor #
##########
printf "\n"
read -p "Install editors [y/N]  " -n 1 -r
if [[ $REPLY =~ [Yy]$ ]]; then
    PACKAGES="$PACKAGES \
        app-vim/gnupg \
        app-editors/vim"
fi

#########
# Fonts #
#########
printf "\n"
read -p "Install free fonts [y/N] " -n 1 -r
if [[ $REPLY =~ [Yy]$ ]]; then
    PACKAGES="$PACKAGES \
        media-fonts/freefonts \
        media-fonts/dejavu \
        media-fonts/libertine \
        media-fonts/terminus-font \
        x11-themes/faenza-icon-theme \
        media-fonts/liberation-fonts"
fi

############
# Browsers #
############
printf "\n"
read -p "Install browsers [y/N] " -n 1 -r
if [[ $REPLY =~ [Yy]$ ]]; then
    PACKAGES="$PACKAGES \
        www-client/dwb \
        www-client/links \
        www-client/firefox"
fi

######################
# Misc network tools #
######################
printf "\n" #
read -p "Install ssh and sync utils [y/N] " -n 1 -r
if [[ $REPLY =~ [Yy]$ ]]; then
    PACKAGES="$PACKAGES \
        sys-fs/sshfs-fuse \
        net-misc/rsync \
        sys-libs/zlib"
fi

#########
# Crypt #
#########
printf "\n" #
read -p "Install crypt and privacy utils [y/N] " -n 1 -r
if [[ $REPLY =~ [Yy]$ ]]; then
    PACKAGES="$PACKAGES \
        sys-fs/encfs \
        dev-libs/openssl \
        app-admin/pass \
        app-crypt/gnupg"
fi

###########
# VARIOUS #
###########
printf "\n" # various
read -p "Install other various cli tools [y/N] " -n 1 -r
if [[ $REPLY =~ [Yy]$ ]]; then
    PACKAGES="$PACKAGES \
        media-video/cclive \
        net-misc/livestreamer \
        media-libs/quvi \
        media-libs/libquvi \
        dev-vcs/git \
        sys-process/htop \
        app-misc/tmux \
        app-misc/screen \
        net-fs/nfs-utils \
        net-misc/socat \
        sys-apps/findutils \
        sys-apps/lm_sensors \
        app-arch/unrar \
        app-portage/eix \
        app-arch/unzip"
fi

####################
# Smart card utils #
####################
printf "\n" #
read -p "Install Smart card utils [y/N] " -n 1 -r
if [[ $REPLY =~ [Yy]$ ]]; then
    PACKAGES="$PACKAGES \
        sys-apps/pcsc-tools \
        app-crypt/ccid"
fi

printf "\n"
sudo emerge –update –newuse –deep world
sudo emerge --ask $PACKAGES
exit
