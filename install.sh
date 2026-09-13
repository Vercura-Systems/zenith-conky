#!/usr/bin/env bash
# ==============================================================================
# Zenith Super-Machine Suite Installer
# Complete Setup: Conky HUD + Developer Terminal + System Performance Tuning
# GitHub: https://github.com/Vercura-Systems/zenith-conky
# ==============================================================================
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONFIGS_DIR="$SCRIPT_DIR/configs"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}======================================================${NC}"
echo -e "${RED}${BOLD}             ZENITH SUPER-MACHINE SUITE               ${NC}"
echo -e "${CYAN}      Developer HUD, Terminal Suite & System Tuning    ${NC}"
echo -e "${CYAN}======================================================${NC}\n"

# ------------------------------------------------------------------------------
# Component 1: Zenith Conky HUD
# ------------------------------------------------------------------------------
install_hud() {
    echo -e "${CYAN}[*] Installing Zenith Conky HUD...${NC}"

    # 1. Install Conky if missing
    if ! command -v conky &> /dev/null; then
        echo -e "  Installing conky-all..."
        sudo apt-get update && sudo apt-get install -y conky-all
    else
        echo -e "  ${GREEN}[✓] Conky is already installed.${NC}"
    fi

    # 2. Detect primary network interface
    DEFAULT_IFACE=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5}' || echo "")
    echo -e "  Detected primary network interface: ${BOLD}${DEFAULT_IFACE:-auto}${NC}"

    # 3. Setup Config Directory
    CONKY_DIR="$HOME/.config/conky"
    mkdir -p "$CONKY_DIR"

    if [ -f "$CONKY_DIR/conky.conf" ]; then
        cp "$CONKY_DIR/conky.conf" "$CONKY_DIR/conky.conf.backup.$(date +%s)"
    fi

    cp "$CONFIGS_DIR/conky.conf" "$CONKY_DIR/conky.conf"

    if [ -n "$DEFAULT_IFACE" ]; then
        sed -i "s/\${upspeed}/\${upspeed $DEFAULT_IFACE}/g" "$CONKY_DIR/conky.conf"
        sed -i "s/\${downspeed}/\${downspeed $DEFAULT_IFACE}/g" "$CONKY_DIR/conky.conf"
        sed -i "s/\${totalup}/\${totalup $DEFAULT_IFACE}/g" "$CONKY_DIR/conky.conf"
        sed -i "s/\${totaldown}/\${totaldown $DEFAULT_IFACE}/g" "$CONKY_DIR/conky.conf"
    fi

    # 4. Install Launcher Script
    cp "$SCRIPTS_DIR/start_zenith.sh" "$CONKY_DIR/start_zenith.sh"
    chmod +x "$CONKY_DIR/start_zenith.sh"

    # 5. Configure XDG Autostart (Wayland & X11 safe)
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

    # 6. Clean legacy systemd user service if present
    if [ -f "$HOME/.config/systemd/user/zenith-conky.service" ]; then
        systemctl --user disable --now zenith-conky.service 2>/dev/null || true
        rm -f "$HOME/.config/systemd/user/zenith-conky.service"
        systemctl --user daemon-reload 2>/dev/null || true
    fi

    # 7. Start Conky now
    nohup "$CONKY_DIR/start_zenith.sh" >/dev/null 2>&1 &
    echo -e "${GREEN}[✓] Zenith Conky HUD installed and running!${NC}\n"
}

# ------------------------------------------------------------------------------
# Component 2: Developer Terminal Suite
# ------------------------------------------------------------------------------
install_dev_suite() {
    echo -e "${CYAN}[*] Installing Developer Terminal Suite (Starship, LazyGit, Ripgrep, UV, Tmux)...${NC}"
    mkdir -p "$HOME/.local/bin"

    # Ensure ~/.local/bin is in PATH for this session
    export PATH="$HOME/.local/bin:$PATH"

    # 1. Starship Prompt
    if ! command -v starship &>/dev/null; then
        echo -e "  Installing Starship prompt..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
    fi
    mkdir -p "$HOME/.config"
    cp "$CONFIGS_DIR/starship.toml" "$HOME/.config/starship.toml"

    # 2. LazyGit
    if ! command -v lazygit &>/dev/null; then
        echo -e "  Installing LazyGit..."
        LAZYGIT_VER=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*' || echo "0.65.1")
        curl -sLo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VER}_Linux_x86_64.tar.gz"
        tar xf /tmp/lazygit.tar.gz -C "$HOME/.local/bin" lazygit
        rm -f /tmp/lazygit.tar.gz
        chmod +x "$HOME/.local/bin/lazygit"
    fi

    # 3. Ripgrep (rg)
    if ! command -v rg &>/dev/null; then
        echo -e "  Installing Ripgrep..."
        RG_VER=$(curl -s "https://api.github.com/repos/BurntSushi/ripgrep/releases/latest" | grep -Po '"tag_name": "\K[^"]*' || echo "14.1.0")
        curl -sLo /tmp/ripgrep.tar.gz "https://github.com/BurntSushi/ripgrep/releases/latest/download/ripgrep-${RG_VER}-x86_64-unknown-linux-musl.tar.gz"
        tar xf /tmp/ripgrep.tar.gz -C /tmp
        cp /tmp/ripgrep-${RG_VER}-x86_64-unknown-linux-musl/rg "$HOME/.local/bin/"
        rm -rf /tmp/ripgrep*
        chmod +x "$HOME/.local/bin/rg"
    fi

    # 4. uv (Python package manager)
    if ! command -v uv &>/dev/null; then
        echo -e "  Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="$HOME/.local/bin" sh
    fi

    # 5. Terminator Zenith Theme
    mkdir -p "$HOME/.config/terminator"
    cp "$CONFIGS_DIR/terminator.config" "$HOME/.config/terminator/config"

    # 6. Tmux Persistent Session Setup
    if ! command -v tmux &>/dev/null; then
        echo -e "  Installing tmux..."
        sudo apt-get install -y tmux 2>/dev/null || echo "Please install tmux via apt."
    fi
    cp "$CONFIGS_DIR/tmux.conf" "$HOME/.tmux.conf"
    mkdir -p "$HOME/.tmux/plugins"
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" 2>/dev/null || true
    fi
    for p in tmux-sensible tmux-resurrect tmux-continuum; do
        if [ ! -d "$HOME/.tmux/plugins/$p" ]; then
            git clone "https://github.com/tmux-plugins/$p" "$HOME/.tmux/plugins/$p" 2>/dev/null || true
        fi
    done

    # 7. Zsh Integration
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "starship init zsh" "$HOME/.zshrc"; then
            echo -e "  Adding modern CLI tools & Starship to ~/.zshrc..."
            cat << 'ZSH_SNIPPET' >> "$HOME/.zshrc"

# ─── Zenith Modern CLI Power Tools ────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

# Aliases
alias lg="lazygit"
alias top="btop"
alias rg="rg --smart-case"

# Starship prompt
eval "$(starship init zsh)"
ZSH_SNIPPET
        fi
    fi

    echo -e "${GREEN}[✓] Developer Terminal Suite installed!${NC}\n"
}

# ------------------------------------------------------------------------------
# Component 3: Performance Tuning & App Streamlining
# ------------------------------------------------------------------------------
install_performance() {
    echo -e "${CYAN}[*] Running System Performance Boost (zRAM 60%, BBR, VFS)...${NC}"
    sudo "$SCRIPTS_DIR/setup-supermachine.sh"
    echo -e "${GREEN}[✓] System performance optimizations applied!${NC}\n"
}

install_apps_cleanup() {
    echo -e "${CYAN}[*] Running App Streamlining & Snap Cleanup...${NC}"
    sudo "$SCRIPTS_DIR/manage-apps.sh"
    echo -e "${GREEN}[✓] App streamlining complete!${NC}\n"
}

# ------------------------------------------------------------------------------
# Menu / Mode Selector
# ------------------------------------------------------------------------------
case "$1" in
    --hud)
        install_hud
        ;;
    --dev)
        install_dev_suite
        ;;
    --perf)
        install_performance
        ;;
    --apps)
        install_apps_cleanup
        ;;
    --all|-y)
        install_hud
        install_dev_suite
        install_performance
        ;;
    *)
        echo "Please select what you would like to install:"
        echo "  1) Full Super-Machine Setup (HUD + Dev Terminal + Performance Tuning)"
        echo "  2) Zenith Conky HUD only"
        echo "  3) Developer Terminal Suite only (Starship, LazyGit, Ripgrep, Tmux, Terminator)"
        echo "  4) System Performance Tuning (zRAM zstd 60%, Google BBR, Sysctl)"
        echo "  5) App Streamlining & Snap Cleanup (VS Code .deb, Bruno, Snap purge)"
        echo "  q) Quit"
        echo ""
        read -p "Enter choice [1-5]: " choice
        case "$choice" in
            1)
                install_hud
                install_dev_suite
                install_performance
                ;;
            2)
                install_hud
                ;;
            3)
                install_dev_suite
                ;;
            4)
                install_performance
                ;;
            5)
                install_apps_cleanup
                ;;
            *)
                echo "Exiting."
                exit 0
                ;;
        esac
        ;;
esac

echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}      ZENITH SETUP COMPLETED SUCCESSFULLY!            ${NC}"
echo -e "${GREEN}======================================================${NC}"
