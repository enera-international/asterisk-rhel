#!/bin/bash

# Save the current working directory
ORIGINAL_CWD=$(pwd)

# Extract the Asterisk source
sudo tar zxvf asterisk-20-current.tar.gz
cd asterisk-20*/

# Install additional dependencies using the script provided by Asterisk
sudo contrib/scripts/install_prereq install

# Configure the build options
sudo ./configure

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

sudo firewall-cmd --zone=public --add-port=5060/tcp --permanent
sudo firewall-cmd --zone=public --add-port=5060/udp --permanent
sudo firewall-cmd --zone=public --add-port=10000-65535/udp --permanent

# Return to the original working directory
cd $ORIGINAL_CWD
