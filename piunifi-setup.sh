#!/usr/bin/env bash

set -o errexit
set -o pipefail


# Function to output PiUniFi ascii and details of script.
script_info() {
    cat <<EOF
                                                                      
${RED}▓▓▓▓▓▓▓▓▓▓▓▓▓ ${GREEN}▓▓▓▓${RESET} ▓▓▓▓     ▓▓▓▓ ▓▓▓▓     ▓▓▓▓ ▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓
${RED}▓▓▓▓     ▓▓▓▓     ${RESET} ▓▓▓▓     ▓▓▓▓ ▓▓▓▓▓▓   ▓▓▓▓      ▓▓▓▓              
${RED}▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓${RESET} ▓▓▓▓     ▓▓▓▓ ▓▓▓▓ ▓▓▓ ▓▓▓▓ ▓▓▓▓ ▓▓▓▓▓▓▓▓▓     ▓▓▓▓
${RED}▓▓▓▓          ▓▓▓▓${RESET} ▓▓▓▓     ▓▓▓▓ ▓▓▓▓   ▓▓▓▓▓▓ ▓▓▓▓ ▓▓▓▓          ▓▓▓▓
${RED}▓▓▓▓          ▓▓▓▓${RESET} ▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓     ▓▓▓▓ ▓▓▓▓ ▓▓▓▓          ▓▓▓▓

                                                                      
Name:           piunifi-setup.sh
Description:    Raspberry Pi UniFi Network Controller Setup
Author:         github.com/piscripts
Tested:         Raspberry Pi 3 & 4 running Raspbian Buster
Modified:       2020-10-14
Usage:          sudo bash piunifi-setup.sh
Notes:          Requiries sudo/root superuser permissions to run.

EOF
}

# Function to set terminal colors if supported.
term_colors() {
    if [[ -t 1 ]]; then
        RED=$(printf '\033[31m')
        GREEN=$(printf '\033[32m')
        YELLOW=$(printf '\033[33m')
        BLUE=$(printf '\033[34m')
        MAGENTA=$(printf '\033[35m')
        CYAN=$(printf '\033[36m')
        BOLD=$(printf '\033[1m')
        RESET=$(printf '\033[0m')
    else
        RED=""
        GREEN=""
        YELLOW=""
        BLUE=""
        MAGENTA=""
        CYAN=""
        BOLD=""
        RESET=""
    fi
}

# Function to output colored or bold terminal messages.
# Usage examples: term_message "This is a default color and style message"
#                 term_message nb "This is a default color bold message"
#                 term_message rb "This is a red bold message"
term_message() {
    local set_color=""
    local set_style=""
    [[ -z "${2}" ]] && echo -ne "${1}" >&2 && return
    [[ ${1:0:1} == "d" ]] && set_color=${RESET}
    [[ ${1:0:1} == "r" ]] && set_color=${RED}
    [[ ${1:0:1} == "g" ]] && set_color=${GREEN}
    [[ ${1:0:1} == "y" ]] && set_color=${YELLOW}
    [[ ${1:0:1} == "b" ]] && set_color=${BLUE}
    [[ ${1:0:1} == "m" ]] && set_color=${MAGENTA}
    [[ ${1:0:1} == "c" ]] && set_color=${CYAN}
    [[ ${1:1:2} == "b" ]] && set_style=${BOLD}
    echo -e "${set_color}${set_style}${2}${RESET}" >&2 && return
}

# Displays a box containing a dash and message
task_start() {
    echo -ne "[-] ${1}"
}

# Displays a box containing a green tick and optional message if required.
task_done() {
    echo -e "\r[\033[0;32m\xE2\x9C\x94\033[0m] ${1}"
}

# Displays a box containing a red cross and optional message if required.
task_fail() {
    echo -e "\r[\033[0;31m\xe2\x9c\x98\033[0m] ${1}"
}

# Function to pause script and check if the user wishes to continue.
check_continue() {
    local response
    while true; do
        read -r -p "Do you wish to continue (y/N)? " response
        case "${response}" in
        [yY][eE][sS] | [yY])
            echo
            break
            ;;
        *)
            echo
            exit
            ;;
        esac
    done
}

# Function to check if superuser or running using sudo
check_superuser() {
    if [[ $(id -u) -ne 0 ]] >/dev/null 2>&1; then
        term_message rb "Script must be run by superuser or using sudo command\n"
        exit 1
    fi
}

pkg_update() {
    term_message cb "Updating packages using apt update..."
    apt update -y
}

pkg_upgrade() {
    term_message cb "Upgrading packages using apt upgrade..."
    apt upgrade -y
}

pkg_cleanup() {
    term_message cb "Running package clean-up using apt autoclean and autoremove..."
    apt autoclean -y
    apt autoremove -y
}

# Function to check if packages are installed and install them if they are not found.
pkg_install() {
    for pkg in "${@}"; do
        task_start "Checking for required package > ${pkg}"
        if [[ $(dpkg -s "${pkg}") == *"Status: install ok installed"* ]] &>/dev/null; then
            task_done
        else
            task_fail "Package ${pkg} not found.$(tput el)"
            term_message c "Attempting to install ${pkg} package with apt..."
            apt install -y "${pkg}"
            if [[ $(dpkg -s "${pkg}") == *"Status: install ok installed"* ]] &>/dev/null; then
                term_message g "Package ${pkg} is now installed."
            else
                term_message rb "Unable to install package ${pkg}"
            fi
        fi
    done
}

# Function to check if a service is active will return green tick or red cross.
is_active() {
    if [[ $(systemctl is-active "$1") == "active" ]] &>/dev/null; then
        task_done
    else
        task_fail
    fi
}

# Function to install all the dependencies including packages.
setup_dependencies() {
    term_message db "Setup Dependencies"
    term_message c "Installing required dependencies..."
    pkg_install ca-certificates apt-transport-https openjdk-8-jre-headless haveged
    task_start "Adding unifi debian source location and keys..."
    echo 'deb https://www.ui.com/downloads/unifi/debian stable ubiquiti' | sudo tee /etc/apt/sources.list.d/100-ubnt-unifi.list &>/dev/null
    sudo wget -O /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ui.com/unifi/unifi-repo.gpg &>/dev/null
    task_done
    term_message c "Updating packages to include newly added sources..."
    pkg_update
}

setup_unifi() {
    term_message c "Installing unifi..."
    pkg_install unifi
}


final_info() {
    term_message gb "\nSetup script has completed.\n"
    local hostip=$(hostname -I | awk '{print $1}')
    task_start "Unifi Controller Service https://${hostip}:8443" && is_active unifi
    term_message c "\nA reboot is required to ensure all newly installed services start.\n"
    check_continue
    term_message cb "\nRebooting Pi...\n"
    sudo reboot
}


main() {
    clear
    term_colors
    script_info
    check_superuser
    check_continue
    pkg_update
    pkg_upgrade
    pkg_cleanup
    setup_dependencies
    setup_unifi
    final_info
}

main "${@}"
