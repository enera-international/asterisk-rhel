#!/bin/bash

# Define the path to modules.conf
MODULES_CONF="/etc/asterisk/modules.conf"

# Check if noload => chan_sip.so exists and comment it out
if grep -q "^noload = chan_sip.so" "$MODULES_CONF"; then
    echo "Commenting out noload = chan_sip.so in $MODULES_CONF."
    sudo sed -i 's/^noload = chan_sip.so/;noload = chan_sip.so/' "$MODULES_CONF"
else
    echo "noload = chan_sip.so not found in $MODULES_CONF."
fi

# Restart Asterisk to apply changes
sudo systemctl restart asterisk

echo "Asterisk has been restarted to apply changes."
