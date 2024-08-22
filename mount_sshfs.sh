#!/bin/bash

# Script to mount a remote directory over SSH using sshfs

# Prompt for the remote username
read -p "Enter the remote SSH username: " REMOTE_USER

# Prompt for the remote host
read -p "Enter the remote SSH host (e.g., 192.168.1.100 or remote.domain.com): " REMOTE_HOST

# Use /home/<username> as the remote path
REMOTE_PATH="/home/$REMOTE_USER"

# Set the default local mount point to the current directory with the remote host name
DEFAULT_LOCAL_MOUNT_POINT="$(pwd)/$REMOTE_HOST"

# Prompt for the local mount point, showing the default
read -p "Enter the local mount point (default: $DEFAULT_LOCAL_MOUNT_POINT): " LOCAL_MOUNT_POINT

# Use the default if no input is provided
LOCAL_MOUNT_POINT=${LOCAL_MOUNT_POINT:-$DEFAULT_LOCAL_MOUNT_POINT}

# Check if sshfs is installed
if ! command -v sshfs &> /dev/null
then
    echo "sshfs could not be found. Please install sshfs using 'sudo yum install sshfs' or 'sudo dnf install sshfs'."
    exit
fi

# Create the local mount point directory if it doesn't exist
if [ ! -d "$LOCAL_MOUNT_POINT" ]; then
    mkdir -p "$LOCAL_MOUNT_POINT"
    echo "Created mount point directory: $LOCAL_MOUNT_POINT"
fi

# Mount the remote directory
echo "Mounting $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH to $LOCAL_MOUNT_POINT..."
sshfs "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH" "$LOCAL_MOUNT_POINT"

# Check if the mount was successful
if mount | grep "$LOCAL_MOUNT_POINT" > /dev/null; then
    echo "Successfully mounted $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH to $LOCAL_MOUNT_POINT"
else
    echo "Failed to mount $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH"
    exit 1
fi

# Unmount function
unmount() {
    echo "Unmounting $LOCAL_MOUNT_POINT..."
    fusermount -u "$LOCAL_MOUNT_POINT"
    
    if [ $? -eq 0 ]; then
        echo "Successfully unmounted $LOCAL_MOUNT_POINT"
    else
        echo "Failed to unmount $LOCAL_MOUNT_POINT"
        exit 1
    fi
}

# Trap the exit signal to unmount the file system when the script is terminated
trap unmount EXIT

# Keep the script running to keep the mount alive
echo "Press Ctrl+C to unmount and exit the script."
while true; do
    sleep 1
done
