#!/bin/bash
set -e
set -x

export LC_ALL= LANG=

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
sudo chmod u+w extract-cd/casper/filesystem.squashfs squashfs.unpacked squashfs.unpacked/etc/apt/sources.list squashfs.unpacked/etc/

sudo bash -c "echo 'en_US.UTF-8 UTF-8' > squashfs.unpacked/etc/locale.gen"

sudo chroot squashfs.unpacked bash -c ": \
	     && wget -O - -q http://distro.bluecherrydvr.com/key/bluecherry-distro-archive-keyring.gpg | apt-key add - \
	     && add-apt-repository 'deb http://distro.bluecherrydvr.com/ubuntu/ precise main' \
	     && apt-get update \
	     && apt-get remove --yes ubiquity-slideshow-ubuntu \
	     && apt-get remove --purge --yes '^account-plugin.*' aisleriot '^appmenu-qt.*' aspell apport baobab '^brasero.*' cheese '^compiz.*' dvd+rw-tools '^empathy.*' '^espeak.*' '^evince.*' \
	     && apt-get remove --purge --yes '^firefox.*' \
	     && apt-get remove --purge --yes '^friends.*' \
	     && apt-get remove --purge --yes gdb \
	     && apt-get remove --purge --yes '^gedit.*' \
	     && apt-get remove --purge --yes ghostscript \
	     && apt-get remove --purge --yes '^libreoffice.*' \
	     && apt-get remove --purge --yes '^language-pack.*' \
	     && apt-get remove --purge --yes '^libpurple.*' \
	     && apt-get remove --purge --yes man-db \
	     && apt-get remove --purge --yes manpages \
	     && apt-get remove --purge --yes manpages-dev \
	     && apt-get remove --purge --yes '^rhythmbox.*' \
	     && apt-get remove --purge --yes sane-utils \
	     && apt-get remove --purge --yes '^telepathy.*' \
	     && apt-get remove --purge --yes '^totem.*' \
	     && apt-get remove --purge --yes '^thunderbird.*' \
	     && apt-get remove --purge --yes '^transmission.*' \
	     && apt-get remove --purge --yes vim-tiny vim-common \
	     && apt-get remove --purge --yes wodim \
	     && apt-get remove --purge --yes xorg-docs-core \
	     && apt-get remove --purge --yes xterm \
	     && apt-get remove --purge --yes doc-base \
	     && apt-get remove --purge --yes info \
	     && apt-get remove --purge --yes install-info \
	     && apt-get remove --purge --yes gcc gcc-4.8 libgcc-4.8-dev \
	     && apt-get remove --purge --yes '.*-icon-theme' \
	     && apt-get remove --purge --yes '^fonts-t.*' '^fonts-kacst.*' '^fonts-sil.*' fonts-nanum ttf-punjabi-fonts ttf-indic-fonts-core fonts-khmeros-core fonts-lao fonts-lklug-sinhala gsfonts \
	     && apt-get remove --purge --yes smbclient \
	     && apt-get remove --purge --yes seahorse \
	     && apt-get remove --purge --yes apparmor \
	     && apt-get remove --purge --yes btrfs-tools \
	     && apt-get remove --purge --yes bash-completion \
	     && apt-get remove --purge --yes '^evolution-data-server.*' \
	     && apt-get remove --purge --yes '^sphinx.*' \
	     && apt-get remove --purge --yes '^zeitgeist.*' \
	     && apt-get autoremove --yes \
	     && apt-get install --yes bluecherry-live plymouth-theme-bluecherry-logo \
	     && apt-get autoclean --yes \
	     && apt-get clean --yes \
	     && rm -rf /usr/share/{doc,man} \
	     && rm -rf /usr/src/* \
	     && rm -rf /usr/lib/debug \
	     && rm -rf /usr/share/icons/HighContrast \

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
