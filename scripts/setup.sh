#! /usr/bin/env bash

echo "summoned"

# ---------------
# necessary steps
# ---------------

set -e
termux-setup-storage

pkg update && pkg upgrade -y

echo "Make sure Termux:API app is installed on your device, ok?"
read
pkg install termux-api coreutils -y

# and, obviously
pkg uninstall nano -y

# -----------
# basic setup
# -----------

get_file() {
    local path="$1"

    if [ -f "$path" ]; then
        echo "$(realpath "$path")"
    else
        echo "ERROR: no such file $path" >&2
        return 1
    fi
}

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../"
cd
termux=$(get_file "$DIR/res/termux")
motd=$(get_file "$DIR/res/motd")
bashrc=$(get_file "$DIR/res/bashrc")
bash_aliases=$(get_file "$DIR/res/bash-aliases")

echo "want verbosity while copy-pasting? (y/N)"
read -r is_verbose
if [ "$is_verbose" = 'y' ]; then
    alias cp="cp -vf"
else
    alias cp="cp -f"
fi

cp -r "$termux" "$HOME/.termux/"
cp "$motd" "$HOME/../usr/etc/motd"
cp "$bashrc" "$HOME/.bashrc"
cp "$bash_aliases" "$HOME/.bash_aliases"

# ------------------------
# commencing end of script
# ------------------------

echo "want to setup a desktop environment[termux x11 + xfce]? (y/N)"
read -r gui_time
if [ "$gui_time" = 'y' ]; then
    bash "$DIR/scripts/desktop_setup.sh"
fi

echo "everything is ok."
exit 0

