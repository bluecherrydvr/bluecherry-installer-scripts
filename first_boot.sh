#!/bin/bash
set -e
set -x

MYSQL_ADMIN_PASSWORD='insecure'

echo $LINENO
echo "
mysql-server-5.5 mysql-server/root_password password $MYSQL_ADMIN_PASSWORD
mysql-server-5.5 mysql-server/root_password_again password $MYSQL_ADMIN_PASSWORD
bluecherry bluecherry/mysql_admin_login string root
bluecherry bluecherry/mysql_admin_password string $MYSQL_ADMIN_PASSWORD
bluecherry bluecherry/db_name string bluecherry
bluecherry bluecherry/db_user string bluecherry
bluecherry bluecherry/db_password string bluecherry

" | debconf-set-selections 

echo $LINENO
apt-get update

echo $LINENO
apt-get install --yes --verbose-versions \
	mysql-server \
	openssh-server \
	solo6010-dkms \

#	bluecherry \


# TODO Populate package with fixed postinst into repos and install via apt-get
echo $LINENO
wget "http://lizard.bluecherry.net/~autkin/tmp/trusty/bluecherry_2.3.5-4_amd64.deb" -O /root/bc.deb
echo $LINENO
dpkg -i /root/bc.deb || true

echo $LINENO
apt-get --yes -f install
echo $LINENO
