#!/bin/bash

echo "=== Starting FS25 Dedicated Server ==="

# Check if we should only run VNC (game not installed yet)
if [ -f "/opt/fs25/.vnc_only" ]; then
    echo "VNC-only mode detected. Game not installed yet."
    echo "Please install the game using VNC at port 5900 or http://localhost:6080"
    echo "Sleeping to prevent restart loop..."
    sleep infinity  # Sleep forever until container is restarted
    exit 0
fi

# Set Wine environment
export WINEARCH=win64
export WINEPREFIX=/home/fs25server/.wine
export WINEDEBUG=-all
export DISPLAY=:1

# Check if game directory exists
GAME_DIR="/home/fs25server/.wine/drive_c/FS25Server"
if [ ! -d "${GAME_DIR}" ]; then
    echo "Game directory not found at ${GAME_DIR}"
    echo "Please install the game first using VNC."
    echo "Sleeping to prevent restart loop..."
    sleep infinity  # Sleep forever until container is restarted
    exit 0
fi

# Set working directory to the actual installation
cd "${GAME_DIR}"

# Server configuration
CONFIG_FILE="/opt/fs25/config/dedicatedServer.xml"

# Check if dedicatedServer.exe exists
if [ ! -f "dedicatedServer.exe" ]; then
    echo "ERROR: dedicatedServer.exe not found!"
    echo "Please install the game first using VNC."
    echo "Sleeping to prevent restart loop..."
    sleep infinity  # Sleep forever until container is restarted
    exit 0
fi

# Check if configuration exists
if [ ! -f "${CONFIG_FILE}" ]; then
    echo "ERROR: Server configuration not found at ${CONFIG_FILE}"
    echo "Server will create default configuration on first run."
fi

# Run the dedicated server
echo "Starting dedicated server..."
echo "Configuration: ${CONFIG_FILE}"
echo "Port: ${SERVER_PORT}"
echo "Max Players: ${SERVER_PLAYERS}"

# Note: dedicatedServer.xml in the game directory contains web admin config
# The game server config is passed as a parameter or managed by the server itself
echo "Web admin config is in ./dedicatedServer.xml"

# Start the server with Wine (let it use its own config)
echo "Starting dedicatedServer.exe..."
exec wine dedicatedServer.exe