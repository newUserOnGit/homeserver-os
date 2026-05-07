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

# Create essential device nodes
echo -e "${YELLOW}Creating device nodes...${NC}"
cd "${ROOTFS_DIR}/dev"
sudo mknod -m 666 null c 1 3
sudo mknod -m 666 zero c 1 5
sudo mknod -m 666 random c 1 8
sudo mknod -m 666 urandom c 1 9
sudo mknod -m 666 tty c 5 0
sudo mknod -m 600 console c 5 1

# Copy kernel modules
if [ -d "${KERNEL_OUTPUT}/lib/modules" ]; then
    echo -e "${YELLOW}Copying kernel modules...${NC}"
    cp -r "${KERNEL_OUTPUT}/lib/modules" "${ROOTFS_DIR}/lib/"
fi

# Create init script
echo -e "${YELLOW}Creating init script...${NC}"
cat > "${ROOTFS_DIR}/init" << 'EOF'
#!/bin/sh

# Mount essential filesystems
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev

# Create additional device nodes
mknod /dev/null c 1 3 2>/dev/null || true
mknod /dev/console c 5 1 2>/dev/null || true

# Clear screen
clear

# Welcome message
echo "=========================================="
echo "   Custom Server OS - Linux Edition"
echo "   Based on Linux Kernel 6.12.28"
echo "=========================================="
echo ""
echo "Initializing system..."

# Load kernel modules
echo "Loading kernel modules..."
find /lib/modules -name '*.ko' -exec insmod {} \; 2>/dev/null || true

# Setup network
echo "Configuring network..."
ip link set lo up
ip addr add 127.0.0.1/8 dev lo

# Mount tmpfs
mount -t tmpfs tmpfs /tmp
mount -t tmpfs tmpfs /var

# Create necessary directories
mkdir -p /var/log /var/run /var/lock

echo ""
echo "System initialized successfully!"
echo ""

# Start shell
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
