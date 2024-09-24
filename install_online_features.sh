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
echo "Enter the numbers separated by spaces (e.g., 1 3 5):"
read -p "> " features

# Function to install Asterisk
install_asterisk() {
    echo "Installing Asterisk..."
    sudo dnf install -y asterisk
    sudo systemctl daemon-reload
    sudo systemctl start asterisk
    sudo systemctl enable asterisk
    source ./utilities/firewall-add-port.sh public 5038 udp
    source ./utilities/firewall-add-port.sh public 5060 tcp
    source ./utilities/firewall-add-port.sh public 5060 udp
    source ./utilities/firewall-add-port.sh public 10000-65535 tcp
}

# Function to install Asterisk from source
install_asterisk_from_source() {
    echo "Installing Asterisk from source..."
    source ./utilities/install_asterisk_online_from_source.sh
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
    
    ORIGINAL_CWD=$(pwd)

    # Clone and install asterisk-api-server
    if [ -d "/srv/asterisk-api-server" ]; then
        sudo rm -rf /srv/asterisk-api-server
    fi
    sudo mkdir -p /srv/asterisk-api-server
    sudo chown -R rapidreach:rapidreach /srv/asterisk-api-server
    git clone https://github.com/enera-international/asterisk-api-server.git /srv/asterisk-api-server
    cd /srv/asterisk-api-server
    npm install
    npm run build
    sudo chmod -R 777 dist
    sudo semanage fcontext -a -t httpd_sys_content_t "/srv/asterisk-api-server(/.*)?"
    sudo restorecon -R /srv/asterisk-api-server

    
    # Clone and install asterisk-web-server  
    if [ -d "/srv/asterisk-web-app" ]; then
        sudo rm -rf /srv/asterisk-web-app
    fi
    sudo mkdir -p /srv/asterisk-web-app
    sudo chown -R rapidreach:rapidreach /srv/asterisk-web-app
    git clone https://github.com/enera-international/asterisk-web-app.git /srv/asterisk-web-app
    cd /srv/asterisk-web-app
    npm install
    npm run build
    sudo chmod -R 777 /srv /srv/asterisk-web-app
    sudo chown -R nginx:nginx /srv/asterisk-web-app
    sudo semanage fcontext -a -t httpd_sys_content_t "/srv/asterisk-web-app(/.*)?"
    sudo restorecon -R /srv/asterisk-web-app
    cd $ORIGINAL_CWD
    source ./utilities/install_nginx.sh
    source ./utilities/install_enera_api_service.sh
}

# Function to install Samba
install_samba() {
    echo "Installing Samba..."
    sudo dnf install -y samba samba-client samba-common
    source ./utilities/install_samba.sh
}

# Function to install RDP
install_rdp() {
    echo "Installing RDP..."
    sudo dnf install -y xrdp
    sudo systemctl enable xrdp --now
    source ./utilities/firewall-add-port.sh public 3389 tcp
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
sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
source ./utilities/firewall-add-port.sh public 22 tcp
source ./utilities/set_selinux_permissive.sh

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
