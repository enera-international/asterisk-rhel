#!/bin/bash

# Backup the original SELinux config
sudo cp /etc/selinux/config /etc/selinux/config.bak

# Change SELinux mode to permissive in the config file
sudo sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

# Verify the change
grep SELINUX= /etc/selinux/config

# Set current mode to permissive (immediate effect)
sudo setenforce 0

echo "SELinux is now set to Permissive mode."
