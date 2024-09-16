#!/bin/bash

# Get the directory to save downloaded files
FEATURE_DIR=$1
mkdir -p $FEATURE_DIR

# Download Asterisk and its dependencies
sudo dnf install -y dnf-plugins-core
sudo dnf download --resolve --destdir=$FEATURE_DIR asterisk asterisk-chan-sip
