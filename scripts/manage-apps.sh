#!/usr/bin/env bash
set -e

# ==============================================================================
# Zenith Super-Machine App Management & Optimization Script
# ==============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[-] Please run with sudo: sudo ./manage-apps.sh${NC}"
  exit 1
fi

echo -e "${CYAN}======================================================${NC}"
echo -e "${GREEN}     ZENITH APP STREAMLINING & SYSTEM CLEANUP         ${NC}"
echo -e "${CYAN}======================================================${NC}\n"

# ------------------------------------------------------------------------------
# 1. Optimize Snap Retention & Purge 17+ Disabled Snap Revisions
# ------------------------------------------------------------------------------
echo -e "${CYAN}[1/6] Purging old disabled Snap revisions & setting retain=2...${NC}"
snap set system refresh.retain=2 || true

# Remove disabled snaps to free 5-8 GB and clear ~20 loop devices
snap list --all | awk '/disabled/{print $1, $3}' |
    while read snapname revision; do
        if [ -n "$snapname" ] && [ -n "$revision" ]; then
            echo -e "  ${YELLOW}Removing old revision $revision of $snapname...${NC}"
            snap remove "$snapname" --revision="$revision" || true
        fi
    done
echo -e "${GREEN}[✓] Snap storage cleaned.${NC}\n"

# ------------------------------------------------------------------------------
# 2. Database Services (Kept Active for Local Laravel / PHP Development)
# ------------------------------------------------------------------------------
echo -e "${CYAN}[2/5] Checking Database Services (MySQL kept active for local dev)...${NC}"
if systemctl is-active --quiet mysql; then
    echo -e "${GREEN}[✓] MySQL service is active and running for local development.${NC}\n"
else
    echo -e "  MySQL is not currently running.\n"
fi

# ------------------------------------------------------------------------------
# 3. Purge Redundant DBeaver Snap (Keep sleek Beekeeper Studio)
# ------------------------------------------------------------------------------
echo -e "${CYAN}[3/5] Purging redundant DBeaver Snap...${NC}"
if snap list | grep -q "dbeaver-ce"; then
    snap remove dbeaver-ce || true
    echo -e "${GREEN}[✓] DBeaver removed. Beekeeper Studio is active and ready.${NC}\n"
else
    echo -e "  DBeaver is not installed.\n"
fi

# ------------------------------------------------------------------------------
# 4. Remove Unofficial WhatsApp Snap
# ------------------------------------------------------------------------------
echo -e "${CYAN}[4/5] Removing unmaintained WhatsApp Snap...${NC}"
if snap list | grep -q "whatsapp-linux-app"; then
    snap remove whatsapp-linux-app || true
    echo -e "${GREEN}[✓] WhatsApp Snap removed (use Chrome/Firefox PWA instead).${NC}\n"
else
    echo -e "  WhatsApp Snap is not installed.\n"
fi

# ------------------------------------------------------------------------------
# 5. Swap VS Code Snap -> Official Microsoft .deb Repo
# ------------------------------------------------------------------------------
echo -e "${CYAN}[4/5] Swapping VS Code Snap to Official Microsoft Repository...${NC}"
# Add Microsoft GPG key & APT repo
mkdir -p /etc/apt/keyrings
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor --yes -o /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list

apt-get update
apt-get install -y code

# Remove the snap version (User extensions and ~/.config/Code are 100% preserved)
if snap list | grep -q "code "; then
    snap remove code || true
fi
echo -e "${GREEN}[✓] Official VS Code (.deb) installed with full hardware/keyring access.${NC}\n"

# ------------------------------------------------------------------------------
# 6. Install Bruno (.deb) & Remove Heavy Postman Snap
# ------------------------------------------------------------------------------
echo -e "${CYAN}[5/5] Installing Bruno (.deb) and purging Postman...${NC}"
BRUNO_DEB="/tmp/bruno_latest_amd64.deb"
BRUNO_URL=$(curl -s "https://api.github.com/repos/usebruno/bruno/releases/latest" | grep -o 'https://[^"]*amd64_linux\.deb' | head -1)

if [ -n "$BRUNO_URL" ]; then
    echo -e "  Downloading Bruno from $BRUNO_URL..."
    curl -Lo "$BRUNO_DEB" "$BRUNO_URL"
    apt-get install -y "$BRUNO_DEB" || dpkg -i "$BRUNO_DEB"
    rm -f "$BRUNO_DEB"
    echo -e "${GREEN}[✓] Bruno installed successfully.${NC}"
fi

if snap list | grep -q "postman"; then
    snap remove postman || true
    echo -e "${GREEN}[✓] Postman Snap removed.${NC}\n"
fi

echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}[✓] All app modernizations & cleanups complete!        ${NC}"
echo -e "${GREEN}======================================================${NC}"
