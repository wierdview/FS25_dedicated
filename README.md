# Ubuntu FS25 Dedicated Server Docker

A Docker container that runs Farming Simulator 25 Dedicated Server on Ubuntu 24.04 using Wine. This solution provides a complete environment with VNC access for installation and management.

## Prerequisites

- Docker and Docker Compose installed
- x86_64/amd64 architecture (ARM not supported)
- Farming Simulator 25 **non-Steam version** from [GIANTS Software](https://eshop.giants-software.com/)
- **Activation key required**: For the dedicated server
- 8-12GB RAM (depending on player count and mods)
- 40GB+ disk space
- Basic knowledge of Docker and command line

## Complete Setup Guide

### Step 1: Clone the Repository

```bash
git clone https://github.com/yourusername/ubuntu-fs25-server.git
cd ubuntu-fs25-server
```

### Step 2: Download Farming Simulator 25

1. Go to [GIANTS Software Downloads](https://eshop.giants-software.com/downloads.php)
2. Paste your Activation Key
3. Download the **ZIP version** (non Steam version!)
4. You should receive a file like `FarmingSimulator2025_some_version.zip`

### Step 3: Extract Game Files

Extract the downloaded ZIP file into the `installer/` directory:

```bash
# Create installer directory if it doesn't exist
mkdir -p installer
```

You should now have files like:
```
installer/
├── FarmingSimulator2025.exe
├── FarmingSimulator2025-1a.bin
├── FarmingSimulator2025-1b.bin
└── ... (more .bin files)
```

### Step 4: Configure Environment

1. Copy the example environment file:
```bash
cp .env.example .env
```

2. Edit `.env` to set your passwords:
```bash
nano .env
```

Important variables to change:
```env
# VNC password for remote desktop access
VNC_PASSWORD=YourSecureVNCPassword

# Web admin credentials for FS25 server management
WEB_USERNAME=admin
WEB_PASSWORD=YourSecureWebPassword

# In-game admin password
SERVER_ADMIN=YourGameAdminPassword
```

### Step 5: Build and Start the Container

```bash
# Build the Docker image manually:
docker compose build

# Start the container
docker compose up -d
```

### Step 6: Connect to VNC

Access the container's desktop environment:

**Option A - Web Browser (Recommended):**
- Open http://localhost:6080/vnc_auto.html in your browser
- Enter VNC password when prompted

**Option B - VNC Client:**
- Use any VNC client (RealVNC, TightVNC, etc.)
- Connect to `localhost:5900`
- Enter VNC password

### Step 7: Install Farming Simulator 25

1. Once connected via VNC, right-click on the desktop
2. Select **"Install FS25"** from the menu
3. Follow the installer:
   - Install to C:\FS25Server when prompted (make sure the files are installed into the root of FS25Server Directory
   - The installation will take 10-15 minutes

### Step 8: Activate the Game

**Important:** You must activate the game before running the dedicated server!

1. Right-click on the desktop
2. Select **"Run Game Client"** from the menu
3. When prompted, enter your activation key
4. Complete the activation process (it also may prompt to update, just click yes and wait for it to download the update)
5. The game may show errors about 3D acceleration - this is normal
6. Close the game after activation is complete. (close the script because game won't be able to run)

### Step 9: Start the Dedicated Server

**Option A - Restart Container (Recommended):**
```bash
docker compose restart
```
The server will start automatically if activation was successful.

**Option B - Manual Start:**
1. Right-click on desktop in VNC
2. Select **"Start FS25 Server"** from menu

### Step 10: Access Web Admin

Open http://localhost:8080 in your browser and log in with:
- Username: (from WEB_USERNAME in .env)
- Password: (from WEB_PASSWORD in .env)

## Managing Your Server

### Adding Mods

Place mod files in the `userdata/mods/` directory:
```bash
cp path/to/your-mod.zip userdata/mods/
```

OPTIONAL: Place savegame folders in the `userdata/` directory: (game saves them as Savegame1, Savegame2, etc..)


### Server Configuration

- **Web Admin**: http://localhost:8080 - Configure maps, settings, and monitor players, run the server
- **Game Settings**: Managed through web interface
- **Direct Access**: `userdata/dedicated_server/dedicatedServerConfig.xml`

### Viewing Logs

```bash
# Container logs
docker compose logs -f

# Game server logs
docker compose exec ubuntu-fs25-server tail -f /var/log/supervisor/fs25server.log
```

### Useful Commands

```bash
# Stop server
docker compose stop

# Start server
docker compose start

# Restart server
docker compose restart

# Access container shell
docker compose exec ubuntu-fs25-server bash

# Check server status
docker compose exec ubuntu-fs25-server supervisorctl status
```

## Port Configuration

| Port | Service | Description |
|------|---------|-------------|
| 5900 | VNC | Direct VNC access |
| 6080 | Web VNC | Browser-based VNC (noVNC) |
| 8080 | Web Admin | FS25 server management interface |
| 10823 | Game Server | FS25 game traffic (TCP/UDP) |

## Troubleshooting

### Common Issues and Solutions

#### "Data files corrupt" Error
- **Cause**: Game needs activation
- **Solution**: Run Game Client from Fluxbox menu and activate with your key

#### Server Won't Start
- Verify activation was successful
- Check logs: `docker compose exec ubuntu-fs25-server tail -f /var/log/supervisor/fs25server.log`

#### Can't Connect to VNC
- Check if ports are in use: `netstat -tulpn | grep -E '5900|6080'`
- Verify VNC password in `.env` file
- Try web browser access first

#### Web Admin Login Failed
- Check credentials in `.env` file
- Restart container after changing passwords
- Verify port 8080 is accessible

#### Performance Issues
- Increase memory limit in `docker-compose.yml`
- Reduce number of mods
- Check CPU usage: `docker stats`

### Advanced Troubleshooting

```bash
# Check all services status
docker compose exec ubuntu-fs25-server supervisorctl status

# View Wine errors
docker compose exec ubuntu-fs25-server tail -f /var/log/supervisor/fs25server.log | grep -i error

# Test Wine installation
docker compose exec ubuntu-fs25-server wine --version

# Check disk space
docker compose exec ubuntu-fs25-server df -h
```

## Data Persistence

All important data is preserved between container restarts:

| Directory | Contents | Description |
|-----------|----------|-------------|
| `./userdata/` | Game data | Mods, saves, settings, activation |
| `./userdata/mods/` | Mod files | Place .zip mod files here |
| `./userdata/dedicated_server/` | Server saves | Game progress and configuration |
| `./wine_registry/` | Wine data | Activation and registry data |
| `./installer/` | Game installer | Keep for reinstallation if needed |

## Security Considerations

1. **Change default passwords** in `.env` before first use
2. **Use strong passwords** for VNC and web admin
3. **Firewall rules**: Only expose necessary ports
4. **Regular backups**: Backup `userdata/` directory
5. **Monitor access**: Check web admin logs regularly

## License Requirements

⚠️ **Important**: You need TWO licenses:
1. One for the dedicated server
2. One for playing on the server (you can connect to the server from PlayStation, Xbox, Steam, Epic, you have to check the Crossplay option and mod compatiblity)

Server must be non-Steam version from GIANTS Software.

## Support and Resources

- [GIANTS Software Forum](https://forum.giants-software.com/)
- [FS25 Dedicated Server Documentation](https://www.farming-simulator.com/support.php)
- [Docker Documentation](https://docs.docker.com/)
- [Wine Documentation](https://www.winehq.org/documentation)

## Credits

- https://github.com/wine-gameservers/arch-fs25server git page
- Based on Ubuntu 24.04 and Wine
- Uses Supervisor for process management
- Includes noVNC for web-based access
- Inspired by various FS server Docker projects

---

**Note**: This is an unofficial Docker image. Farming Simulator 25 is a trademark of GIANTS Software.
