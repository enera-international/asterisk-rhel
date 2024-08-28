#!/bin/bash

echo "Select the features to install:"
echo "1) Asterisk"
echo "2) Enera Asterisk API (with Node.js, Nginx, MongoDB, and npm packages)"
echo "3) RDP"
echo "4) VSCode (with Bash and TypeScript plugins)"
echo "5) RHEL Security Updates"
echo "6) Download All Updates"
echo "7) All features"
echo "Enter the numbers separated by spaces (e.g., 1 3 4):"
read -p "> " features

# Function to install Asterisk
install_asterisk() {
    echo "Installing Asterisk..."
    sudo dnf install -y asterisk
}

# Function to install Enera Asterisk API (with dependencies)
install_enera_asterisk_api() {
    echo "Installing Enera Asterisk API (with Node.js, Nginx, MongoDB, and npm packages)..."
    sudo dnf install -y nodejs nginx
    
    # Add MongoDB repository and install
    sudo tee /etc/yum.repos.d/mongodb-org-4.4.repo > /dev/null <<EOF
[mongodb-org-4.4]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/4.4/x86_64/
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
    rm -rf asterisk-api-server
    
    # Clone and install asterisk-web-server
    git clone https://github.com/enera-international/asterisk-web-server.git
    cd asterisk-web-server
    npm install
    cd ..
    rm -rf asterisk-web-server
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

# Process each selected feature
for feature in $features; do
    case $feature in
        1)
            install_asterisk
            ;;
        2)
            install_enera_asterisk_api
            ;;
        3)
            install_rdp
            ;;
        4)
            install_vscode
            ;;
        5)
            install_rhel_security_updates
            ;;
        6)
            install_rhel_all_updates
            ;;
        7)
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

echo "Installation complete."
