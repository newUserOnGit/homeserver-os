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
ip link set lo up 2>/dev/null || log "WARNING: Failed to bring up loopback"
ip addr add 127.0.0.1/8 dev lo 2>/dev/null || log "WARNING: Failed to set loopback address"

log "Step 6: System information..."
log "Kernel: $(uname -r)"
log "Hostname: $(hostname)"
log "Available commands: $(ls /bin | wc -l) binaries in /bin"

echo ""
echo "=========================================="
echo "  Custom Server OS - Linux Edition"
echo "  Based on Linux Kernel 6.12.28"
echo "=========================================="
echo ""
echo "System initialized successfully!"
echo ""
echo "Available commands:"
echo "  ls, cat, ps, top, free, df, mount, ip, ping"
echo "  vi, grep, find, tar, gzip, wget, curl"
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

# Create issue (login banner)
cat > "${ROOTFS_DIR}/etc/issue" << 'EOF'

Custom Server OS - Linux Edition
Kernel: 6.12.28

Login: root (no password)

EOF

echo -e "${GREEN}Root filesystem created successfully!${NC}"
echo "Location: ${ROOTFS_DIR}"
echo ""
