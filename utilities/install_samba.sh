#!/bin/bash

# Save the current working directory
ORIGINAL_CWD=$(pwd)

# Define variables
SAMBA_SHARE_DIR="/srv/samba/linehandler"
SAMBA_CONF_FILE="/etc/samba/smb.conf"
SAMBA_SERVICE="smb"

# Update the system and install Samba
echo "Updating system and installing Samba..."
sudo yum update -y
sudo yum install -y samba samba-client samba-common

# Create the Samba share directory
echo "Creating Samba share directory at $SAMBA_SHARE_DIR..."
sudo mkdir -p $SAMBA_SHARE_DIR

# Set permissions on the share directory
echo "Setting permissions on the Samba share directory..."
sudo chmod 2775 $SAMBA_SHARE_DIR
sudo chown nobody:nobody $SAMBA_SHARE_DIR

# Backup the existing Samba configuration file
echo "Backing up the existing Samba configuration file..."
sudo cp $SAMBA_CONF_FILE ${SAMBA_CONF_FILE}.bak

# Add the Samba share configuration to smb.conf
echo "Adding Samba share configuration to $SAMBA_CONF_FILE..."
sudo bash -c "cat >> $SAMBA_CONF_FILE" <<EOL

[linehandler]
   path = $SAMBA_SHARE_DIR
   writable = yes
   browsable = yes
   guest ok = yes
   create mask = 0664
   directory mask = 0775
EOL

# Set SELinux context for the Samba share directory (if SELinux is enabled)
if sestatus | grep -q "SELinux status:.*enabled"; then
    echo "Setting SELinux context for the Samba share directory..."
    sudo chcon -t samba_share_t $SAMBA_SHARE_DIR
fi

# Start and enable Samba services
echo "Starting and enabling Samba services..."
sudo systemctl start smb nmb
sudo systemctl enable smb nmb

# Test the Samba configuration
echo "Testing Samba configuration..."
sudo testparm

echo "Samba installation and configuration completed."

$ORIGINAL_CWD/utilities/firewall-add-port.sh public 445 tcp
$ORIGINAL_CWD/utilities/firewall-add-port.sh public 139 tcp
$ORIGINAL_CWD/utilities/firewall-add-port.sh public 137-138 udp

# Return to the original working directory
cd $ORIGINAL_CWD
