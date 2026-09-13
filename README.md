# Zenith Conky ⚡

> **A hyper-minimal, borderless developer HUD for Linux desktops.**  
> Designed for dark setups, ultra-wide displays, and clean workspaces.

---

## ✨ Features

- **Borderless & Transparent**: Pure ARGB visual compositing that floats seamlessly over any dark wallpaper.
- **Micro-Gauges & Telemetry**: Ultra-thin, high-contrast metric bars for CPU load, RAM, Swap, and NVMe disk space.
- **Real-Time CPU Load Graph**: Smooth hardware utilization graph without clunky frames or borders.
- **Dynamic Network Traffic**: Live upload and download speeds with automatic network interface detection.
- **Top Resource Consumers**: Real-time listing of top 5 active processes sorted by CPU and memory consumption.
- **Modern Clean Typography**: Uses Ubuntu Sans / monospace with subtle letter spacing and hierarchical color coding.

---

## 🚀 Quick Install (1-Liner)

Clone and run the automated installer:

```bash
git clone https://github.com/Vercura-Systems/zenith-conky.git ~/.zenith-conky
cd ~/.zenith-conky
./install.sh
```

The script will:
1. Ensure `conky` is installed on your machine.
2. Back up any existing `~/.config/conky/conky.conf`.
3. Auto-detect your primary network interface (`wlan0`, `eth0`, etc.).
4. Enable autostart on system boot.
5. Reload Conky immediately.

---

## 🎨 Customization

The configuration is written in modern Conky Lua (`~/.config/conky/conky.conf`).

### Changing Accent Colors

Open `~/.config/conky/conky.conf` and modify the color palette section:

```lua
    -- Color Palette
    default_color = '#EAEAEA',
    color0 = '#E11D48', -- Primary Accent (Default: African Coral / Carmine)
    color1 = '#FFFFFF', -- Crisp White (Values)
    color2 = '#8E8E98', -- Muted Slate (Labels)
    color3 = '#3A3A42', -- Separator Rule
    color4 = '#10B981', -- Emerald Green (Disk / Upload)
    color5 = '#38BDF8', -- Sky Cyan (RAM / Download)
```

* **Cyberpunk Cyan**: Set `color0 = '#00F0FF'`
* **Matrix Green**: Set `color0 = '#00FF66'`
* **Purple Royale**: Set `color0 = '#A855F7'`
* **Amber Flame**: Set `color0 = '#F59E0B'`

### Adjusting Screen Position

In the config header:
```lua
    alignment = 'top_left', -- Options: top_left, top_right, bottom_left, bottom_right
    gap_x = 45,             -- Horizontal margin in pixels
    gap_y = 50,             -- Vertical margin in pixels
```

---

## 🗑️ Uninstallation

To remove Zenith Conky and restore your previous config:

```bash
cd ~/.zenith-conky
./uninstall.sh
```

---

## 📄 License

MIT License © 2026 Chidera (odesigo). Free for personal and commercial use.
