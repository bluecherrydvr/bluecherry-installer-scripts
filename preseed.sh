#!/bin/bash
set -e

cp /cdrom/install_pkgs.sh /target/root
in-target /root/install_pkgs.sh
