#!/bin/bash

# Get the directory to save downloaded files
FEATURE_DIR=$1
mkdir -p $FEATURE_DIR

# Download Samba and its dependencies
sudo dnf install -y dnf-plugins-core
sudo dnf download --resolve --destdir=$FEATURE_DIR samba samba-client samba-common
