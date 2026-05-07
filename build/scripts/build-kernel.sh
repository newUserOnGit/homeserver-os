#!/bin/bash
# Custom Server OS - Kernel Build Script
# Builds Linux kernel 6.12.28 with custom configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Directories
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
KERNEL_SRC="${PROJECT_ROOT}/linux-kernel/source"
BUILD_DIR="${PROJECT_ROOT}/build"
CONFIG_DIR="${PROJECT_ROOT}/config"
OUTPUT_DIR="${BUILD_DIR}/kernel-output"

echo -e "${GREEN}=== Custom Server OS - Kernel Build ===${NC}"
echo "Project root: ${PROJECT_ROOT}"
echo "Kernel source: ${KERNEL_SRC}"
echo "Build directory: ${BUILD_DIR}"
echo ""

# Check if kernel source exists
if [ ! -d "${KERNEL_SRC}" ]; then
    echo -e "${RED}Error: Kernel source not found at ${KERNEL_SRC}${NC}"
    exit 1
fi

# Check if config exists
if [ ! -f "${CONFIG_DIR}/kernel.config" ]; then
    echo -e "${RED}Error: Kernel config not found at ${CONFIG_DIR}/kernel.config${NC}"
    exit 1
fi

# Create output directory
mkdir -p "${OUTPUT_DIR}"

# Copy custom config
echo -e "${YELLOW}Copying custom kernel configuration...${NC}"
cp "${CONFIG_DIR}/kernel.config" "${KERNEL_SRC}/.config"

# Navigate to kernel source
cd "${KERNEL_SRC}"

# Check kernel version
echo -e "${YELLOW}Kernel version:${NC}"
make kernelversion

# Configure kernel
echo -e "${YELLOW}Configuring kernel...${NC}"
make olddefconfig

# Build kernel
echo -e "${YELLOW}Building kernel (this may take a while)...${NC}"
NCPUS=$(nproc)
echo "Using ${NCPUS} CPU cores"
make -j${NCPUS}

# Build modules
echo -e "${YELLOW}Building kernel modules...${NC}"
make modules -j${NCPUS}

# Install modules to output directory
echo -e "${YELLOW}Installing modules...${NC}"
make INSTALL_MOD_PATH="${OUTPUT_DIR}" modules_install

# Copy kernel image
echo -e "${YELLOW}Copying kernel image...${NC}"
cp arch/x86/boot/bzImage "${OUTPUT_DIR}/vmlinuz"

# Copy System.map
cp System.map "${OUTPUT_DIR}/System.map"

# Copy config
cp .config "${OUTPUT_DIR}/config"

echo ""
echo -e "${GREEN}=== Kernel build completed successfully! ===${NC}"
echo "Kernel image: ${OUTPUT_DIR}/vmlinuz"
echo "Modules: ${OUTPUT_DIR}/lib/modules/"
echo "System.map: ${OUTPUT_DIR}/System.map"
echo ""
