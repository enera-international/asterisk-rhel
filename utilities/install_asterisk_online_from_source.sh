#!/bin/bash

ASTERISK_FILENAME=asterisk-18.24.2

# Save the current working directory
ORIGINAL_CWD=$(pwd)

# Install dependencies
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y epel-release dnf-plugins-core
sudo dnf install -y \
    wget \
    git \
    ncurses-devel \
    libxml2-devel \
    sqlite-devel \
    openssl-devel \
    libuuid-devel \
    libedit-devel

sudo dnf install -y \
    tar gcc-c++ make newt-devel libsqlite3x-devel binutils-devel


# Download the Asterisk source
cd /usr/src/
sudo wget $ASTERISK_URL

source $ORIGINAL_CWD/utilities/install_asterisk_from_source.sh

echo "Asterisk installation is complete."

# Return to the original working directory
cd $ORIGINAL_CWD
