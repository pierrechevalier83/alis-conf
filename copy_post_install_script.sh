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

function clone_alis_conf_repo() {
    print_step "clone_alis_conf_repo()"
    execute_user "mkdir -p /home/$USER_NAME/Documents/code"
    execute_user "cd /home/$USER_NAME/Documents/code && git clone https://github.com/pierrechevalier83/alis-conf"
}

function copy_alis_config_file() {
    print_step "copy_alis_config_file()"
    cp alis.conf /mnt/home/$USER_NAME/Documents/code/
    execute_sudo "chown $USER_NAME /home/$USER_NAME/Documents/code/alis.conf"
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
    echo -e "${GREEN}Post install script successfully setup on installed system"'!'"${NC}"
    echo -e "${GREEN}On first boot, cd ~/Documents/code/alis-conf and run ./post_install.sh to perform final configuration steps"'!'"${NC}"
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
    ALL_STEPS=("configuration_install facts clone_alis_conf_repo copy_alis_config_file end")
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
    execute_step "clone_alis_conf_repo" "${STEPS}"
    execute_step "copy_alis_config_file" "${STEPS}"
    execute_step "end" "${STEPS}"
}

main $@
