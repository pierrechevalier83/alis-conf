#!/usr/bin/env bash
set -e

# Get alis
curl -sL https://raw.githubusercontent.com/picodotdev/alis/master/download.sh | bash

GITHUB_USER=pierrechevalier83

# Install wget dependency
pacman -Sy --noconfirm wget

rm -f alis_custom.conf
rm -f alis_custom.vm.conf
rm -f alis_custom.chromebook.conf
rm -f alis_custom.T14.conf
rm -f alis_package_custom.sh
rm -f configure.sh

wget https://raw.githubusercontent.com/$GITHUB_USER/alis-conf/main/alis_custom.conf
wget https://raw.githubusercontent.com/$GITHUB_USER/alis-conf/main/alis_custom.vm.conf
wget https://raw.githubusercontent.com/$GITHUB_USER/alis-conf/main/alis_custom.chromebook.conf
wget https://raw.githubusercontent.com/$GITHUB_USER/alis-conf/main/alis_custom.T14.conf
wget https://raw.githubusercontent.com/$GITHUB_USER/alis-conf/main/alis_packages_custom.conf
wget https://raw.githubusercontent.com/$GITHUB_USER/alis-conf/main/configure.sh

chmod +x configure.sh
