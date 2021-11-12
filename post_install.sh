#!/usr/bin/env bash
set -e

CONF_FILE="alis.conf"

RED='\033[0;31m'
GREEN='\033[0;32m'
LIGHT_BLUE='\033[1;34m'
NC='\033[0m'

function configuration_install() {
    source "$CONF_FILE"
}

function setup_dotfiles() {
	print_step "setup_dotfiles()"
	arch-chroot /mnt bash -c "mkdir /home/$USER_NAME/Documents/code"
	arch-chroot /mnt bash -c "mkdir -p /home/$USER_NAME/.config/nvim"
	arch-chroot /mnt bash -c "mkdir -p /home/$USER_NAME/.config/alacritty"
	arch-chroot /mnt bash -c "cd /home/$USER_NAME/Documents/code && git clone https://github.com/pierrechevalier83/dotfiles"
	arch-chroot /mnt bash -c "ln -s /home/$USER_NAME/Documents/code/dotfiles/git/.gitconfig /home/$USER_NAME/.gitconfig"
	arch-chroot /mnt bash -c "ln -s /home/$USER_NAME/Documents/code/dotfiles/zsh/.zshrc /home/$USER_NAME/.zshrc"
	arch-chroot /mnt bash -c "ln -s /home/$USER_NAME/Documents/code/dotfiles/zsh/.zshrc /root/.zshrc"
	arch-chroot /mnt bash -c "ln -s /home/$USER_NAME/Documents/code/dotfiles/neovim/init.vim /home/$USER_NAME/.config/neovim/init.vim"
	arch-chroot /mnt bash -c "curl -fLo /home/$USER_NAME/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
	arch-chroot /mnt bash -c "ln -s /home/$USER_NAME/Documents/code/dotfiles/alacritty/alacritty.yml /home/$USER_NAME/.config/alacritty/alacritty.yml"
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
    ALL_STEPS=("setup_dotfiles")
    STEP="setup_dotfiles"

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

    execute_step "setup_dotfiles" "${STEPS}"
    execute_step "end" "${STEPS}"
}

main $@
