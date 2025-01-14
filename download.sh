#!/usr/bin/env bash
set -e

# Get alis
curl -sL https://raw.githubusercontent.com/pierrechevalier83/alis/master/download.sh | bash

# Get my custom configs
GITHUB_USER=pierrechevalier83

rm -f alis_custom.conf
rm -f alis_custom.vm.conf
rm -f alis_custom.chromebook.conf
rm -f alis_custom.T14.conf
rm -f alis_package_custom.sh
rm -f configure.sh
rm -f copy_post_install_script.sh

curl -O https://raw.githubusercontent.com/$GITHUB_USER/alis-conf/main/alis_custom.conf
curl -O https://raw.githubusercontent.com/$GITHUB_USER/alis-conf/main/alis_custom.vm.conf
curl -O https://raw.githubusercontent.com/$GITHUB_USER/alis-conf/main/alis_custom.chromebook.conf
curl -O https://raw.githubusercontent.com/$GITHUB_USER/alis-conf/main/alis_custom.T14.conf
curl -O https://raw.githubusercontent.com/$GITHUB_USER/alis-conf/main/alis_packages_custom.conf
curl -O https://raw.githubusercontent.com/$GITHUB_USER/alis-conf/main/configure.sh
curl -O https://raw.githubusercontent.com/$GITHUB_USER/alis-conf/main/copy_post_install_script.sh

# Configure this particular environment
chmod +x configure.sh
chmod +x copy_post_install_script.sh
