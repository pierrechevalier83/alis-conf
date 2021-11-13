#!/usr/bin/env bash
set -e

# enviroment variables
#USER_NAME=""
#USER_PASSWORD=""

# global variables (no configuration, don't edit)
SYSTEM_INSTALLATION="false"
CONF_FILE="alis.conf"

RED='\033[0;31m'
GREEN='\033[0;32m'
LIGHT_BLUE='\033[1;34m'
NC='\033[0m'

function configuration_install() {
    source "$CONF_FILE"
}

function facts() {
    print_step "facts()"

    if [ $(whoami) == "root" ]; then
        SYSTEM_INSTALLATION="true"
    else
        SYSTEM_INSTALLATION="false"
        USER_NAME="$(whoami)"
    fi
}

function setup_dotfiles() {
    print_step "setup_dotfiles()"
    mkdir -p /home/$USER_NAME/Documents/code
    mkdir -p /home/$USER_NAME/.config/nvim
    mkdir -p /home/$USER_NAME/.config/alacritty
    cd /home/$USER_NAME/Documents/code && rm -rf dotfiles && git clone https://github.com/pierrechevalier83/dotfiles && cd -
    ln -sf /home/$USER_NAME/Documents/code/dotfiles/git/.gitconfig /home/$USER_NAME/.gitconfig
    ln -sf /home/$USER_NAME/Documents/code/dotfiles/zsh/.zshrc /home/$USER_NAME/.zshrc
    sudo ln -sf /home/$USER_NAME/Documents/code/dotfiles/zsh/.zshrc /root/.zshrc
    ln -sf /home/$USER_NAME/Documents/code/dotfiles/neovim/init.vim /home/$USER_NAME/.config/nvim/init.vim
    curl -fLo /home/$USER_NAME/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    nvim +PlugInstall +UpdateRemotePlugins +qall
    nvim +CocInstall coc-rust-analyzer +qall
    ln -sf /home/$USER_NAME/Documents/code/dotfiles/alacritty/alacritty.yml /home/$USER_NAME/.config/alacritty/alacritty.yml
}

function configure_gnome() {
    print_step "configure_gnome()"
    cp templates/dconf.settings .
    if [ "$MACHINE" == "chromebook" ]; then
        cat templates/dconf.chromebook.settings >> dconf.settings
    elif [ "$MACHINE" == "T14" ]; then
        cat templates/dconf.T14.settings >> dconf.settings
    fi
    dconf load / < dconf.settings
    rm dconf.settings
}

function configure_gdm() {
    print_step "configure_gdm()"
	sudo mkdir -p /etc/dconf/profile/gdm
	sudo cp template/gdm /etc/dconf/profile/gdm
    sudo mkdir -p /etc/dconf/db/gdm.d
	sudo cp templates/06-tap-to-click /etc/dconf/db/gdm.d/06-tap-to-click
	sudo dconf update
}


function setup_etc_hosts() {
    print_step "setup_etc_hosts()"
	cp templates/hosts .
	sed -i "s/HOSTNAME/$HOSTNAME/g" hosts
	sudo cp hosts /etc/hosts
	rm hosts
}

function setup_mirror_upgrade_hook() {
    print_step "setup_mirror_upgrade_hook()"
	sudo mkdir -p /etc/pacman.d/hooks
	sudo cp templates/mirrorupgrade.hook /etc/pacman.d/hooks/mirrorupgrade.hook
}

function setup_rust() {
	print_step "setup_rust()"
	rustup install nightly stable
	rustup default stable
}

function execute_sudo() {
    COMMAND="$1"
    if [ "$SYSTEM_INSTALLATION" == "true" ]; then
        arch-chroot /mnt bash -c "$COMMAND"
    else
        bash -c "sudo $COMMAND"
    fi
}

function execute_user() {
    COMMAND="$1"
    if [ "$SYSTEM_INSTALLATION" == "true" ]; then
        arch-chroot /mnt bash -c "su $USER_NAME -s /usr/bin/bash -c \"$COMMAND\""
    else
        bash -c "$COMMAND"
    fi
}

function end() {
    echo ""
    echo -e "${GREEN}Arch Linux configured as per pierrechevalier83's preferences"'!'"${NC}"
    echo ""
}

function print_step() {
    STEP="$1"
    echo ""
    echo -e "${LIGHT_BLUE}# ${STEP} step${NC}"
    echo ""
}

function execute_step() {
    STEP="$1"
    STEPS="$2"
    if [[ " $STEPS " =~ " $STEP " ]]; then
        eval $STEP
    else
        echo "Skipping $STEP"
    fi
}

function main() {
    ALL_STEPS=("configuration_install facts setup_dotfiles configure_gnome configure_gdm setup_etc_hosts setup_mirror_upgrade_hook end")
    STEP="configuration_install"

    if [ -n "$1" ]; then
        STEP="$1"
    fi
    if [ "$STEP" == "steps" ]; then
        echo "Steps: $ALL_STEPS"
        return 0
    fi

    # get step execute from
    FOUND="false"
    STEPS=""
    for S in ${ALL_STEPS[@]}; do
        if [ $FOUND = "true" -o "${STEP}" = "${S}" ]; then
            FOUND="true"
            STEPS="$STEPS $S"
        fi
    done

    execute_step "configuration_install" "${STEPS}"
    execute_step "facts" "${STEPS}"
    execute_step "setup_dotfiles" "${STEPS}"
    execute_step "configure_gnome" "${STEPS}"
    execute_step "configure_gdm" "${STEPS}"
    execute_step "setup_etc_hosts" "${STEPS}"
    execute_step "setup_mirror_upgrade_hook" "${STEPS}"
    #execute_step "setup_rust" "${STEPS}"
    execute_step "end" "${STEPS}"
}

main $@
