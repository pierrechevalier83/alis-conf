curl -sL https://raw.githubusercontent.com/pierrechevalier83/alis-conf/main/download.sh | bash &&
./configure.sh &&
./alis.sh &&
./copy_post_install_script.sh &&
./alis-reboot.sh
