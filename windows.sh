#!/bin/bash

#  Apps
#  package manager
#  wezterm
#  tiling manager

#  Configs
#  wezterm
#  tiling manager

echo "Checking choco installation"
choco -?
if [[ $? != 0 ]] ; then
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
else
    choco upgrade chocolatey
fi

# Start installing apps
echo "Installing missing applications"
choco install wezterm -y

# Move the relevant config
echo "Installing configs"
cp ./config/.wezterm.lua %USERPROFILE%/.wezterm.lua
