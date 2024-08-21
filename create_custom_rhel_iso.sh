#!/bin/bash

# Variables
RHEL_VERSION=${1:-9.4}
ISO_NAME="rhel-${RHEL_VERSION}-x86_64-dvd.iso"
MOUNT_DIR="/mnt/rhel-iso"
WORK_DIR="/tmp/rhel-remaster"
CUSTOM_DIR="${WORK_DIR}/custom"
ISO_OUTPUT="rhel-${RHEL_VERSION}-custom.iso"
SOFTWARE_DIR="${WORK_DIR}/extra_packages"

# Function to clean up temporary files and directories
cleanup() {
    echo "Cleaning up..."
    if mountpoint -q "${MOUNT_DIR}"; then
        echo "Unmounting ISO..."
        sudo umount "${MOUNT_DIR}"
    fi
    echo "Removing temporary directories..."
    sudo rm -rf "${MOUNT_DIR}"
    echo "Cleanup completed."
}

# Trap to clean up on exit or error
trap cleanup EXIT

# Step 2: Prepare working directories
prepare_directories() {
    echo "Preparing directories..."
    sudo mkdir -p "${MOUNT_DIR}" "${CUSTOM_DIR}" "${SOFTWARE_DIR}"
    sudo mount -o loop "${ISO_NAME}" "${MOUNT_DIR}"
    sudo rsync -avz "${MOUNT_DIR}/" "${CUSTOM_DIR}/"
    sudo umount "${MOUNT_DIR}"
}

# Step 3: Add software packages (Asterisk, SSH server, RDP)
add_software() {
    
    echo "Adding software packages..."
    ORIGINAL_DIR=$(pwd)
    cd "${SOFTWARE_DIR}"
    
    # Install wget to fetch software
    sudo yum install -y wget
    
    # Download Asterisk source
    wget https://downloads.asterisk.org/pub/telephony/asterisk/asterisk-18-current.tar.gz
    
    # Add SSH server and RDP packages
    yumdownloader --resolve openssh-server
    yumdownloader --resolve xrdp
    
    # Copy software to ISO custom directory
    cp -r "${SOFTWARE_DIR}" "${CUSTOM_DIR}/Packages"
    cd "${ORIGINAL_DIR}"
}

# Step 4: Add custom installation script
add_installation_script() {
    echo "Adding custom installation script..."
    SCRIPT_PATH="${CUSTOM_DIR}/custom_install.sh"

    cat <<EOF > "${SCRIPT_PATH}"
#!/bin/bash
echo "Installing custom software packages..."

# Install Asterisk
tar -xzf /run/install/repo/Packages/asterisk-18-current.tar.gz -C /usr/src
cd /usr/src/asterisk-18*
./configure
make
make install
make config
make samples

# Enable SSH and RDP
yum localinstall -y /run/install/repo/Packages/openssh-server*.rpm
yum localinstall -y /run/install/repo/Packages/xrdp*.rpm
systemctl enable sshd
systemctl enable xrdp
# Configure SELinux for xrdp
chcon --type=bin_t /usr/sbin/xrdp
chcon --type=bin_t /usr/sbin/xrdp-sesman
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-port=5060/udp
firewall-cmd --permanent --add-port=5060/tcp
firewall-cmd --permanent --add-port=5061/tcp
firewall-cmd --permanent --add-port=10000-20000/udp
firewall-cmd --permanent --add-port=3389/tcp
firewall-cmd --reload

echo "Installation of custom software completed."
EOF

    chmod +x "${SCRIPT_PATH}"

    # Add custom installation script to the installation process
    ks_path="${CUSTOM_DIR}/isolinux/ks.cfg"
    echo "%post --interpreter=/bin/bash" >> "${ks_path}"
    echo "${SCRIPT_PATH}" >> "${ks_path}"
    echo "%end" >> "${ks_path}"
}

# Step 5: Create the new ISO
create_iso() {
    echo "Creating the new custom ISO..."
    sudo mkisofs -o "${ISO_OUTPUT}" -b isolinux/isolinux.bin -c isolinux/boot.cat \
    -no-emul-boot -boot-load-size 4 -boot-info-table -R -J -v -T "${CUSTOM_DIR}/"

    # Add the ISO checksum
    sudo implantisomd5 "${ISO_OUTPUT}"
}

# Main Script Execution
main() {
    cleanup
    prepare_directories
    add_software
    add_installation_script
    create_iso
    echo "Custom RHEL ISO has been created: ${ISO_OUTPUT}"
}

main
