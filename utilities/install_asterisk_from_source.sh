#!/bin/bash

ASTERISK_FILENAME=$1

# Extract the Asterisk source
sudo tar zxvf $ASTERISK_FILENAME.tar.gz
cd $ASTERISK_FILENAME*/

# Install additional dependencies using the script provided by Asterisk
sudo contrib/scripts/install_prereq install

# Configure the build options
echo "ENABLE_SIP=yes" > menuselect.makeopts
echo "ENABLE_PJSIP=no" >> menuselect.makeopts
sudo ./configure --with-jansson-bundled

# Choose the modules to build
sudo make menuselect

# Build and install Asterisk
sudo make -j2
sudo make install

# Install sample configuration files (optional)
sudo make samples

# Install Asterisk service script
sudo dnf install chkconfig -y
sudo make config
sudo ldconfig
sudo rm /etc/rc.d/init.d/asterisk
sudo cp $ORIGINAL_CWD/utilities/asterisk.service /etc/systemd/system
sudo systemctl daemon-reload

$ORIGINAL_CWD/utilities/firewall-add-port.sh public 5038 tcp
$ORIGINAL_CWD/utilities/firewall-add-port.sh public 5060 tcp
$ORIGINAL_CWD/utilities/firewall-add-port.sh public 5060 udp
$ORIGINAL_CWD/utilities/firewall-add-port.sh public 10000-65535 tcp

# Create the asterisk group if it doesn't exist
if ! getent group asterisk > /dev/null; then
    echo "Creating 'asterisk' group..."
    sudo groupadd asterisk
else
    echo "'asterisk' group already exists."
fi

# Create the asterisk user if it doesn't exist
if ! id -u asterisk > /dev/null 2>&1; then
    echo "Creating 'asterisk' user..."
    sudo useradd -r -d /var/lib/asterisk -s /sbin/nologin -c "Asterisk PBX" -g asterisk asterisk
    # Set appropriate ownership for Asterisk directories
    sudo mkdir -p /var/run/asterisk /var/log/asterisk /var/lib/asterisk /var/spool/asterisk /var/tmp/asterisk
    sudo chown -R asterisk:asterisk /var/run/asterisk /var/log/asterisk /var/lib/asterisk /var/spool/asterisk /var/tmp/asterisk
else
    echo "'asterisk' user already exists."
fi

# Set Asterisk to start on boot
sudo systemctl enable asterisk

# Start Asterisk
sudo systemctl start asterisk

# Verify that Asterisk is running
sudo systemctl status asterisk
