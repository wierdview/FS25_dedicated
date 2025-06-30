#!/bin/bash

# VNC Password Setup Script
echo "=== VNC Password Setup ==="
echo

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then 
    echo "This script must be run as root or with sudo"
    exit 1
fi

# Prompt for password
echo "Enter new VNC password (6-8 characters):"
read -s password
echo

if [ ${#password} -lt 6 ] || [ ${#password} -gt 8 ]; then
    echo "ERROR: Password must be 6-8 characters long"
    exit 1
fi

# Create VNC directory if it doesn't exist
mkdir -p /home/fs25server/.vnc
chown fs25server:fs25server /home/fs25server/.vnc

# Set the password
su - fs25server -c "x11vnc -storepasswd '$password' /home/fs25server/.vnc/passwd"

if [ $? -eq 0 ]; then
    echo "VNC password set successfully!"
    echo "You may need to restart the container for changes to take effect."
else
    echo "ERROR: Failed to set VNC password"
    exit 1
fi