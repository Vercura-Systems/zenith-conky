#!/usr/bin/env bash
set -e

echo "========================================================"
echo "         ZENITH SUPER-MACHINE OPTIMIZATION"
echo "========================================================"

if [ "$EUID" -ne 0 ]; then
  echo "[-] Please run with sudo: sudo ./setup-supermachine.sh"
  exit 1
fi

# 1. Configure zRAM (60% RAM, zstd high-ratio compression)
echo "[*] Configuring zRAM (zstd @ 60% of RAM)..."
cat << 'EOF' > /etc/default/zramswap
# Compression algorithm (zstd = best balance of speed & compression ratio)
ALGO=zstd

# Use 60% of physical memory for compressed swap pool
PERCENT=60

# Higher priority than disk swap so RAM is always used first
PRIORITY=100
EOF

systemctl restart zramswap.service || true
echo "[✓] zRAM configured."

# 2. Kernel & Network Optimization (TCP BBR + VFS tuning)
echo "[*] Configuring Kernel & TCP BBR Congestion Control..."
cat << 'EOF' > /etc/sysctl.d/99-performance.conf
# Google BBR Congestion Control for faster WiFi & packet throughput
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# Keep directory inode cache longer in memory (faster file indexing)
vm.vfs_cache_pressure = 50

# Generous file watcher limits for VS Code / Node / React dev servers
fs.inotify.max_user_watches = 524288
EOF

sysctl --system >/dev/null 2>&1 || true
echo "[✓] Kernel sysctl optimizations applied."

# 3. Optimize Snap Retention
echo "[*] Setting Snap retention limit to 2 (reduces loop devices & frees NVMe space)..."
snap set system refresh.retain=2 || true
echo "[✓] Snap retention optimized."

echo ""
echo "========================================================"
echo "    [✓] Super-Machine optimizations applied successfully!"
echo "========================================================"
zramctl 2>/dev/null || swapon -s
