#!/bin/bash

echo "==================================="
echo "  FS25 Installation Helper"
echo "==================================="
echo ""

# Check if installer exists
INSTALLER_PATH="/opt/fs25/installer/FarmingSimulator2025.exe"
if [ ! -f "$INSTALLER_PATH" ]; then
    echo "ERROR: FS25 installer not found!"
    echo ""
    echo "Please place the FS25 installer at:"
    echo "  $INSTALLER_PATH"
    echo ""
    echo "You can download it from:"
    echo "  https://www.farming-simulator.com/"
    echo ""
    echo "Press Enter to exit..."
    read
    exit 1
fi

echo "Found FS25 installer!"
echo ""
echo "IMPORTANT INSTALLATION NOTES:"
echo "1. Install to: C:\\FS25Server"
echo "2. Do NOT install desktop shortcuts"
echo "3. The installer may appear frozen - be patient!"
echo "4. NOTE: After Installation is done, press right click on the desktop and press on Run the Game Client, this is necessary to Activate your copy of the game with your Activation Key. (this part is very hard to automate)."
echo ""
echo "Press Enter to start installation..."
read

# Set Wine environment
export WINEARCH=win64
export WINEPREFIX=/home/fs25server/.wine
export WINEDEBUG=-all

# Create the installation directory in Wine
mkdir -p "$WINEPREFIX/drive_c/FS25Server"

# Run the installer
echo "Starting FS25 installer..."
wine "$INSTALLER_PATH"

# Check if installation succeeded
if [ -f "$WINEPREFIX/drive_c/FS25Server/dedicatedServer.exe" ]; then
    echo ""
    echo "Installation appears successful!"
    echo ""
    # Create symlink for easier access
    ln -sf "$WINEPREFIX/drive_c/FS25Server" /opt/fs25/game
    echo "Game files linked to /opt/fs25/game"
    echo ""
    echo "You can now:"
    echo "1. Close this window"
    echo "2. Restart the container"
    echo "3. The server will start automatically"
else
    echo ""
    echo "Installation may have failed!"
    echo "Please check if dedicatedServer.exe exists in C:\\FS25Server"
fi

echo ""
echo "Press Enter to exit..."
read
