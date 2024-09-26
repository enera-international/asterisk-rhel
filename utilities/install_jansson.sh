#!/bin/bash

# Script to install Jansson from GitHub

# Switch to superuser
sudo -i <<EOF

# Navigate to the /usr/src directory
cd /usr/src/

# Clone the Jansson repository
git clone https://github.com/akheron/jansson.git

# Navigate into the cloned directory
cd jansson

# Prepare the build system
autoreconf -i

# Configure the build
./configure --prefix=/usr/

# Compile and install
make && make install

EOF

echo "Jansson installation completed successfully!"
