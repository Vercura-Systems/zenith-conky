# Zenith Super-Machine & Developer HUD ⚡

> **A hyper-minimal developer telemetry HUD, terminal powerhouse, and Linux performance booster.**  
> Designed for clean workspaces, dark setups, and maximum developer productivity.

---

## 🌟 What is Zenith?

Zenith turns any standard Ubuntu/Debian installation into an elite, responsive developer workstation:

1. **Zenith Conky HUD**: A borderless, translucent hardware telemetry overlay. Pinned directly to the desktop layer so it stays visible even when triggering "Show Desktop" (<kbd>Win</kbd> + <kbd>D</kbd>).
2. **Developer Terminal Suite**: Instant setup for Starship prompt, Terminator dark theme, `lazygit`, `ripgrep`, `uv`, and persistent `tmux` sessions that restore your exact split-screen layouts across reboots.
3. **Kernel & Memory Boost**: 60% zRAM compressed swap (`zstd`), Google BBR TCP network acceleration, inotify file-watcher limits, and Snap storage optimization.

---

## 🚀 1-Liner Installation (New Machine Setup)

On any fresh machine, simply clone and run:

```bash
git clone https://github.com/Vercura-Systems/zenith-conky.git ~/.zenith-conky
cd ~/.zenith-conky
./install.sh
```

### Unattended / Scripted Mode:
```bash
./install.sh --all    # Installs HUD + Dev Suite + Performance Tuning
./install.sh --hud    # Installs Conky HUD only
./install.sh --dev    # Installs Terminal Suite & CLI tools only
./install.sh --perf   # Applies Kernel & zRAM performance tuning
./install.sh --apps   # Runs App Streamlining & Snap cleanup
```

---

## 🖥️ 1. Zenith Conky HUD

- **Window Anchor**: Configured as a native `desktop` window type. Compatible with GNOME Shell (Wayland & X11) and guaranteed not to minimize when pressing <kbd>Win</kbd> + <kbd>D</kbd>.
- **Autostart**: Powered by an XDG desktop entry (`~/.config/autostart/zenith-conky.desktop`) with display server stabilization delay.
- **Hardware Telemetry**:
  - Live CPU Load %, Frequency & Multi-core Graph
  - RAM & Swap usage micro-bars
  - Root NVMe storage telemetry
  - Auto-detected Network Upload & Download speeds
  - Top 5 real-time resource-consuming processes

---

## ⚡ 2. Terminal & CLI Power Suite

* **Starship Prompt**: Blazing-fast Rust-based prompt displaying Git branch & dirty state, runtime badges (Node.js, Python, Rust), execution time, and emerald/carmine status indicators.
* **Terminator Zenith Theme**: Obsidian `#090A0F` dark palette, hidden scrollbar, borderless geometry, and quick split shortcuts (<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>E</kbd> vertical, <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>O</kbd> horizontal).
* **Persistent Sessions (Tmux)**: Powered by `tmux-resurrect` and `tmux-continuum`. Automatically saves your open panes and working directories every 15 minutes and restores them after system reboot.
* **Modern CLI Stack**:
  * `lazygit` (`lg`): Terminal Git TUI
  * `ripgrep` (`rg`): Ultra-fast codebase search
  * `uv`: 100x faster Python virtual environments & pip replacement
  * `eza`: Modern `ls` with file icons and Git status
  * `bat`: Syntax-highlighted file viewing
  * `zoxide`: Smarter directory jumping (`z <folder>`)

---

## 🏎️ 3. Super-Machine Performance Tuning

Run the performance module via `sudo ./scripts/setup-supermachine.sh`:

- **zRAM Swap Expansion**: Allocates 60% of physical RAM as a compressed in-memory swap pool using `zstd`. Delivers ~24–28 GB effective memory with near-zero latency and zero SSD wear.
- **Google BBR Congestion Control**: Replaces legacy `cubic` with `bbr` + `fq` packet scheduler for faster throughput and lower latency over WiFi.
- **VFS Cache Pressure**: Tuned to `50` to retain directory inodes and file indexes in RAM longer.
- **Snap Bloat Reduction**: Enforces `refresh.retain=2` to purge gigabytes of dead revisions and eliminate loop devices.

---

## 📁 Repository Structure

```
zenith-conky/
├── configs/
│   ├── conky.conf              # Zenith HUD telemetry config
│   ├── starship.toml           # Zenith dark prompt with runtime & git badges
│   ├── terminator.config       # Minimalist Zenith dark terminal profile & shortcuts
│   └── tmux.conf               # Persistent session save/restore config
├── scripts/
│   ├── start_zenith.sh         # Conky launcher with Wayland/X11 display delay
│   ├── setup-supermachine.sh   # Kernel BBR, zRAM 60% zstd, sysctl tweaks
│   └── manage-apps.sh          # Snap cleanup, VS Code deb migration, Bruno setup
├── install.sh                  # Master interactive/automated installer
├── uninstall.sh                # Clean uninstaller
├── LICENSE
└── README.md
```

---

## 🗑️ Uninstallation

To remove Zenith Conky and restore any previous configuration:

```bash
cd ~/.zenith-conky
./uninstall.sh
```

---

## 📄 License

MIT License © 2026 Vercura Systems. Free for personal and commercial use.
