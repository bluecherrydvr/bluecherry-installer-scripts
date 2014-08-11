#!/bin/bash
set -e

MYSQL_ADMIN_PASSWORD='insecure'

echo "
bluecherry bluecherry/note_install_succeed seen true

bluecherry bluecherry/mysql_admin_login seen true
bluecherry bluecherry/mysql_admin_login string root

bluecherry bluecherry/mysql_admin_password seen true
bluecherry bluecherry/mysql_admin_password string $MYSQL_ADMIN_PASSWORD

bluecherry bluecherry/db_name seen true
bluecherry bluecherry/db_name string bluecherry

bluecherry bluecherry/db_user seen true
bluecherry bluecherry/db_user string bluecherry

bluecherry bluecherry/db_password seen true
bluecherry bluecherry/db_password string bluecherry

" | debconf-set-selections 

apt-get update

apt-get install mysql-server
mysqladmin -u root password "$MYSQL_ADMIN_PASSWORD"

apt-get install --verbose-versions \
	openssh-server \
	solo6010-dkms \

#	bluecherry \


# TODO Populate package with fixed postinst into repos and install via apt-get
wget "http://lizard.bluecherry.net/~autkin/tmp/trusty/bluecherry_2.3.5-4_amd64.deb" -O bc.deb
dpkg -i bc.deb
