#!/bin/bash

echo "Checking homebrew installation"
which -s brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    brew update
    brew upgrade --cask
fi

# Start installing apps
echo "installing missing applications"
brew install --cask wezterm
brew install --cask amethyst
brew install lazygit
brew install lazydocker
brew install neovim
brew install starship
brew install lsd

# Move the relevant config
echo "installing configs"
cp ./config/.wezterm.lua $HOME/.wezterm.lua
cp -r ./config/nvim $HOME/.config/nvim
cp ./config/.zshrc $HOME/.zshrc
