#!/bin/bash

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
if [ -d "$EXTRACT_DIR/Asterisk" ]; then
    install_packages "Asterisk" "$EXTRACT_DIR/Asterisk"
fi

if [ -d "$EXTRACT_DIR/Enera_Asterisk_API" ]; then
    install_packages "Enera_Asterisk_API" "$EXTRACT_DIR/Enera_Asterisk_API"
    install_npm_dependencies "Enera_Asterisk_API" "$EXTRACT_DIR/Enera_Asterisk_API" "asterisk-api-server"
    install_npm_dependencies "Enera_Asterisk_API" "$EXTRACT_DIR/Enera_Asterisk_API" "asterisk-web-server"
fi

if [ -d "$EXTRACT_DIR/RDP" ]; then
    install_packages "RDP" "$EXTRACT_DIR/RDP"
fi

if [ -d "$EXTRACT_DIR/VSCode" ]; then
    install_packages "VSCode" "$EXTRACT_DIR/VSCode"

    # Install VSCode extensions
    EXT_DIR="$EXTRACT_DIR/VSCode/vscode-extensions"
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
