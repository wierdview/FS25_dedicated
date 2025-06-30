#!/bin/bash

# FS25 Game Client Runner Script (for activation)
echo "=== FS25 Game Client Launcher ==="
echo
echo "This will try to launch the full Farming Simulator 25 game client."
echo "Use this to activate your game with your product key."
echo
echo "IMPORTANT: You need a dedicated server license separate from your game license! (Non-Steam Client)."
echo
echo "NOTE: The game won't be able to run because it is being run in a container with no 3D acceleration but it will run the update process and activation process."

# Check if game is installed
if [ ! -f "/home/fs25server/.wine/drive_c/FS25Server/FarmingSimulator2025.exe" ]; then
    echo "ERROR: FS25 game client not found!"
    echo "Please install the game first using the 'Install FS25' option."
    echo
    echo "Press any key to exit..."
    read -n 1
    exit 1
fi

echo "Starting FS25 game client..."
echo
echo "When the game starts:"
echo "1. Enter your activation key when prompted"
echo "2. Complete the activation process"
echo "3. You can then close the game"
echo "4. After activation, use 'Start FS25 Server' to run the dedicated server"
echo
echo "Press any key to continue..."
read -n 1

# Set Wine environment
export WINEPREFIX="/home/fs25server/.wine"
export WINEDEBUG="-all"
export DISPLAY=":1"

# Change to game directory
cd /home/fs25server/.wine/drive_c/FS25Server

# Start the game client
echo
echo "Launching Farming Simulator 25..."
wine FarmingSimulator2025.exe

echo
echo "Game client closed."
echo "If activation was successful, you can now start the dedicated server."
echo
echo "Press any key to exit..."
read -n 1
