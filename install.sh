#!/usr/bin/env bash
set -e

# Zenith Conky Installer
# Minimalist Developer HUD for Linux Desktops

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}==============================================${NC}"
echo -e "${RED}         ZENITH CONKY INSTALLER               ${NC}"
echo -e "${CYAN}   Minimalist Developer HUD for Linux         ${NC}"
echo -e "${CYAN}==============================================${NC}\n"

# 1. Check & Install Conky if missing
if ! command -v conky &> /dev/null; then
    echo -e "${CYAN}[*] Conky not found. Installing conky-all...${NC}"
    sudo apt update && sudo apt install -y conky-all
else
    echo -e "${GREEN}[✓] Conky is already installed.${NC}"
fi

# 2. Detect default network interface
DEFAULT_IFACE=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5}' || echo "")
echo -e "${CYAN}[*] Detected primary network interface:${NC} ${DEFAULT_IFACE:-auto}"

# 3. Prepare Config Directory
CONKY_DIR="$HOME/.config/conky"
mkdir -p "$CONKY_DIR"

if [ -f "$CONKY_DIR/conky.conf" ]; then
    BACKUP_FILE="$CONKY_DIR/conky.conf.backup.$(date +%s)"
    echo -e "${CYAN}[*] Backing up existing config to:${NC} $BACKUP_FILE"
    cp "$CONKY_DIR/conky.conf" "$BACKUP_FILE"
fi

# 4. Copy & Customize Configuration
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cp "$SCRIPT_DIR/conky.conf" "$CONKY_DIR/conky.conf"

if [ -n "$DEFAULT_IFACE" ]; then
    sed -i "s/\${upspeed}/\${upspeed $DEFAULT_IFACE}/g" "$CONKY_DIR/conky.conf"
    sed -i "s/\${downspeed}/\${downspeed $DEFAULT_IFACE}/g" "$CONKY_DIR/conky.conf"
    sed -i "s/\${totalup}/\${totalup $DEFAULT_IFACE}/g" "$CONKY_DIR/conky.conf"
    sed -i "s/\${totaldown}/\${totaldown $DEFAULT_IFACE}/g" "$CONKY_DIR/conky.conf"
fi

# 5. Install Launcher Script & Configure XDG Autostart
cat << 'LAUNCHER' > "$CONKY_DIR/start_zenith.sh"
#!/usr/bin/env bash
# Wait for display server and desktop compositor to initialize
sleep 2

# Kill any existing conky instances
killall -q conky || true

# Launch Zenith Conky
exec /usr/bin/conky -c "$HOME/.config/conky/conky.conf"
LAUNCHER
chmod +x "$CONKY_DIR/start_zenith.sh"

# Configure XDG Autostart (compatible with Wayland and X11)
AUTOSTART_DIR="$HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"
cat << DESKTOP > "$AUTOSTART_DIR/zenith-conky.desktop"
[Desktop Entry]
Type=Application
Name=Zenith Conky HUD
Comment=Zenith Conky System Telemetry HUD
Exec=$CONKY_DIR/start_zenith.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=2
StartupNotify=false
Terminal=false
DESKTOP

# Clean up obsolete systemd user service if present
if [ -f "$HOME/.config/systemd/user/zenith-conky.service" ]; then
    systemctl --user disable --now zenith-conky.service 2>/dev/null || true
    rm -f "$HOME/.config/systemd/user/zenith-conky.service"
    systemctl --user daemon-reload 2>/dev/null || true
fi

# 6. Start Conky now
nohup "$CONKY_DIR/start_zenith.sh" >/dev/null 2>&1 &

echo -e "\n${GREEN}[✓] Zenith Conky installed and running successfully!${NC}"
echo -e "${CYAN}[*] Config file:${NC} ~/.config/conky/conky.conf"
echo -e "${CYAN}[*] Autostart entry:${NC} ~/.config/autostart/zenith-conky.desktop"
