#!/bin/bash

# Save the current working directory
ORIGINAL_CWD=$(pwd)

# Get the directory to save downloaded files
FEATURE_DIR=$1
mkdir -p $FEATURE_DIR

# Variables
AST_VERSION=18.24.2

# Update the system
sudo dnf update -y

# Install the necessary tools
sudo dnf install -y epel-release dnf-plugins-core
sudo dnf config-manager --set-enabled PowerTools
sudo dnf install -y \
    wget \
    git \
    tar \
    gzip

# Download Asterisk source code
cd $FEATURE_DIR
wget http://downloads.asterisk.org/pub/telephony/asterisk/old-releases/asterisk-$AST_VERSION.tar.gz
#wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-$AST_VERSION.tar.gz

# Download Asterisk build dependencies
sudo dnf install --downloadonly --downloaddir=$FEATURE_DIR \
    "Development Tools" \
    ncurses-devel \
    libxml2-devel \
    sqlite-devel \
    openssl-devel \
    libuuid-devel \
    jansson-devel \
    libedit-devel \
    pjproject-devel

# Download additional dependencies using the Asterisk script
tar zxvf asterisk-$AST_VERSION.tar.gz
cd asterisk-$AST_VERSION
sudo contrib/scripts/install_prereq install --install=no --download=$FEATURE_DIR

# Package all downloaded files
cd $FEATURE_DIR
tar czvf asterisk_offline_install.tar.gz *

echo "All files have been downloaded and packaged into asterisk_offline_install.tar.gz."

# Return to the original working directory
cd $ORIGINAL_CWD
