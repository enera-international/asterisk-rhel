#!/bin/bash

# Create the main directory for the download
DOWNLOAD_DIR="offline_packages"
mkdir -p $DOWNLOAD_DIR

echo "Select the features to include in the download:"
echo "1) Asterisk"
echo "2) Enera Asterisk API (with Node.js, Nginx)"
echo "3) RDP"
echo "4) VSCode (with Bash and TypeScript plugins)"
echo "5) RHEL Security Updates"
echo "6) Download All Updates"
echo "7) All features"
echo "Enter the numbers separated by spaces (e.g., 1 3 4):"
read -p "> " features

# Function to call each feature script
download_feature() {
    feature_name=$1
    echo "Downloading $feature_name..."
    ./download_${feature_name}.sh "$DOWNLOAD_DIR/$feature_name"
    echo "$feature_name downloaded."
}

# Process each selected feature
for feature in $features; do
    case $feature in
        1)
            download_feature "asterisk"
            ;;
        2)
            download_feature "enera_asterisk_api"
            ;;
        3)
            download_feature "rdp"
            ;;
        4)
            download_feature "vscode"
            ;;
        5)
            download_feature "rhel_security_updates"
            ;;
        6)
            download_feature "rhel_all_updates"
            ;;
        7)
            download_feature "asterisk"
            download_feature "enera_asterisk_api"
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
