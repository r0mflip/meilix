#!/bin/bash
sudo chroot chroot <<EOF
# Set up several useful shell variables
export CASPER_GENERATE_UUID=1
export HOME=/root
export TTY=unknown
export TERM=vt100
export DEBIAN_FRONTEND=noninteractive
export LANG=C
export LIVE_BOOT_SCRIPTS="casper lupin-casper"

# To allow a few apps using upstart to install correctly. JM 2011-02-21
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl

# Installing wget
apt-get install wget apt-transport-https

# Add key for third party repo
apt-key update
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E1098513
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1EBD81D9
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 91E7EE5E

if [ ${arch} == 'amd64' ]; then
# add support for i386 packages
dpkg --add-architecture i386
fi

# Update in-chroot package database
apt-get -qq update

apt-get -qq -y install glib2 #may resolve error

# Install core packages
apt-get -qq -y --purge install ubuntu-standard casper lupin-casper \
  laptop-detect os-prober linux-generic

#see if this works, needs refactoring
sed -i 's\USERNAME=casper\USERNAME=${1:-"hotelos"}\g' /usr/share/initramfs-tools/scripts/casper

# Install meilix metapackage
dpkg -i meilix-metapackage*.deb
apt-get install -f

# Install base packages
apt-get -qq -y install xorg
apt-get -qq -y install sddm
# apt-get -qq -y install lightdm
#apt-get -qq -y install xserver-xorg-video-intel



apt-get -qq -y --allow-unauthenticated install lxqt openbox
apt-get -qq -y --allow-unauthenticated install pcmanfm-qt
apt-get -qq -y --allow-unauthenticated install lxqt-metapackage
apt-get -qq -y --allow-unauthenticated install lxqt-admin lxqt-common lxqt-config lxqt-globalkeys lxqt-notificationd
apt-get -qq -y --allow-unauthenticated install lxqt-panel lxqt-policykit lxqt-powermanagement lxqt-qtplugin \
apt-get -qq -y --allow-unauthenticated install lxqt-runner lxqt-session lxqt-sudo


#sudo apt-get install lightdm-gtk-greeter
# set
#dpkg-reconfigure lightdm

#/usr/lib/lightdm/lightdm-set-defaults --autologin hotelos

#apt-get -qq -y install lubuntu-desktop

# Install ubiquity
apt-get -qq -y install ubiquity ubiquity-casper ubiquity-slideshow-ubuntu ubiquity-frontend-kde


# Plymouth theme
apt-get -qq -y install plymouth-label #dependency of our theme
dpkg -i plymouth-meilix-logo_1.0-1_all.deb
dpkg -i plymouth-meilix-text_1.0-1_all.deb
apt-get install -f

ls /usr/share/plymouth/themes # show us which themes we have
# show us the plymouth meilix-logo folder
ls /usr/share/plymouth/themes/meilix-logo/
update-alternatives --verbose --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/meilix-logo/meilix-logo.plymouth 150
update-alternatives --verbose --install /usr/share/plymouth/themes/text.plymouth text.plymouth /usr/share/plymouth/themes/meilix-text/meilix-text.plymouth 144

#update-alternatives --verbose --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/meilix-logo/meilix-plymouth-theme.plymouth 150

update-alternatives --list text.plymouth
update-alternatives --list default.plymouth

update-alternatives --auto text.plymouth
update-alternatives --auto default.plymouth

#update-alternatives --skip-auto --config default.plymouth
update-initramfs -u # update initram
#update-initramfs -u -b /image/casper # update initram
update-initramfs -c -k all
#update-initramfs -c -k all -b /image/casper

# Fix chromium install problem
 mv /etc/chromium-browser/ /etc/chromium-browser_

# Remove screensaver
apt-get -qq -y remove xscreensaver

# Archive Manager
apt-get -qq -y --purge install file-roller unrar

# lubuntu-restricted-extras
apt-get -qq -y --purge install lubuntu-restricted-extras

# Install specific packages
apt-get -qq -y -o Dpkg::Options::="--force-overwrite" --purge install chromium-browser

#rm -rf /etc/chromium-browser
mv /etc/chromium-browser_ /etc/chromium-browser

# Install lxrandr to change monitor settings
apt-get -qq -y --purge install lxrandr

# Install Internet packages
apt-get -qq -y --purge install flashplugin-installer google-talkplugin pidgin qpdfview libqtwebkit4

# Install local Skype 32Bit package
if [ ${arch} == 'amd64' ]; then
  # 64-bit
  wget https://go.skype.com/skypeforlinux-64.deb
  dpkg -i skypeforlinux-64.deb
else
  # 32-bit
  dpkg -i skype-ubuntu_4.1.0.20-1_i386.deb
fi

#Overwrite for decreasing the uid
sed -i '/UID_MIN/ c\UID_MIN 998' /etc/login.defs

# Install graphic
apt-get -qq -y --purge install gimp inkscape
#apt-get -qq -y --purge remove imagemagick

# Install Libreoffice
apt-get -qq -y --purge install --no-install-recommends libreoffice-gtk libreoffice-gtk libreoffice-writer libreoffice-calc libreoffice-impress

#screen-dimming turns off always
echo -ne "\033[9;0]" >> /etc/issue
setterm -blank 0 >> /etc/issue

#Install vlc
apt-get -qq -y install vlc

#Install dropbox
apt-get -qq -y install nautilus-dropbox
nautilus --quit

# Oxygen to be used as a fallback icon theme
apt-get -qq -y install oxygen-icon-theme

# Install text editor
apt-get -qq -y install kate

# Remove lxqt-powermanagement
#dependency on lxqt
#apt-get -qq -y purge lxqt-powermanagement
#apt-get -qq -y purge lxqt-powermanagement-l10n

# temporary for debugging black screen issue
cat /etc/default/grub
cat /boot/grub/grub.cfg
ls /boot/grub

#Remove Kwin
#apt-get remove kwin

#Google custom ad
apt-get -qq -y --purge install mygoad
#Install East Asia font
apt-get -qq -y --purge install ttf-arphic-uming ttf-wqy-zenhei ttf-sazanami-mincho ttf-sazanami-gothic ttf-unfonts-core
# Install languages packs
apt-get -qq -y --purge install language-pack-zh-hans language-pack-ja
apt-get -qq -y --purge install language-pack-gnome-en
# Install ibus
apt-get -qq -y --purge install ibus ibus-clutter ibus-gtk ibus-gtk3 ibus-qt4
apt-get -qq -y --purge install ibus-unikey ibus-anthy ibus-pinyin ibus-m17n
apt-get -qq -y --purge install im-switch

# Meilix default settings
dpkg -i --force-overwrite meilix-default-settings_1.0_all.deb
sed -i 's\USERNAME=casper\USERNAME=hotelos\g' /usr/share/initramfs-tools/scripts/casper
update-initramfs -u -k all
dpkg -i --force-overwrite systemlock_0.1-1_all.deb
sed -i 's\USERNAME=casper\USERNAME=hotelos\g' /usr/share/initramfs-tools/scripts/casper
apt-get install -f
apt-get -qq -y remove dconf-tools

# temporarily commented out to remove an error source
# Installation of packages from Generator Webapp
#SCRIPT_URL=https://www.github.com/fossasia/meilix-generator/archive/master.zip
#wget -O $scripts.zip $SCRIPT_URL
#unzip scripts.zip
#SCRIPTS_FOLDER_IN_ZIP="meilix-generator-master/scripts"
#ls $SCRIPTS_FOLDER_IN_ZIP; do
#$SCRIPTS_FOLDER_IN_ZIP/script; done			#execute all scripts

# Clean up the chroot before
perl -i -nle 'print unless /^Package: language-(pack|support)/ .. /^$/;' /var/lib/apt/extended_states
apt-get -qq clean
rm -rf /tmp/*
#rm /etc/resolv.conf


rm meilix-default-settings_1.0_all.deb
rm meilix-metapackage_1.0-1_all.deb
rm systemlock_0.1-1_all.deb plymouth-meilix-logo_1.0-1_all.deb plymouth-meilix-text_1.0-1_all.deb
rm meilix-imclient_*_all.deb

# Why was this added?
# apt-get remove --purge wget apt-transport-https

# Just for Test purposes
echo initramfs.con
cat conf/initramfs.conf
echo uuid.conf
cat conf/uuid.conf
echo conf.d
cat conf/conf.d
ls /usr/share/xsessions/
echo passphrase section
ls /usr/share/initramfs-tools/scripts/casper
ls /usr/share/initramfs-tools/scripts/casper-bottom/
echo Skript 25
less /usr/share/initramfs-tools/scripts/casper-bottom/25adduser
echo Skript 15
cat /usr/share/initramfs-tools/scripts/casper-bottom/15autologin
echo end passphrase section

# Reverting earlier initctl override. JM 2012-0604
rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl

exit
EOF
