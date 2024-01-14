#!/bin/bash

# Check if the script is run as root or with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or with sudo."
    exit 1
fi
# Add 32bit repos
dpkg --add-architecture i386
#sources list add

# Update package lists
apt update
# remove unwanted packages

# Upgrade installed packages
apt upgrade -y

# Define the packages to install
packages=("libglib2.0-bin" "okular" "smartmontools" "vlc" "radeontop" "pavucontrol" "qbittorrent" "filezilla" "openjdk-17-jre" "npm" "nodejs" "btop" "code" "wget" "git" "file-roller" "flameshot" "flatpak" "galculator" "gnome-disk-utility" "gparted" "baobab" "krita" "nala" "neofetch")

# Construct a single command to install all packages
install_command=$(printf "%s " "${packages[@]}")

# Use the appropriate package manager for your system
apt-get install -y $install_command  # For Debian/Ubuntu

# Check if the installation was successful
if [ $? -eq 0 ]; then
    echo "Packages installed successfully."
else
    echo "Failed to install packages. Exiting."
    exit 1
fi

echo "Installation completed."
exit 0
