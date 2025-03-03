#!/usr/bin/env bash

set -e  # Exit immediately on error
echo "Summoned"

# ---------------
# Necessary steps
# ---------------

prompt() {
    local msg="$1"
    local cmd="$2"
    local affirm="${3:-y}"  # Defaults to 'y' if no third argument is provided

    echo -n "$msg"
    read -r choice

    if [[ "$choice" == "$affirm" ]]; then
        eval "$cmd"
    else
        echo "Cancelled"
    fi
}

prompt "Give Termux permissions to access your files in internal storage? (y/N) " "termux-setup-storage"

echo "Updating package lists and upgrading installed packages..."
pkg update && pkg upgrade -y
pkg install -y coreutils termux-api

echo "Ensuring Termux:API addon is installed for clipboard interactions and more."
echo "Press <Enter> to continue..."
read -r

# Ensure nano is uninstalled if present
if command -v nano &>/dev/null; then
    pkg uninstall -y nano
fi

# -----------
# Basic setup
# -----------

get_config() {
    local path="$1"

    if [[ -e "$path" ]]; then
        realpath "$path"
    else
        echo "ERROR: No such file: $path" >&2
        return 1
    fi
}

# Get path to directory of cloned repo
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../"
cd || exit 1  # Ensure we're in the home directory

echo "Installing required packages..."
pkg install -y lsd fastfetch starship lazygit zoxide neovim

# Get stored configs
termux_conf=$(get_config "$DIR/res/.termux")
bash_conf=$(get_config "$DIR/res/.bash")
lsd_conf=$(get_config "$DIR/res/lsd")
motd_conf=$(get_config "$DIR/res/motd")

# Conditional config replacement
prompt "Replace existing configs? Or skip to first see/edit files in res/ (y/N) " "replace_configs"

replace_configs() {
    cp -vr "$termux_conf"/* "$HOME/.termux/"
    cp -vr "$bash_conf"/* "$HOME/"
    
    mkdir -p "$HOME/.config/"
    cp -vr "$lsd_conf" "$HOME/.config/"

    git clone https://github.com/the-attu/kickstart.nvim "$HOME/.config/"

    cp -v "$motd_conf" "$HOME/../usr/etc/motd"
}

# ------------------------
# End of script
# ------------------------

prompt "Want to set up a desktop environment [Termux X11 + XFCE]? (y/N) " "bash \"$DIR/scripts/desktop_setup.sh\""

echo "Everything is OK."
exit 0

