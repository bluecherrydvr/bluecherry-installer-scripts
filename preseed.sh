#!/bin/bash

wget http://distro.bluecherrydvr.com/ubuntu/installer/first_boot.sh -O /target/root/first_boot.sh

cat << 'EOF' > /target/etc/rc.local
#!/bin/bash -e
/root/first_boot.sh | tee -a /root/first_boot.log
EOF


