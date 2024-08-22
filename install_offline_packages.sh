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

# Define the tarball name
TARBALL="offline_packages_rhel_${RHEL_VERSION}.tar.gz"

# Define the extraction directory
EXTRACT_DIR="offline_packages_rhel_extract"

# Check if the tarball exists
if [ ! -f $TARBALL ]; then
    echo "Error: Tarball $TARBALL not found."
    exit 1
fi

# Create extraction directory if it doesn't exist
mkdir -p $EXTRACT_DIR

# Decompress the tarball
tar -xzvf $TARBALL -C $EXTRACT_DIR

# Install any EPEL RPM first
for rpm_file in $EXTRACT_DIR/epel-release*.rpm; do
    if [ -f "$rpm_file" ]; then
        echo "Installing EPEL repository RPM: $rpm_file"
        sudo dnf localinstall -y "$rpm_file"
    fi
done

# Install the general packages (SSH, Asterisk, Node.js)
sudo dnf localinstall -y $EXTRACT_DIR/*.rpm

# Set up the asterisk user and group
if ! id -u asterisk >/dev/null 2>&1; then
    echo "Creating asterisk user and group..."
    sudo groupadd asterisk
    sudo useradd -r -d /var/lib/asterisk -s /sbin/nologin -g asterisk asterisk
    sudo mkdir -p /var/lib/asterisk
    sudo chown asterisk:asterisk /var/lib/asterisk
    echo "asterisk user and group created with home directory /var/lib/asterisk."
else
    echo "asterisk user and group already exist."
fi

# Create and configure Asterisk systemd service
echo "Configuring Asterisk as a service..."

sudo bash -c 'cat <<EOF > /etc/systemd/system/asterisk.service
[Unit]
Description=Asterisk PBX and telephony daemon
After=network.target

[Service]
Type=simple
WorkingDirectory=/var/lib/asterisk
Environment=HOME=/var/lib/asterisk
ExecStart=/usr/sbin/asterisk -mqf -C /etc/asterisk/asterisk.conf
ExecStop=/usr/sbin/asterisk -rx "core stop now"
ExecReload=/usr/sbin/asterisk -rx "core reload"
Restart=always
RestartSec=10
User=asterisk
Group=asterisk
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemd to apply the new service
sudo systemctl daemon-reload

# Enable and start Asterisk service
sudo systemctl enable asterisk
sudo systemctl start asterisk

# Open firewall for Asterisk SIP (5060) and RTP (10000-20000) traffic
sudo firewall-cmd --permanent --add-port=5060/udp
sudo firewall-cmd --permanent --add-port=5060/tcp
sudo firewall-cmd --permanent --add-port=10000-20000/udp
sudo firewall-cmd --reload

# Install and configure RDP if the marker file exists
if [ -d "$EXTRACT_DIR/rdp" ]; then
    echo "Installing RDP (xrdp)..."
    sudo dnf localinstall -y $EXTRACT_DIR/rdp/*.rpm
    
    # Install GUI if not already installed
    if ! systemctl get-default | grep -q graphical.target; then
        echo "Installing GNOME desktop environment..."
        sudo dnf groupinstall -y "Server with GUI"
        sudo systemctl set-default graphical.target
        sudo systemctl isolate graphical.target
    fi
    
    # Enable and start xrdp service
    sudo systemctl enable xrdp
    sudo systemctl start xrdp

    # Allow RDP through firewall
    sudo firewall-cmd --permanent --add-port=3389/tcp
    sudo firewall-cmd --reload
    
    # Configure SELinux for xrdp
    if selinuxenabled; then
        sudo setsebool -P xrdp_can_connect_dbus 1
    fi
    
    # Optionally configure xrdp to use Xorg
    echo "Configuring xrdp to use Xorg..."
    sudo sed -i 's/^param=param=Xorg/param=Xorg/' /etc/xrdp/xrdp.ini
    sudo systemctl restart xrdp
fi

# Install Visual Studio Code and extensions if the marker file exists
if [ -d "$EXTRACT_DIR/vscode" ]; then
    echo "Installing Visual Studio Code (VSCode)..."
    sudo dnf localinstall -y $EXTRACT_DIR/vscode/*.rpm
    
    # Install the Bash Debug extension
    if [ -f "$EXTRACT_DIR/vscode/bash-debug-*.vsix" ]; then
        echo "Installing Bash Debug extension..."
        code --install-extension "$EXTRACT_DIR/vscode/bash-debug-*.vsix"
    fi

    # Install the TypeScript extension
    if [ -f "$EXTRACT_DIR/vscode/vscode-typescript-next-*.vsix" ]; then
        echo "Installing TypeScript extension..."
        code --install-extension "$EXTRACT_DIR/vscode/vscode-typescript-next-*.vsix"
    fi
fi

# Cleanup the extraction directory
rm -rf $EXTRACT_DIR

echo "Package installation completed."
