#!/bin/bash

wget http://distro.bluecherrydvr.com/ubuntu/installer/first_boot.sh -O /target/root/first_boot.sh

chmod a+x /target/root/first_boot.sh
cp /target/etc/rc.local{,.bkp}

cat << 'EOF' > /target/etc/rc.local
#!/bin/bash -e

service lightdm stop
sleep 2
openvt --console=8 --force --switch --wait -- bash -c "/root/first_boot.sh 2>&1 | tee -a /root/first_boot.log"
EOF


