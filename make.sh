#!/bin/bash
set -e
set -x

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
sudo rm -rf extract-cd squashfs.unpacked || true
mkdir extract-cd
rsync -a mnt/ extract-cd
sudo umount mnt/

sudo unsquashfs -d squashfs.unpacked extract-cd/casper/filesystem.squashfs
sudo chmod u+w extract-cd/casper/filesystem.squashfs squashfs.unpacked squashfs.unpacked/etc/apt/sources.list
sudo chroot squashfs.unpacked bash -c ": \
	     && wget -O - -q http://distro.bluecherrydvr.com/key/bluecherry-distro-archive-keyring.gpg | apt-key add - \
	     && add-apt-repository 'deb http://distro.bluecherrydvr.com/ubuntu/ precise main' \
	     && apt-get update \
	     && apt-get remove --yes ubiquity-slideshow-ubuntu \
	     && apt-get install --yes bluecherry-live plymouth-theme-bluecherry-logo \
	     "
sudo mksquashfs squashfs.unpacked extract-cd/casper/filesystem.squashfs -noappend

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
