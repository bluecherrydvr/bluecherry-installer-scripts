#!/bin/bash
set -e

ISOFILE=ubuntu-14.04.1-desktop-amd64.iso
if ! [[ -f $ISOFILE ]]
then
	wget http://releases.ubuntu.com/14.04.1/ubuntu-14.04.1-desktop-amd64.iso -O $ISOFILE
fi

# mount
rm -rf mnt || true
mkdir mnt
sudo mount -o loop $ISOFILE mnt

# extract
sudo rm -rf extract-cd || true
mkdir extract-cd
rsync -a mnt/ extract-cd
sudo umount mnt/

# Very useful link: https://groups.google.com/forum/#!topic/packer-tool/SWhoARVwVnM

# Update isolinux/txt.cfg to use our preseed file, available via HTTP
chmod a+w extract-cd/isolinux/txt.cfg
cat << 'EOF' > extract-cd/isolinux/txt.cfg
default install
label install
  menu label ^Install Bluecherry Ubuntu distribution
  kernel /casper/vmlinuz.efi
  append  file=/cdrom/preseed.cfg boot=casper initrd=/casper/initrd.lz quiet splash automatic-ubiquity debug-ubiquity auto=true priority=critical    --

EOF

chmod a+w extract-cd
cp preseed.cfg preseed.sh extract-cd

pushd extract-cd
../mkiso.sh ../custom.iso
popd

echo 'Success. Take custom.iso'
