#!/bin/bash
# Custom Server OS - Root Filesystem Builder
# Creates minimal root filesystem with busybox

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Directories
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BUILD_DIR="${PROJECT_ROOT}/build"
ROOTFS_DIR="${BUILD_DIR}/rootfs"
KERNEL_OUTPUT="${BUILD_DIR}/kernel-output"

echo -e "${GREEN}=== Building Root Filesystem ===${NC}"

# Create rootfs structure
echo -e "${YELLOW}Creating directory structure...${NC}"
mkdir -p "${ROOTFS_DIR}"/{bin,sbin,etc,proc,sys,dev,tmp,var,usr/{bin,sbin,lib},lib,lib64,home,root,mnt,opt}

# Set permissions
chmod 1777 "${ROOTFS_DIR}/tmp"

# Device nodes will be created by devtmpfs at boot
echo -e "${YELLOW}Device nodes will be created by devtmpfs at boot...${NC}"

# Check if busybox is already installed
if [ ! -f "${ROOTFS_DIR}/bin/busybox" ]; then
    echo -e "${YELLOW}Busybox not found in rootfs. Please install it manually.${NC}"
    echo "Run: cd ${BUILD_DIR} && wget -O busybox https://busybox.net/downloads/binaries/1.35.0-x86_64-linux-musl/busybox"
    echo "Then: cp busybox rootfs/bin/ && cd rootfs/bin && ./busybox --install -s ."
    exit 1
fi

# Copy kernel modules
if [ -d "${KERNEL_OUTPUT}/lib/modules" ]; then
    echo -e "${YELLOW}Copying kernel modules...${NC}"
    cp -r "${KERNEL_OUTPUT}/lib/modules" "${ROOTFS_DIR}/lib/"
fi

# Create init script
echo -e "${YELLOW}Creating init script...${NC}"
cat > "${ROOTFS_DIR}/init" << 'EOF'
#!/bin/sh
# Enhanced init script for Custom Server OS
# With detailed debugging output

echo "=========================================="
echo "  Custom Server OS - Init Starting"
echo "=========================================="
echo ""

# Function to print with timestamp
log() {
    echo "[INIT] $1"
}

log "Step 1: Mounting essential filesystems..."

# Mount proc
log "Mounting /proc..."
mount -t proc proc /proc || log "ERROR: Failed to mount /proc"

# Mount sysfs
log "Mounting /sys..."
mount -t sysfs sysfs /sys || log "ERROR: Failed to mount /sys"

# Mount devtmpfs
log "Mounting /dev..."
mount -t devtmpfs devtmpfs /dev || log "ERROR: Failed to mount /dev"

log "Essential filesystems mounted successfully!"

# Create additional device nodes if needed
log "Step 2: Creating device nodes..."
mknod /dev/null c 1 3 2>/dev/null || log "WARNING: /dev/null already exists"
mknod /dev/console c 5 1 2>/dev/null || log "WARNING: /dev/console already exists"
mknod /dev/tty c 5 0 2>/dev/null || log "WARNING: /dev/tty already exists"

log "Step 3: Setting up environment..."
export PATH=/bin:/sbin:/usr/bin:/usr/sbin
export HOME=/root
export TERM=linux

log "Step 4: Mounting additional filesystems..."
mount -t tmpfs tmpfs /tmp 2>/dev/null || log "WARNING: Failed to mount /tmp"
mount -t tmpfs tmpfs /var 2>/dev/null || log "WARNING: Failed to mount /var"

# Create necessary directories
log "Creating system directories..."
mkdir -p /var/log /var/run /var/lock /var/tmp 2>/dev/null

log "Step 5: Setting up network..."
# Bring up loopback
ip link set lo up 2>/dev/null || log "WARNING: Failed to bring up loopback"
ip addr add 127.0.0.1/8 dev lo 2>/dev/null || log "WARNING: Failed to set loopback address"

# Detect and configure network interfaces
log "Detecting network interfaces..."
for iface in $(ls /sys/class/net/ | grep -v lo); do
    log "Found interface: $iface"
    ip link set $iface up 2>/dev/null && log "  Brought up $iface" || log "  WARNING: Failed to bring up $iface"
done

# Try to get IP via DHCP on eth0 (if exists)
if [ -d /sys/class/net/eth0 ]; then
    log "Attempting DHCP on eth0..."
    udhcpc -i eth0 -n -q -t 5 2>/dev/null && log "  DHCP successful on eth0" || log "  WARNING: DHCP failed on eth0"
fi

# Show network status
log "Network interfaces status:"
ip addr show 2>/dev/null | grep -E "^[0-9]+:|inet " | sed 's/^/  /'

log "Step 6: System information..."
log "Kernel: $(uname -r)"
log "Architecture: $(uname -m)"
log "Hostname: $(hostname)"
log "Uptime: $(cut -d' ' -f1 /proc/uptime)s"
log "Memory: $(free -m | awk 'NR==2{printf "%s/%sMB (%.0f%%)", $3,$2,$3*100/$2}')"
log "Available commands: $(ls /bin | wc -l) binaries in /bin"

# Show boot summary
echo ""
echo "=========================================="
echo "  Boot Summary"
echo "=========================================="
echo "  Kernel:    $(uname -r)"
echo "  Hostname:  $(hostname)"
echo "  Memory:    $(free -m | awk 'NR==2{printf "%sMB total", $2}')"
echo "  Network:   $(ip -o link show | grep -v lo | wc -l) interface(s) detected"
echo "=========================================="

echo ""
echo "=========================================="
echo "  Custom Server OS - Linux Edition"
echo "  Based on Linux Kernel 6.12.28"
echo "=========================================="
echo ""
echo "System initialized successfully!"
echo ""
echo "Available commands:"
echo "  System: ls, cat, ps, top, free, df, mount, sysinfo"
echo "  Network: ip, ping, nettest, wget, curl"
echo "  Management: service, psinfo, diskusage, update-system"
echo "  Editors: vi, nano"
echo "  Utils: grep, find, tar, gzip"
echo ""
echo "Network management:"
echo "  service network {start|stop|restart|status}"
echo "  nettest - Run network connectivity test"
echo ""
echo "System information:"
echo "  sysinfo - Display detailed system information"
echo "  psinfo - Process information and management"
echo "  diskusage - Disk usage information"
echo ""
echo "Type 'help' for busybox command list"
echo "Type 'uname -a' for kernel information"
echo ""
echo "Login: root (no password required)"
echo ""

# Start interactive shell
log "Starting shell..."
exec /bin/sh
EOF

chmod +x "${ROOTFS_DIR}/init"

# Create fstab
echo -e "${YELLOW}Creating /etc/fstab...${NC}"
cat > "${ROOTFS_DIR}/etc/fstab" << 'EOF'
# <file system> <mount point> <type> <options> <dump> <pass>
proc            /proc         proc   defaults  0      0
sysfs           /sys          sysfs  defaults  0      0
devtmpfs        /dev          devtmpfs defaults 0     0
tmpfs           /tmp          tmpfs  defaults  0      0
EOF

# Create hostname
echo "custom-server-os" > "${ROOTFS_DIR}/etc/hostname"

# Create hosts file
cat > "${ROOTFS_DIR}/etc/hosts" << 'EOF'
127.0.0.1   localhost
127.0.1.1   custom-server-os
::1         localhost ip6-localhost ip6-loopback
EOF

# Create passwd
cat > "${ROOTFS_DIR}/etc/passwd" << 'EOF'
root:x:0:0:root:/root:/bin/sh
EOF

# Create group
cat > "${ROOTFS_DIR}/etc/group" << 'EOF'
root:x:0:
EOF

# Create inittab (if using busybox init)
cat > "${ROOTFS_DIR}/etc/inittab" << 'EOF'
::sysinit:/etc/init.d/rcS
::respawn:/sbin/getty 38400 tty1
::ctrlaltdel:/sbin/reboot
::shutdown:/bin/umount -a -r
EOF

# Create network interfaces
mkdir -p "${ROOTFS_DIR}/etc/network"
cat > "${ROOTFS_DIR}/etc/network/interfaces" << 'EOF'
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF

# Create network management scripts
echo -e "${YELLOW}Creating network management scripts...${NC}"
mkdir -p "${ROOTFS_DIR}/etc/init.d"

# Network startup script
cat > "${ROOTFS_DIR}/etc/init.d/network" << 'EOF'
#!/bin/sh
# Network initialization script

case "$1" in
    start)
        echo "Starting network..."
        # Bring up loopback
        ip link set lo up
        ip addr add 127.0.0.1/8 dev lo

        # Bring up all interfaces
        for iface in $(ls /sys/class/net/ | grep -v lo); do
            echo "  Configuring $iface..."
            ip link set $iface up

            # Try DHCP
            if [ "$iface" = "eth0" ]; then
                udhcpc -i $iface -n -q -t 5 &
            fi
        done
        ;;
    stop)
        echo "Stopping network..."
        for iface in $(ls /sys/class/net/ | grep -v lo); do
            ip link set $iface down
        done
        ;;
    restart)
        $0 stop
        sleep 1
        $0 start
        ;;
    status)
        echo "Network interfaces:"
        ip addr show
        echo ""
        echo "Routing table:"
        ip route show
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac
EOF

chmod +x "${ROOTFS_DIR}/etc/init.d/network"

# Create helper script for network testing
cat > "${ROOTFS_DIR}/usr/bin/nettest" << 'EOF'
#!/bin/sh
# Network connectivity test script

echo "=== Network Connectivity Test ==="
echo ""

# Test loopback
echo "1. Testing loopback (127.0.0.1)..."
if ping -c 1 -W 2 127.0.0.1 >/dev/null 2>&1; then
    echo "   ✓ Loopback OK"
else
    echo "   ✗ Loopback FAILED"
fi

# Show interfaces
echo ""
echo "2. Network interfaces:"
ip addr show | grep -E "^[0-9]+:|inet " | sed 's/^/   /'

# Show routes
echo ""
echo "3. Routing table:"
ip route show | sed 's/^/   /'

# Test gateway
echo ""
echo "4. Testing gateway..."
GATEWAY=$(ip route | grep default | awk '{print $3}')
if [ -n "$GATEWAY" ]; then
    echo "   Gateway: $GATEWAY"
    if ping -c 1 -W 2 $GATEWAY >/dev/null 2>&1; then
        echo "   ✓ Gateway reachable"
    else
        echo "   ✗ Gateway unreachable"
    fi
else
    echo "   ✗ No default gateway configured"
fi

# Test DNS
echo ""
echo "5. Testing DNS (8.8.8.8)..."
if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
    echo "   ✓ DNS server reachable"
else
    echo "   ✗ DNS server unreachable"
fi

echo ""
echo "=== Test Complete ==="
EOF

chmod +x "${ROOTFS_DIR}/usr/bin/nettest"

# Create system information script
cat > "${ROOTFS_DIR}/usr/bin/sysinfo" << 'EOF'
#!/bin/sh
# System information display script

echo "=========================================="
echo "  Custom Server OS - System Information"
echo "=========================================="
echo ""

# System
echo "System:"
echo "  OS:           Custom Server OS (Linux Edition)"
echo "  Kernel:       $(uname -r)"
echo "  Architecture: $(uname -m)"
echo "  Hostname:     $(hostname)"
echo "  Uptime:       $(awk '{printf "%d days, %02d:%02d:%02d", $1/86400, ($1%86400)/3600, ($1%3600)/60, $1%60}' /proc/uptime)"
echo ""

# CPU
echo "CPU:"
grep "model name" /proc/cpuinfo | head -1 | sed 's/model name.*: /  Model:        /'
echo "  Cores:        $(grep -c processor /proc/cpuinfo)"
echo ""

# Memory
echo "Memory:"
free -m | awk 'NR==2{printf "  Total:        %sMB\n  Used:         %sMB\n  Free:         %sMB\n  Usage:        %.0f%%\n", $2,$3,$4,$3*100/$2}'
echo ""

# Disk
echo "Storage:"
df -h / | awk 'NR==2{printf "  Total:        %s\n  Used:         %s\n  Available:    %s\n  Usage:        %s\n", $2,$3,$4,$5}'
echo ""

# Network
echo "Network:"
for iface in $(ls /sys/class/net/); do
    if [ "$iface" != "lo" ]; then
        echo "  Interface:    $iface"
        ip addr show $iface | grep "inet " | awk '{printf "  IP Address:   %s\n", $2}'
        ip link show $iface | grep "link/ether" | awk '{printf "  MAC Address:  %s\n", $2}'
    fi
done
echo ""

# Processes
echo "Processes:"
echo "  Running:      $(ps aux | wc -l)"
echo ""

echo "=========================================="
EOF

chmod +x "${ROOTFS_DIR}/usr/bin/sysinfo"

# Create system management scripts
echo -e "${YELLOW}Creating system management scripts...${NC}"

# Service management script
cat > "${ROOTFS_DIR}/usr/bin/service" << 'EOF'
#!/bin/sh
# Simple service management script

if [ $# -lt 2 ]; then
    echo "Usage: service <name> {start|stop|restart|status}"
    echo ""
    echo "Available services:"
    ls /etc/init.d/ 2>/dev/null | grep -v "^rc" | sed 's/^/  /'
    exit 1
fi

SERVICE="/etc/init.d/$1"
ACTION="$2"

if [ ! -f "$SERVICE" ]; then
    echo "Error: Service '$1' not found"
    exit 1
fi

if [ ! -x "$SERVICE" ]; then
    chmod +x "$SERVICE"
fi

$SERVICE $ACTION
EOF

chmod +x "${ROOTFS_DIR}/usr/bin/service"

# System update script
cat > "${ROOTFS_DIR}/usr/bin/update-system" << 'EOF'
#!/bin/sh
# System update information script

echo "=========================================="
echo "  Custom Server OS - System Update"
echo "=========================================="
echo ""
echo "Current Version: 0.2.1"
echo "Kernel: $(uname -r)"
echo ""
echo "This is a development version."
echo "Updates are not yet available."
echo ""
echo "For manual updates, rebuild the system:"
echo "  1. Update source code"
echo "  2. Run: make clean && make all"
echo "  3. Reboot with new ISO"
echo ""
EOF

chmod +x "${ROOTFS_DIR}/usr/bin/update-system"

# Disk usage script
cat > "${ROOTFS_DIR}/usr/bin/diskusage" << 'EOF'
#!/bin/sh
# Disk usage information script

echo "=========================================="
echo "  Disk Usage Information"
echo "=========================================="
echo ""
echo "Filesystem usage:"
df -h | awk 'NR==1 || /^\// {print}'
echo ""
echo "Top 10 largest directories in /:"
du -h / 2>/dev/null | sort -rh | head -10
echo ""
EOF

chmod +x "${ROOTFS_DIR}/usr/bin/diskusage"

# Process management helper
cat > "${ROOTFS_DIR}/usr/bin/psinfo" << 'EOF'
#!/bin/sh
# Process information script

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: psinfo [options]"
    echo ""
    echo "Options:"
    echo "  (no args)  Show all processes"
    echo "  -t         Show process tree"
    echo "  -m         Show memory usage"
    echo "  -c         Show CPU usage"
    exit 0
fi

case "$1" in
    -t)
        echo "Process Tree:"
        ps -ef
        ;;
    -m)
        echo "Memory Usage by Process:"
        ps aux | sort -k4 -r | head -10
        ;;
    -c)
        echo "CPU Usage by Process:"
        ps aux | sort -k3 -r | head -10
        ;;
    *)
        echo "Running Processes:"
        ps aux
        ;;
esac
EOF

chmod +x "${ROOTFS_DIR}/usr/bin/psinfo"

# Create issue (login banner)
cat > "${ROOTFS_DIR}/etc/issue" << 'EOF'

Custom Server OS - Linux Edition
Kernel: 6.12.28

Login: root (no password)

EOF

echo -e "${GREEN}Root filesystem created successfully!${NC}"
echo "Location: ${ROOTFS_DIR}"
echo ""
