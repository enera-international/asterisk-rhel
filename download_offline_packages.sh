#!/bin/bash

# Set default RHEL version to 9 if not provided
RHEL_VERSION=${1:-9}

# Function to check and install dnf if running on RHEL 7
install_dnf_if_needed() {
    if [[ $(cat /etc/redhat-release) == *"release 7."* ]]; then
        echo "RHEL 7 detected. Installing dnf..."
        sudo yum install -y dnf
    fi
}

# Ensure dnf is available
install_dnf_if_needed

# Base directory to store downloaded packages
BASE_DIR="offline_packages_rhel_${RHEL_VERSION}"
rm -rf $BASE_DIR
mkdir -p $BASE_DIR

# Ask whether to include RDP
read -p "Include RDP (xrdp)? (y/n) [n]: " INCLUDE_RDP
INCLUDE_RDP=${INCLUDE_RDP:-n}

# Ask whether to include Visual Studio Code
read -p "Include Visual Studio Code (VSCode)? (y/n) [n]: " INCLUDE_VSCODE
INCLUDE_VSCODE=${INCLUDE_VSCODE:-n}

# Function to download a package and its dependencies
download_package() {
    PACKAGE=$1
    DEST_DIR=$2
    echo "Downloading $PACKAGE into $DEST_DIR..."
    dnf download --resolve --destdir=$DEST_DIR $PACKAGE
}

# Download the EPEL release RPM
EPEL_URL="https://dl.fedoraproject.org/pub/epel/epel-release-latest-${RHEL_VERSION%%.*}.noarch.rpm"
EPEL_RPM="$BASE_DIR/epel-release-latest-${RHEL_VERSION%%.*}.noarch.rpm"
echo "Downloading EPEL repository RPM..."
curl -L -o "$EPEL_RPM" "$EPEL_URL"

# Handle RDP inclusion
if [[ $INCLUDE_RDP =~ ^[Yy]$ ]]; then
    echo "Including RDP..."
    RDP_DIR="$BASE_DIR/rdp"
    mkdir -p $RDP_DIR
    download_package "xrdp" $RDP_DIR
fi

# Handle Visual Studio Code inclusion
if [[ $INCLUDE_VSCODE =~ ^[Yy]$ ]]; then
    echo "Including Visual Studio Code..."
    VSCODE_DIR="$BASE_DIR/vscode"
    mkdir -p $VSCODE_DIR
    download_package "code" $VSCODE_DIR  # This assumes the VSCode repository is set up

    # Download the Bash Debug extension
    BASH_DEBUG_VERSION="0.3.9" # Adjust the version as needed
    BASH_DEBUG_URL="https://marketplace.visualstudio.com/_apis/public/gallery/publishers/rogalmic/vsextensions/bash-debug/$BASH_DEBUG_VERSION/vspackage"
    BASH_DEBUG_FILE="$VSCODE_DIR/bash-debug-$BASH_DEBUG_VERSION.vsix"
    
    echo "Downloading Bash Debug extension..."
    curl -L -o "$BASH_DEBUG_FILE" "$BASH_DEBUG_URL"

    # Download the TypeScript extension
    TYPESCRIPT_VERSION="4.5.20211217" # Adjust the version as needed
    TYPESCRIPT_URL="https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-vscode/vsextensions/vscode-typescript-next/$TYPESCRIPT_VERSION/vspackage"
    TYPESCRIPT_FILE="$VSCODE_DIR/vscode-typescript-next-$TYPESCRIPT_VERSION.vsix"
    
    echo "Downloading TypeScript extension..."
    curl -L -o "$TYPESCRIPT_FILE" "$TYPESCRIPT_URL"
fi

# Download other necessary packages
download_package "openssh" $BASE_DIR
download_package "asterisk" $BASE_DIR
download_package "nodejs" $BASE_DIR

# Compress the downloaded packages
tar -czvf "$BASE_DIR.tar.gz" -C "$BASE_DIR" .

# Cleanup
rm -rf $BASE_DIR

echo "Packages downloaded and compressed into $BASE_DIR.tar.gz"
