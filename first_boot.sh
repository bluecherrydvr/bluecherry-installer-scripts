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

wget -O - -q http://distro.bluecherrydvr.com/key/bluecherry-distro-archive-keyring.gpg | apt-key add -
add-apt-repository 'deb http://ubuntu.bluecherrydvr.com trusty main'

apt-get update
apt-get remove --yes \
	ubuntu-artwork \

apt-get install --yes --verbose-versions \
	linux-image-generic \
	linux-headers-generic \

apt-get install --yes --verbose-versions \
	mysql-server \
	openssh-server \
	solo6010-dkms \
	bluecherry-artwork \
	plymouth-theme-bluecherry-logo \
	gnome-session-flashback \
	bluecherry \
	bluecherry-client \


apt-get --yes -f install

mv /etc/rc.local{.bkp,}
rm $0

echo -e "[SeatDefaults]\nuser-session=gnome-fallback" >> /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf

echo "[Desktop Entry]
Encoding=UTF-8
Name=Bluecherry Web Interface
Type=Link
URL=https://127.0.0.1:7001/
Icon=text-html
" > /home/bcadmin/Desktop/webui.desktop

echo "[Desktop Entry]
Version=0
Name=Bluecherry Client
Comment=Application to view events and live camera video
Exec=/usr/bin/bluecherry-client
Terminal=false
" > /home/bcadmin/Desktop/bc-client.desktop

echo "#!/bin/bash
/usr/bin/bluecherry-client &
" > /home/bcadmin/.xsession
chmod +x /home/bcadmin/.xsession

# chvt + lightdm restart don't work stable - user is often mysteriously thrown to tty1, so we reboot to stay safe and stable
reboot
