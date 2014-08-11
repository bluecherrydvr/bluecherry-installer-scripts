#!/bin/bash
set -e

in-target bash -c "\
		apt-get update; \
		apt-get install --yes --verbose-versions \
			openssh-server \
			bluecherry \
			solo6010-dkms \
		; \
		" &> /target/preseed.sh.log
