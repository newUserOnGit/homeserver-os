#!/bin/bash
# Custom Server OS - ISO Builder
# Creates bootable ISO image with GRUB

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Directories
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BUILD_DIR="${PROJECT_ROOT}/build"
ISO_DIR="${BUILD_DIR}/iso"
ROOTFS_DIR="${BUILD_DIR}/rootfs"
KERNEL_OUTPUT="${BUILD_DIR}/kernel-output"

echo -e "${GREEN}=== Building ISO Image ===${NC}"

# Check if kernel exists
if [ ! -f "${KERNEL_OUTPUT}/vmlinuz" ]; then
    echo -e "${RED}Error: Kernel not found. Run build-kernel.sh first.${NC}"
    exit 1
fi

# Check if rootfs exists
if [ ! -d "${ROOTFS_DIR}" ]; then
    echo -e "${RED}Error: Root filesystem not found. Run build-rootfs.sh first.${NC}"
    exit 1
fi

# Create ISO directory structure
echo -e "${YELLOW}Creating ISO directory structure...${NC}"
mkdir -p "${ISO_DIR}/boot/grub"

# Copy kernel
echo -e "${YELLOW}Copying kernel...${NC}"
cp "${KERNEL_OUTPUT}/vmlinuz" "${ISO_DIR}/boot/"

# Create initramfs from rootfs
echo -e "${YELLOW}Creating initramfs...${NC}"
cd "${ROOTFS_DIR}"
find . | cpio -o -H newc | gzip > "${ISO_DIR}/boot/initramfs.gz"

# Create GRUB configuration
echo -e "${YELLOW}Creating GRUB configuration...${NC}"
cat > "${ISO_DIR}/boot/grub/grub.cfg" << 'EOF'
set timeout=5
set default=0

menuentry "Custom Server OS - Linux Edition" {
    linux /boot/vmlinuz quiet
    initrd /boot/initramfs.gz
}

menuentry "Custom Server OS - Debug Mode" {
    linux /boot/vmlinuz debug loglevel=7
    initrd /boot/initramfs.gz
}

menuentry "Custom Server OS - Single User Mode" {
    linux /boot/vmlinuz single
    initrd /boot/initramfs.gz
}
EOF

# Build ISO
echo -e "${YELLOW}Building ISO image...${NC}"
OUTPUT_ISO="${BUILD_DIR}/custom-server-os.iso"

if command -v grub-mkrescue &> /dev/null; then
    grub-mkrescue -o "${OUTPUT_ISO}" "${ISO_DIR}"
elif command -v grub2-mkrescue &> /dev/null; then
    grub2-mkrescue -o "${OUTPUT_ISO}" "${ISO_DIR}"
else
    echo -e "${RED}Error: grub-mkrescue not found. Please install grub tools.${NC}"
    exit 1
fi

# Calculate ISO size
ISO_SIZE=$(du -h "${OUTPUT_ISO}" | cut -f1)

echo ""
echo -e "${GREEN}=== ISO Image created successfully! ===${NC}"
echo "Location: ${OUTPUT_ISO}"
echo "Size: ${ISO_SIZE}"
echo ""
echo "To test in QEMU, run:"
echo "  qemu-system-x86_64 -cdrom ${OUTPUT_ISO} -m 512M"
echo ""
