#!/bin/bash

# Update the system
echo "Updating the system..."
sudo dnf update -y

# Install necessary dependencies
echo "Installing necessary dependencies..."
sudo dnf install -y wget gpg

# Add Microsoft repository
echo "Adding Microsoft repository..."
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

# Create a repository file
echo "Creating repository file..."
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

# Install VS Code
echo "Installing Visual Studio Code..."
sudo dnf install -y code

# Verify installation
if command -v code &> /dev/null; then
    echo "Visual Studio Code has been successfully installed."
else
    echo "Error: Visual Studio Code installation failed."
    exit 1
fi

