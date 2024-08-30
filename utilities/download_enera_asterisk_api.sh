#!/bin/bash

# Save the current working directory
ORIGINAL_CWD=$(pwd)

# Get the directory to save downloaded files
FEATURE_DIR=$1
mkdir -p $FEATURE_DIR

# Download Node.js, Nginx, MongoDB, and other dependencies
sudo dnf install -y dnf-plugins-core nodejs

# Add MongoDB repository and key
cat <<EOF | sudo tee /etc/yum.repos.d/mongodb-org-4.4.repo
[mongodb-org-4.4]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/4.4/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.4.asc
EOF

# Download MongoDB, Node.js, Nginx, and their dependencies
sudo dnf download --resolve --destdir=$FEATURE_DIR mongodb-org nodejs nginx httpd-tools

# Clone the public npm package enera-international/asterisk-api-server and package it
cd $FEATURE_DIR
git clone https://github.com/enera-international/asterisk-api-server.git
cd asterisk-api-server
npm install
cd ..
tar -czvf asterisk-api-server.tar.gz asterisk-api-server
rm -rf asterisk-api-server

# Clone the public npm package enera-international/asterisk-web-server and package it
cd $FEATURE_DIR
git clone https://github.com/enera-international/asterisk-web-app.git
cd asterisk-web-app
npm install
cd ..
tar -czvf asterisk-web-app.tar.gz asterisk-web-app
rm -rf asterisk-web-server

# Return to the original working directory
cd $ORIGINAL_CWD
