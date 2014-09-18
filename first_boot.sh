#!/bin/bash

echo 'Please change password for default user, "bcadmin"; its current value is "insecure"'
passwd bcadmin || true
echo 'Please enter password for MySQL "root" user:'
IFS="\n" read MYSQL_ADMIN_PASSWORD || true

set -x

echo "
mysql-server-5.5 mysql-server/root_password password $MYSQL_ADMIN_PASSWORD
mysql-server-5.5 mysql-server/root_password_again password $MYSQL_ADMIN_PASSWORD
bluecherry bluecherry/mysql_admin_login string root
bluecherry bluecherry/mysql_admin_password string $MYSQL_ADMIN_PASSWORD
bluecherry bluecherry/db_name string bluecherry
bluecherry bluecherry/db_user string bluecherry
bluecherry bluecherry/db_password string bluecherry

" | debconf-set-selections 

apt-get update
apt-get remove --yes \
	ubuntu-artwork \


apt-get install --yes --verbose-versions \
	mysql-server \
	openssh-server \
	solo6010-dkms \
	bluecherry-artwork \
	plymouth-theme-bluecherry-logo \
	gnome-session-flashback \

#	bluecherry \


# TODO Populate package with fixed postinst into repos and install via apt-get
if [[ `arch` == 'x86_64' ]]
then
	ARCH='amd64'
else
	ARCH='i386'
fi

wget "http://lizard.bluecherry.net/~autkin/release_2.3.9-2/trusty/bluecherry_2.3.9-2_${ARCH}.deb" -O /root/bc.deb
dpkg -i /root/bc.deb || true

apt-get --yes -f install

mv /etc/rc.local{.bkp,}
rm $0
rm /root/bc.deb

echo -e "[SeatDefaults]\nuser-session=gnome-fallback" >> /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf

# chvt + lightdm restart don't work stable - user is often mysteriously thrown to tty1, so we reboot to stay safe and stable
reboot
