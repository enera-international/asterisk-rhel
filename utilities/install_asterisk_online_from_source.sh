#!/bin/bash

# Save the current working directory
ORIGINAL_CWD=$(pwd)

# Install dependencies
sudo dnf group -y install "Development Tools"
sudo dnf -y install git wget vim  net-tools sqlite-devel psmisc ncurses-devel newt-devel libxml2-devel libtiff-devel gtk2-devel libtool libuuid-devel subversion kernel-devel crontabs cronie-anacron libedit libedit-devel
source utilities/install_jansson.sh
# Create a directory for Asterisk
cd /usr/src
mkdir -p ~/asterisk && cd ~/asterisk

# Download Asterisk 18
wget $ASTERISK_URL
tar xvfz $ASTERISK_FILENAME
rm -f $ASTERISK_FILENAME
cd $ASTERISK_BASEFILENAME/

# Install Asterisk (configure, build, and run menuselect)
./configure --libdir=/usr/lib64

# Run menuselect for interactive configuration
make menuselect

sudo contrib/scripts/get_mp3_source.sh
sudo ./contrib/scripts/install_prereq install

# Continue with the build process
sudo dnf install chkconfig -y
make
sudo make install
sudo make samples
sudo make config
sudo ldconfig
sudo rm /etc/rc.d/init.d/asterisk
sudo make install-logrotate

# Create Asterisk user and group
if ! id -u asterisk > /dev/null 2>&1; then
  sudo groupadd asterisk
    sudo useradd -r -d /var/lib/asterisk -g asterisk asterisk
    sudo usermod -aG audio,dialout asterisk
fi
sudo chown -R asterisk.asterisk /etc/asterisk /var/{lib,log,spool}/asterisk /usr/lib64/asterisk

# Update /etc/sysconfig/asterisk
sudo bash -c 'echo "AST_USER=\"asterisk\"" > /etc/sysconfig/asterisk'
sudo bash -c 'echo "AST_GROUP=\"asterisk\"" >> /etc/sysconfig/asterisk'

# Update /etc/asterisk/asterisk.conf
sudo bash -c 'echo "[general]" > /etc/asterisk/asterisk.conf'
sudo bash -c 'echo "runuser = asterisk ; The user to run as." >> /etc/asterisk/asterisk.conf'
sudo bash -c 'echo "rungroup = asterisk ; The group to run as." >> /etc/asterisk/asterisk.conf'

sudo mkdir -p /var/run/asterisk
sudo chown asterisk:asterisk /var/run/asterisk
sudo chmod 750 /var/run/asterisk

# Set up Asterisk to run as a service
sudo tee /etc/systemd/system/asterisk.service > /dev/null <<EOL
[Unit]
Description=Asterisk
After=network.target

[Service]
Type=simple
User=asterisk
Group=asterisk
ExecStartPre=/bin/mkdir -p /var/run/asterisk
ExecStartPre=/bin/chown asterisk:asterisk /var/run/asterisk
ExecStartPre=/bin/chmod 750 /var/run/asterisk
ExecStart=/usr/sbin/asterisk -f
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL

source ./utilities/enable_chan_sip.sh

# Enable and start the Asterisk service
sudo systemctl daemon-reload
sudo systemctl enable asterisk
sudo systemctl start asterisk

$ORIGINAL_CWD/utilities/firewall-add-port.sh public 5038 tcp
$ORIGINAL_CWD/utilities/firewall-add-port.sh public 5060 tcp
$ORIGINAL_CWD/utilities/firewall-add-port.sh public 5060 udp
$ORIGINAL_CWD/utilities/firewall-add-port.sh public 10000-65535 udp

echo "Asterisk installation is complete."

# Return to the original working directory
cd $ORIGINAL_CWD
