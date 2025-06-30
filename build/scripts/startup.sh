#!/bin/bash

echo "=== Starting FS25 Ubuntu Server ==="

# Update user and group IDs if provided
if [ -n "${PUID}" ] && [ -n "${PGID}" ]; then
    echo "Updating user fs25server to UID: ${PUID}, GID: ${PGID}"
    groupmod -g "${PGID}" fs25server
    usermod -u "${PUID}" -g "${PGID}" fs25server
    chown -R fs25server:fs25server /home/fs25server /opt/fs25
fi

# Update VNC password if provided
if [ -n "${VNC_PASSWORD}" ]; then
    mkdir -p /home/fs25server/.vnc
    su - fs25server -c "x11vnc -storepasswd ${VNC_PASSWORD} /home/fs25server/.vnc/passwd"
fi

# Ensure helper scripts are executable
chmod +x /home/fs25server/*.sh 2>/dev/null
chmod +x /home/fs25server/.fluxbox/startup 2>/dev/null
chown -R fs25server:fs25server /home/fs25server

# Create first run marker if not exists
if [ ! -f "/opt/fs25/.initialized" ]; then
    touch /opt/fs25/first_run
    chown fs25server:fs25server /opt/fs25/first_run
fi

# Create server configuration from environment variables
CONFIG_FILE="/opt/fs25/config/dedicatedServer.xml"
if [ "${ENABLE_STARTUP_SCRIPTS}" = "yes" ] && [ ! -f "${CONFIG_FILE}" ]; then
    echo "Creating initial server configuration..."
    cat > "${CONFIG_FILE}" << EOF
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<gameserver>
    <settings>
        <game>
            <name>${SERVER_NAME}</name>
            <password></password>
            <admin_password>admin</admin_password>
            <mapName>${SERVER_MAP}</mapName>
            <difficulty>${SERVER_DIFFICULTY}</difficulty>
            <pauseGameIfEmpty>${SERVER_PAUSE_EMPTY}</pauseGameIfEmpty>
            <savegame>${SERVER_SAVEGAME:-1}</savegame>
            <saveInterval>${SERVER_SAVE_INTERVAL}</saveInterval>
            <statsInterval>${SERVER_STATS_INTERVAL}</statsInterval>
            <allowCrossPlay>${SERVER_CROSSPLAY}</allowCrossPlay>
        </game>
        <network>
            <port>${SERVER_PORT}</port>
            <maxPlayers>${SERVER_PLAYERS}</maxPlayers>
            <language>${SERVER_REGION}</language>
        </network>
    </settings>
</gameserver>
EOF
    chown fs25server:fs25server "${CONFIG_FILE}"
fi

# Create marker files to indicate what services to start
if [ ! -f "/home/fs25server/.wine/drive_c/FS25Server/dedicatedServer.exe" ]; then
    echo "WARNING: Game not found at /home/fs25server/.wine/drive_c/FS25Server/dedicatedServer.exe"
    echo "Please install the game using VNC first!"
    echo "Connect to VNC at port 5900 or Web VNC at http://localhost:6080"
    touch /opt/fs25/.vnc_only
else
    echo "Game found, will start all services..."
    rm -f /opt/fs25/.vnc_only
    # Ensure fs25server owns the Wine directory
    chown -R fs25server:fs25server /home/fs25server/.wine
    
    # Don't overwrite dedicatedServer.xml anymore
    # The server manages its own config
fi

# Create or update web admin configuration
# The dedicatedServer.xml needs to be in the game directory for the web admin to work
if [ "${ENABLE_STARTUP_SCRIPTS}" = "yes" ]; then
    # Only create web admin config if game is installed
    if [ -d "/home/fs25server/.wine/drive_c/FS25Server" ]; then
        WEBADMIN_CONFIG="/home/fs25server/.wine/drive_c/FS25Server/dedicatedServer.xml"
        echo "Configuring web admin interface..."
        
        # Set default values if not provided
        WEB_USERNAME="${WEB_USERNAME:-admin}"
        WEB_PASSWORD="${WEB_PASSWORD:-fs25}"
        
        # Create the web admin configuration file
        cat > "${WEBADMIN_CONFIG}" << EOF
<?xml version="1.0" encoding="utf-8" standalone="no" ?>
<server>
    <webserver port="8080">
        <initial_admin>
            <username>${WEB_USERNAME}</username>
            <passphrase>${WEB_PASSWORD}</passphrase>
        </initial_admin>
        <tls port="8443" active="false">
            <certificate>cert.pem</certificate>
            <privatekey>pk.pem</privatekey>
        </tls>
    </webserver>
    <game description="Farming Simulator 25" name="FarmingSimulator2025" exe="FarmingSimulator2025Game.exe">
    </game>
</server>
EOF
        
        # Ensure proper ownership
        chown fs25server:fs25server "${WEBADMIN_CONFIG}"
        
        echo "Web admin configured - Username: ${WEB_USERNAME}, Port: 8080"
        
        # Also copy to /opt/fs25 for reference
        cp "${WEBADMIN_CONFIG}" "/opt/fs25/dedicatedServer.xml"
        chown fs25server:fs25server "/opt/fs25/dedicatedServer.xml"
    fi
fi

echo "Startup script completed"