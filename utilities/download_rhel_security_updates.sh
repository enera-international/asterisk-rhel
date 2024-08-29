#!/bin/bash

# Get the directory to save downloaded files
FEATURE_DIR=$1
mkdir -p $FEATURE_DIR

# Download RHEL security updates
sudo dnf install -y dnf-plugins-core

# Download only the security updates
sudo dnf updateinfo list security | awk '{print $3}' | xargs sudo dnf download --resolve --destdir=$FEATURE_DIR

# Alternatively, to download all security updates without specifying:
# sudo dnf download --resolve --security --destdir=$FEATURE_DIR
