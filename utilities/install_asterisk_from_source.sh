#!/bin/bash

ASTERISK_FILENAME=$1

# Save the current working directory
ORIGINAL_CWD=$(pwd)

# Extract the Asterisk source
sudo tar zxvf ASTERISK_FILENAME
cd $ASTERISK_FILENAME*/

# Install additional dependencies using the script provided by Asterisk
sudo contrib/scripts/install_prereq install

# Configure the build options
sudo ./configure --with-jansson-bundled

# Choose the modules to build
sudo make menuselect

# Build and install Asterisk
sudo make -j2
sudo make install

# Install sample configuration files (optional)
sudo make samples

# Install Asterisk service script
sudo make config
sudo ldconfig

# Set Asterisk to start on boot
sudo systemctl enable asterisk

# Start Asterisk
sudo systemctl start asterisk

# Verify that Asterisk is running
sudo systemctl status asterisk

$ORIGINAL_CWD/utilities/firewall-add-port.sh public 5060 tcp
$ORIGINAL_CWD/utilities/firewall-add-port.sh public 5060 udp
$ORIGINAL_CWD/utilities/firewall-add-port.sh public 10000-65535 tcp

# Return to the original working directory
cd $ORIGINAL_CWD
