#!/bin/bash

# Exit on any error
set -e
set -u
set -o pipefail

# Create the main directory for the download
DOWNLOAD_DIR="offline_packages"
mkdir -p $DOWNLOAD_DIR

echo "Select the features to include in the download:"
echo "1) Asterisk from RHEL repository *"
echo "2) Asterisk source (alternative to 1, for customization) *"
echo "3) Enera Asterisk API *"
echo "4) Samba (for backward compatibility) (*)"
echo "5) RDP"
echo "6) VSCode (with Bash and TypeScript plugins)"
echo "7) RHEL Security Updates"
echo "8) Download All RHEL Updates"
echo "9) All features (with Asterisk alt 1)"
echo "* = required feature, (*) = required with old MC"
echo "Enter the numbers separated by spaces (e.g., 1 3 5):"
read -p "> " features

# Function to call each feature script
download_feature() {
    feature_name=$1
    echo "Downloading $feature_name..."
    ./utilities/download_${feature_name}.sh "$DOWNLOAD_DIR/$feature_name"
    echo "$feature_name downloaded."
}

# Process each selected feature
for feature in $features; do
    case $feature in
        1)
            download_feature "asterisk"
            ;;
        2)
            download_feature "asterisk_source"
            ;;
        3)
            download_feature "enera_asterisk_api"
            ;;
        4)
            download_feature "samba"
            ;;
        5)
            download_feature "rdp"
            ;;
        6)
            download_feature "vscode"
            ;;
        7)
            download_feature "rhel_security_updates"
            ;;
        8)
            download_feature "rhel_all_updates"
            ;;
        9)
            download_feature "asterisk"
            download_feature "enera_asterisk_api"
            download_feature "samba"
            download_feature "rdp"
            download_feature "vscode"
            download_feature "rhel_security_updates"
            download_feature "rhel_all_updates"
            ;;
        *)
            echo "Invalid option: $feature"
            ;;
    esac
done

# Create a compressed file for offline installation
tar -czvf offline_installation.tar.gz $DOWNLOAD_DIR

echo "Download complete. All selected features are saved in offline_installation.tar.gz."
