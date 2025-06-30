#!/bin/bash

# FS25 Server Start Helper Script
echo "=== Starting FS25 Dedicated Server ==="
echo

# Check if game is installed
if [ ! -f "/home/fs25server/.wine/drive_c/FS25Server/dedicatedServer.exe" ]; then
    echo "ERROR: FS25 dedicated server not found!"
    echo "Please install the game first using the 'Install FS25' option."
    echo
    echo "Press any key to exit..."
    read -n 1
    exit 1
fi

# Check if server is already running
if pgrep -f "dedicatedServer.exe" > /dev/null; then
    echo "WARNING: FS25 server appears to be already running!"
    echo "Do you want to stop it and start a new instance? (y/n)"
    read -n 1 response
    if [ "$response" = "y" ] || [ "$response" = "Y" ]; then
        echo
        echo "Stopping existing server..."
        pkill -f "dedicatedServer.exe"
        sleep 2
    else
        echo
        echo "Exiting without starting new server."
        exit 0
    fi
fi

echo "Starting FS25 dedicated server..."
echo "Configuration: /opt/fs25/config/dedicatedServer.xml"
echo
echo "Server will run in this terminal. Press Ctrl+C to stop."
echo

# Start the server
cd /home/fs25server/.wine/drive_c/FS25Server
export WINEPREFIX="/home/fs25server/.wine"
export WINEDEBUG="-all"
export DISPLAY=":1"
wine dedicatedServer.exe