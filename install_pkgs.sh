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

" | in-target debconf-set-selections 

echo $LINENO
in-target apt-get update

echo $LINENO
in-target apt-get install --yes --verbose-versions \
	mysql-server \
	openssh-server \
	solo6010-dkms \

#	bluecherry \


# TODO Populate package with fixed postinst into repos and install via apt-get
echo $LINENO
in-target wget "http://lizard.bluecherry.net/~autkin/tmp/trusty/bluecherry_2.3.5-4_amd64.deb" -O /root/bc.deb
echo $LINENO
in-target dpkg -i /root/bc.deb

#apt-get --yes -f install
echo $LINENO
apt-install --yes -f install
echo $LINENO
