#!/bin/bash

# Save the current working directory
ORIGINAL_CWD=$(pwd)

# Update the system
sudo dnf update -y

# Install dependencies
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y epel-release dnf-plugins-core
sudo dnf config-manager --set-enabled PowerTools
sudo dnf install -y \
    wget \
    git \
    ncurses-devel \
    libxml2-devel \
    sqlite-devel \
    openssl-devel \
    libuuid-devel \
    jansson-devel \
    libedit-devel \
    pjproject-devel

# Download the Asterisk source
cd /usr/src/
sudo wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-20-current.tar.gz

./install_asterisk_from_source.sh

echo "Asterisk installation is complete."

# Return to the original working directory
cd $ORIGINAL_CWD
