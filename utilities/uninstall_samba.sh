#!/bin/bash

# Save the current working directory
ORIGINAL_CWD=$(pwd)

# Define variables
SAMBA_SHARE_DIR="/srv/samba/linehandler"
SAMBA_CONF_FILE="/etc/samba/smb.conf"
SAMBA_SERVICE="smb"

# Stop and disable Samba services
echo "Stopping and disabling Samba services..."
sudo systemctl stop smb nmb
sudo systemctl disable smb nmb

# Remove the Samba share directory if it exists
if [ -d "$SAMBA_SHARE_DIR" ]; then
    echo "Removing Samba share directory at $SAMBA_SHARE_DIR..."
    sudo rm -rf $SAMBA_SHARE_DIR
else
    echo "Samba share directory $SAMBA_SHARE_DIR does not exist."
fi

# Restore the original Samba configuration file if backup exists
if [ -f "${SAMBA_CONF_FILE}.bak" ]; then
    echo "Restoring original Samba configuration from backup..."
    sudo mv ${SAMBA_CONF_FILE}.bak $SAMBA_CONF_FILE
else
    echo "No backup of the Samba configuration file found."
fi

# Uninstall Samba packages
echo "Uninstalling Samba packages..."
sudo dnf remove -y samba samba-client samba-common

# Clean up any residual configuration files
echo "Cleaning up residual configuration files..."
sudo rm -rf /var/lib/samba
sudo rm -rf /etc/samba

# Optionally remove SELinux context (if SELinux was configured for Samba)
if sestatus | grep -q "SELinux status:.*enabled"; then
    echo "Removing SELinux context for the Samba share directory..."
    sudo semanage fcontext -d "$SAMBA_SHARE_DIR"
    sudo restorecon -Rv /srv/samba
fi

echo "Samba uninstallation and cleanup completed."

# Return to the original working directory
cd $ORIGINAL_CWD
