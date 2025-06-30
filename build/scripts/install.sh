#!/bin/bash
set -e

echo "=== FS25 Ubuntu Server Installation Script ==="

# Create VNC password file
mkdir -p /home/fs25server/.vnc
x11vnc -storepasswd fs25server /home/fs25server/.vnc/passwd

# Create necessary directories for FS25
mkdir -p /home/fs25server/Documents/My\ Games/FarmingSimulator2025
mkdir -p /home/fs25server/Documents/My\ Games/FarmingSimulator2025/dedicated_server
mkdir -p /home/fs25server/.wine
mkdir -p /opt/fs25/installer

# Download Visual C++ Redistributables for later installation
echo "Downloading Visual C++ Redistributables..."
cd /tmp
wget -q https://aka.ms/vs/17/release/vc_redist.x64.exe -O /opt/fs25/installer/vc_redist.x64.exe || echo "Warning: Could not download VC++ redistributables"

# Create a marker file to indicate first run
touch /opt/fs25/first_run

# Set proper permissions
chown -R fs25server:fs25server /home/fs25server
chown -R fs25server:fs25server /opt/fs25

echo "=== Installation script completed ==="
echo "=== Wine will be initialized on first container start ==="