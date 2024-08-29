#!/bin/bash

# Exit on any error
set -e
set -u
set -o pipefail

# Define the directory and file for tracking installation state
STATE_DIR="$HOME/.enera"
STATE_FILE="$STATE_DIR/installation_state.txt"

# Ensure the state directory exists
mkdir -p "$STATE_DIR"

# Check if a tar file was passed as an argument or if it's in the current directory
TAR_FILE=$1
if [ -z "$TAR_FILE" ]; then
    TAR_FILE="./offline_installation.tar.gz"
fi

# Ensure the TAR file exists
if [ ! -f "$TAR_FILE" ]; then
    echo "Error: TAR file not found: $TAR_FILE"
    exit 1
fi

# Extract the TAR file
EXTRACT_DIR="extracted_features"
mkdir -p "$EXTRACT_DIR"
tar -xzvf "$TAR_FILE" -C "$EXTRACT_DIR"

# Initialize the state file if it doesn't exist
if [ ! -f "$STATE_FILE" ]; then
    touch "$STATE_FILE"
fi

# Function to check if a feature is already installed
is_installed() {
    feature_name=$1
    grep -q "^$feature_name$" "$STATE_FILE"
}

# Function to mark a feature as installed
mark_installed() {
    feature_name=$1
    echo "$feature_name" >> "$STATE_FILE"
}

# Function to install a package
install_packages() {
    feature_name=$1
    feature_dir=$2

    if is_installed "$feature_name"; then
        read -p "$feature_name is already installed. Do you want to reinstall it? (y/n) " choice
        if [ "$choice" != "y" ]; then
            echo "Skipping $feature_name."
            return
        fi
    fi

    if [ -d "$feature_dir" ]; then
        echo "Installing packages from $feature_dir..."
        sudo dnf install -y $feature_dir/*.rpm
        mark_installed "$feature_name"
    else
        echo "Directory $feature_dir does not exist, skipping."
    fi
}

# Function to install npm dependencies
install_npm_dependencies() {
    feature_name=$1
    feature_dir=$2
    package_name=$3

    if is_installed "$feature_name-$package_name"; then
        read -p "$feature_name-$package_name is already installed. Do you want to reinstall it? (y/n) " choice
        if [ "$choice" != "y" ]; then
            echo "Skipping $package_name."
            return
        fi
    fi

    if [ -f "$feature_dir/$package_name.tar.gz" ]; then
        echo "Installing npm dependencies for $package_name..."
        tar -xzvf "$feature_dir/$package_name.tar.gz" -C /path/to/your/nodejs/app
        mark_installed "$feature_name-$package_name"
    else
        echo "No npm dependencies to install for $package_name, skipping."
    fi
}

# Check for and install each feature based on the directories present
if [ -d "$EXTRACT_DIR/asterisk" ]; then
    install_packages "Asterisk" "$EXTRACT_DIR/asterisk"
fi

if [ -d "$EXTRACT_DIR/asterisk_source" ]; then
    install_packages "Asterisk_Source" "$EXTRACT_DIR/asterisk_source"
    ./utilities/install_asterisk_from_source.sh
fi

if [ -d "$EXTRACT_DIR/enera_asterisk_api" ]; then
    install_packages "Enera_Asterisk_API" "$EXTRACT_DIR/enera_asterisk_api"
    install_npm_dependencies "Enera_Asterisk_API" "$EXTRACT_DIR/enera_asterisk_api" "asterisk-api-server"
    install_npm_dependencies "Enera_Asterisk_API" "$EXTRACT_DIR/enera_asterisk_api" "asterisk-web-server"
    ./utilities/install_nginx.sh
    ./utilities/install_enera_api.sh
fi

if [ -d "$EXTRACT_DIR/samba" ]; then
    install_packages "Samba" "$EXTRACT_DIR/samba"
    ./utilities/install_samba.sh
fi

if [ -d "$EXTRACT_DIR/rdp" ]; then
    install_packages "RDP" "$EXTRACT_DIR/rdp"
fi

if [ -d "$EXTRACT_DIR/vcsode" ]; then
    install_packages "VSCode" "$EXTRACT_DIR/vscode"

    # Install VSCode extensions
    EXT_DIR="$EXTRACT_DIR/vscode/vscode-extensions"
    if [ -d "$EXT_DIR" ]; then
        echo "Installing VSCode extensions..."
        for ext in "$EXT_DIR"/*.vsix; do
            code --install-extension "$ext"
        done
        mark_installed "VSCode-extensions"
    fi
fi

if [ -d "$EXTRACT_DIR/rhel_security_updates" ]; then
    install_packages "RHEL_Security_Updates" "$EXTRACT_DIR/rhel_security_updates"
fi

if [ -d "$EXTRACT_DIR/rhel_all_updates" ]; then
    install_packages "RHEL_All_Updates" "$EXTRACT_DIR/rhel_all_updates"
fi

echo "Installation complete."
