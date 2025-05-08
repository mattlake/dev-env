#!/bin/bash

echo "Starting setup script"

# First we need to check which os we are on, and then we can run the correct install scripts and ensure the config files go to the correct places
OS=$(uname)
echo $OS

if [[ "$OS" == 'Linux' ]] ; then
    echo "Linux detected"
    echo "Script not available"
    ecit 1
elif [[ "$OS" == 'Darwin' ]]; then
    echo "Detected Macos..."
    ( exec ./mac.sh )
elif [[ "$OS" == CYGWYN* || "$OS" == MINGW* ]]; then
    echo "Detected Windows"
    echo "Script not available"
    ecit 1
fi

# Apps
# wezterm - done
# tiling manager
# lazygit - done
# lazydocker - done
# fireship
# neovim -done
# fzf
# zoxide
# zsh cofig


