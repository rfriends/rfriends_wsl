#!/bin/bash
# -----------------------------------------
# install rfriends for wsl
# -----------------------------------------
# 1.0 2024/11/13
# 1.1 2024/11/16
# 1.2 2024/12/14
ver=1.2
SITE=https://github.com/rfriends/rfriends3/releases/latest/download
SCRIPT=rfriends3_latest_script.zip
# -----------------------------------------
echo
echo rfriends3 for wsl $ver
echo
# -----------------------------------------
user=`whoami`
dir=.
userstr="s/rfriendsuser/${user}/g"
# -----------------------------------------
ar=`dpkg --print-architecture`
bit=`getconf LONG_BIT`
echo
echo architecture is $ar $bit bits .
echo user is $user .
# -----------------------------------------
echo
echo install tools
echo
#
sudo apt update && sudo apt -y install \
unzip p7zip-full nano vim dnsutils iproute2 tzdata \
at cron wget curl atomicparsley \
php-cli php-xml php-zip php-mbstring php-json php-curl php-intl \
ffmpeg

#sudo apt -y install chromium-browser
sudo apt -y install samba
sudo apt -y install lighttpd lighttpd-mod-webdav php-cgi
sudo apt -y install openssh-server
# -----------------------------------------
echo
echo install rfriends3
echo
cd ~/
rm -f $SCRIPT
wget $SITE/$SCRIPT
unzip -q -o $SCRIPT
# -----------------------------------------
echo
echo configure samba
echo
echo since use c-drive, disable samba
echo

#sudo mkdir -p /var/log/samba
#sudo chown root.adm /var/log/samba

#mkdir -p /home/$user/smbdir/usr2/

#sudo cp -p /etc/samba/smb.conf /etc/samba/smb.conf.org
#sudo sed -e ${userstr} $dir/smb.conf.skel > $dir/smb.conf
#sudo cp -p $dir/smb.conf /etc/samba/smb.conf
#sudo chown root:root /etc/samba/smb.conf
# -----------------------------------------
echo
echo configure usrdir
echo
cdr=/mnt/c
sudo mkdir $cdr/rf3
sudo chown $user $cdr/rf3
sudo chgrp $user $cdr/rf3
mkdir $cdr/rf3/usr
mkdir $cdr/rf3/tmp
#
cat <<EOF | sudo tee /home/$user/rfriends3/config/usrdir.ini > /dev/null
;
; c:\rf3
;
; usr   : rec dir 
; tmp   : work dir
usrdir = "/mnt/c/rf3/usr/"
tmpdir = "/mnt/c/rf3/tmp/"
EOF
#
# -----------------------------------------
echo
echo configure lighttpd
echo

sudo cp -p /etc/lighttpd/conf-available/15-fastcgi-php.conf /etc/lighttpd/conf-available/15-fastcgi-php.conf.org
sudo sed -e ${userstr} $dir/15-fastcgi-php.conf.skel > $dir/15-fastcgi-php.conf
sudo cp -p $dir/15-fastcgi-php.conf /etc/lighttpd/conf-available/15-fastcgi-php.conf
sudo chown root:root /etc/lighttpd/conf-available/15-fastcgi-php.conf

sudo cp -p /etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf.org
sudo sed -e ${userstr} $dir/lighttpd.conf.skel > $dir/lighttpd.conf
sudo cp -p $dir/lighttpd.conf /etc/lighttpd/lighttpd.conf
sudo chown root:root /etc/lighttpd/lighttpd.conf

mkdir -p /home/$user/lighttpd/uploads/
cd /home/$user/rfriends3/script/html
ln -nfs temp webdav
cd ~/

sudo lighttpd-enable-mod fastcgi
sudo lighttpd-enable-mod fastcgi-php
# -----------------------------------------
#if [ ! -e /etc/wsl.conf ]; then
#cat <<EOF | sudo tee /etc/wsl.conf > /dev/null
#[boot]
#systemd = true
#EOF
#fi
#
#sudo grep systemd /etc/wsl.conf
#if [ $? = 1 ]; then
#cat <<EOF | sudo tee -a /etc/wsl.conf > /dev/null
#[boot]
#systemd = true
#EOF
#fi
# -----------------------------------------
if [ ! -e /etc/wsl.conf ]; then
echo /etc/wsl.conf not found
echo abnormal end
exit
fi
#
sudo grep systemd /etc/wsl.conf
if [ $? = 1 ]; then
echo systemd not found
echo abnormal end
exit
fi
# -----------------------------------------
sudo systemctl enable lighttpd
#sudo systemctl enable smbd
sudo systemctl enable atd
sudo systemctl enable cron
#
sudo systemctl restart lighttpd
#sudo systemctl restart smbd
sudo systemctl restart atd
sudo systemctl restart cron
# -----------------------------------------
ip=`ip -4 -br a`
echo
echo ip address is $ip .
echo
echo visit rfriends at http://xxx.xxx.xxx.xxx:8000
echo
# -----------------------------------------
# finish
# -----------------------------------------
echo finished
# -----------------------------------------
