#!/usr/bin/env bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${RED}[*] Uninstalling Zenith Conky...${NC}"

# Stop Conky
killall conky 2>/dev/null || true

# Remove config
rm -f "$HOME/.config/conky/conky.conf"
rm -f "$HOME/.config/autostart/conky.desktop"

# Check for backup to restore
LATEST_BACKUP=$(ls -t "$HOME/.config/conky/conky.conf.backup."* 2>/dev/null | head -n 1 || echo "")
if [ -n "$LATEST_BACKUP" ]; then
    echo -e "${GREEN}[✓] Restoring previous configuration from: $LATEST_BACKUP${NC}"
    mv "$LATEST_BACKUP" "$HOME/.config/conky/conky.conf"
    conky --daemonize --pause=1 || true
else
    echo -e "${GREEN}[✓] Zenith Conky configuration removed.${NC}"
fi

echo -e "${GREEN}[✓] Uninstallation complete.${NC}"
