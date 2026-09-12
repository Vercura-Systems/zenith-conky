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

# 5. Enable Autostart
AUTOSTART_DIR="$HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"
cat << 'AUTOSTART' > "$AUTOSTART_DIR/conky.desktop"
[Desktop Entry]
Type=Application
Name=Zenith Conky
Exec=conky --daemonize --pause=1
StartupNotify=false
Terminal=false
Categories=System;Monitor;
AUTOSTART

# 6. Restart Conky
echo -e "${CYAN}[*] Reloading Conky process...${NC}"
killall conky 2>/dev/null || true
sleep 1
conky --daemonize --pause=1

echo -e "\n${GREEN}[✓] Zenith Conky installed and running successfully!${NC}"
echo -e "${CYAN}[*] Config file:${NC} ~/.config/conky/conky.conf"
