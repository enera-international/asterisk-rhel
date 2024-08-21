#!/bin/bash

# Update the system
echo "Updating system..."
sudo dnf update -y

# Install EPEL repository
echo "Enabling EPEL repository..."
sudo dnf install -y epel-release

# Install required tools
echo "Installing required tools..."
sudo dnf install -y wget xorriso genisoimage isomd5sum rsync yum-utils createrepo

# Manually install squashfs-tools if not available in the repository
echo "Checking for squashfs-tools..."
if ! command -v unsquashfs &> /dev/null; then
    echo "squashfs-tools not found, attempting manual installation..."
    wget http://mirror.centos.org/centos/7/os/x86_64/Packages/squashfs-tools-4.3-0.21.gitf4999fd.el7.x86_64.rpm
    sudo dnf install -y squashfs-tools-4.3-0.21.gitf4999fd.el7.x86_64.rpm
fi

# Verify installation
echo "Verifying installations..."
for tool in wget xorriso genisoimage squashfs-tools isomd5sum rsync createrepo; do
    if ! command -v $tool &> /dev/null; then
        echo "Error: $tool is not installed."
        exit 1
    fi
done

echo "All required tools have been successfully installed."
