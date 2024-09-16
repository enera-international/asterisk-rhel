#!/bin/bash

# Exit on any error
set -e
set -u
set -o pipefail

echo "Select the features to install:"
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
echo "Enter the numbers separated by spaces (e.g., 1 3 4):"
read -p "> " features

# Function to install Asterisk
install_asterisk() {
    echo "Installing Asterisk..."
    sudo dnf install -y asterisk
}

# Function to install Asterisk from source
install_asterisk_from_soure() {
    echo "Installing Asterisk from source..."
    ./utilities/install_asterisk_online_from_source.sh
}

# Function to install Enera Asterisk API (with dependencies)
install_enera_asterisk_api() {
    echo "Installing Enera Asterisk API (with Node.js, Nginx, MongoDB, and npm packages)..."
    # installs nvm (Node Version Manager)
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    # download and install Node.js (you may need to restart the terminal)
    nvm install 20
    sudo dnf install -y nginx
    
    # Add MongoDB repository and install
    sudo tee /etc/yum.repos.d/mongodb-org-4.4.repo > /dev/null <<EOF
[mongodb-org-4.4]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/8/mongodb-org/4.4/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.4.asc
EOF
    sudo dnf install -y mongodb-org
    
    # Clone and install asterisk-api-server
    git clone https://github.com/enera-international/asterisk-api-server.git
    cd asterisk-api-server
    npm install
    cd ..
    
    # Clone and install asterisk-web-server
    git clone https://github.com/enera-international/asterisk-web-app.git
    cd asterisk-web-app
    npm install
    ./utilities/install_nginx.sh
    cd ..
}

# Function to install Samba
install_samba() {
    echo "Installing Samba..."
    sudo dnf install -y samba samba-client samba-common
    ./utilities/install_samba.sh
}

# Function to install RDP
install_rdp() {
    echo "Installing RDP..."
    sudo dnf install -y xrdp
}

# Function to install VSCode and extensions
install_vscode() {
    echo "Installing VSCode..."
    
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

    sudo dnf install -y code
    
    # Install VSCode extensions
    code --install-extension ms-vscode.vscode-typescript-tslint-plugin
    code --install-extension rogalmic.bash-debug
}

# Function to install RHEL Security Updates
install_rhel_security_updates() {
    echo "Installing RHEL Security Updates..."
    sudo dnf update --security -y
}

# Function to install all RHEL Updates
install_rhel_all_updates() {
    echo "Installing all RHEL Updates..."
    sudo dnf update -y
}

#install extra RHEL packages
sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm

# Process each selected feature
for feature in $features; do
    case $feature in
        1)
            install_asterisk
            ;;
        2)
            install_asterisk_from_source
            ;;
        3)
            install_enera_asterisk_api
            ;;
        4)
            install_samba
            ;;
        5)
            install_rdp
            ;;
        6)
            install_vscode
            ;;
        7)
            install_rhel_security_updates
            ;;
        8)
            install_rhel_all_updates
            ;;
        9)
            install_asterisk
            install_enera_asterisk_api
            install_rdp
            install_vscode
            install_rhel_security_updates
            install_rhel_all_updates
            ;;
        *)
            echo "Invalid option: $feature"
            ;;
    esac
done

sudo firewall-cmd --reload

echo "Installation complete."
