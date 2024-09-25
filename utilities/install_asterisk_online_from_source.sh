#!/bin/bash

# Save the current working directory
ORIGINAL_CWD=$(pwd)

# Install dependencies
sudo dnf install -y wget git gcc gcc-c++ make libxml2-devel sqlite-devel \
  uuid-devel jansson-devel openssl-devel ncurses-devel newt-devel \
  libogg-devel libvorbis-devel spandsp-devel libuuid-devel libedit-devel

# Create a directory for Asterisk
mkdir -p ~/asterisk && cd ~/asterisk

# Download Asterisk 18
wget $ASTERISK_URL
tar xzf $ASTERISK_FILENAME
cd $ASTERISK_BASEFILENAME/

# Install Asterisk (configure, build, and run menuselect)
sudo ./configure

# Run menuselect for interactive configuration
make menuselect

# Continue with the build process
make
sudo make install
sudo make config
sudo make install-logrotate

# Create Asterisk user and group
sudo useradd -r -s /sbin/nologin asterisk
sudo chown -R asterisk:asterisk /usr/local/lib/asterisk
sudo chown -R asterisk:asterisk /var/lib/asterisk
sudo chown -R asterisk:asterisk /etc/asterisk
sudo chown -R asterisk:asterisk /var/log/asterisk
sudo chown -R asterisk:asterisk /var/spool/asterisk

# Set up Asterisk to run as a service
sudo tee /etc/systemd/system/asterisk.service > /dev/null <<EOL
[Unit]
Description=Asterisk
After=network.target

[Service]
Type=simple
User=asterisk
Group=asterisk
ExecStart=/usr/local/sbin/asterisk -f
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL

# Enable and start the Asterisk service
sudo systemctl daemon-reload
sudo systemctl enable asterisk
sudo systemctl start asterisk

$ORIGINAL_CWD/utilities/firewall-add-port.sh public 5038 tcp
$ORIGINAL_CWD/utilities/firewall-add-port.sh public 5060 tcp
$ORIGINAL_CWD/utilities/firewall-add-port.sh public 5060 udp
$ORIGINAL_CWD/utilities/firewall-add-port.sh public 10000-65535 tcp

echo "Asterisk installation is complete."

# Return to the original working directory
cd $ORIGINAL_CWD
