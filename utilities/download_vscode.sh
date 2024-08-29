#!/bin/bash

# Save the current working directory
ORIGINAL_CWD=$(pwd)

# Get the directory to save downloaded files
FEATURE_DIR=$1
mkdir -p $FEATURE_DIR

# Download VSCode and its dependencies
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

sudo dnf install -y dnf-plugins-core
sudo dnf download --resolve --destdir=$FEATURE_DIR code

# Download VSCode extensions for Bash and TypeScript
EXT_DIR=$FEATURE_DIR/vscode-extensions
mkdir -p $EXT_DIR
cd $EXT_DIR
wget https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-vscode/vsextensions/vscode-typescript-tslint-plugin/latest/vspackage -O vscode-typescript-tslint-plugin.vsix
wget https://marketplace.visualstudio.com/_apis/public/gallery/publishers/rogalmic/vsextensions/bash-debug/latest/vspackage -O bash-debug.vsix

# Return to the original working directory
cd $ORIGINAL_CWD
