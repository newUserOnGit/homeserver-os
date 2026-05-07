#!/bin/bash
# Build script for Home Server OS

set -e

echo "=================================="
echo "Home Server OS Build System"
echo "=================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
BUILD_DIR="build"
KERNEL_DIR="kernel"
BOOT_DIR="bootloader"
ISO_DIR="$BUILD_DIR/iso"

# Check dependencies
check_dependencies() {
    echo "Checking dependencies..."

    local missing_deps=0

    if ! command -v gcc &> /dev/null; then
        echo -e "${RED}✗ GCC not found${NC}"
        missing_deps=1
    else
        echo -e "${GREEN}✓ GCC found${NC}"
    fi

    if ! command -v nasm &> /dev/null; then
        echo -e "${RED}✗ NASM not found${NC}"
        missing_deps=1
    else
        echo -e "${GREEN}✓ NASM found${NC}"
    fi

    if ! command -v ld &> /dev/null; then
        echo -e "${RED}✗ LD not found${NC}"
        missing_deps=1
    else
        echo -e "${GREEN}✓ LD found${NC}"
    fi

    if ! command -v grub-mkrescue &> /dev/null; then
        echo -e "${YELLOW}⚠ GRUB not found (ISO creation will fail)${NC}"
    else
        echo -e "${GREEN}✓ GRUB found${NC}"
    fi

    if [ $missing_deps -eq 1 ]; then
        echo -e "${RED}Missing required dependencies!${NC}"
        exit 1
    fi

    echo ""
}

# Create build directory
setup_build_dir() {
    echo "Setting up build directory..."
    mkdir -p $BUILD_DIR
    mkdir -p $ISO_DIR/boot/grub
    echo -e "${GREEN}✓ Build directory ready${NC}"
    echo ""
}

# Build bootloader
build_bootloader() {
    echo "Building bootloader..."
    nasm -f bin $BOOT_DIR/boot.asm -o $BUILD_DIR/boot.bin
    echo -e "${GREEN}✓ Bootloader built${NC}"
    echo ""
}

# Build kernel
build_kernel() {
    echo "Building kernel..."

    # Compile kernel sources
    gcc -Wall -Wextra -O2 -nostdlib -ffreestanding -fno-pie \
        -c $KERNEL_DIR/core/kernel.c -o $BUILD_DIR/kernel.o

    # Link kernel
    ld -nostdlib -n -T linker.ld -o $BUILD_DIR/kernel.bin $BUILD_DIR/kernel.o

    echo -e "${GREEN}✓ Kernel built${NC}"
    echo ""
}

# Create ISO image
create_iso() {
    echo "Creating ISO image..."

    cp $BUILD_DIR/kernel.bin $ISO_DIR/boot/
    cp grub.cfg $ISO_DIR/boot/grub/

    if command -v grub-mkrescue &> /dev/null; then
        grub-mkrescue -o $BUILD_DIR/homeserver.iso $ISO_DIR
        echo -e "${GREEN}✓ ISO image created: $BUILD_DIR/homeserver.iso${NC}"
    else
        echo -e "${YELLOW}⚠ GRUB not available, skipping ISO creation${NC}"
    fi

    echo ""
}

# Main build process
main() {
    echo "Starting build process..."
    echo ""

    check_dependencies
    setup_build_dir
    build_bootloader
    build_kernel
    create_iso

    echo "=================================="
    echo -e "${GREEN}Build completed successfully!${NC}"
    echo "=================================="
    echo ""
    echo "Output files:"
    echo "  - Bootloader: $BUILD_DIR/boot.bin"
    echo "  - Kernel:     $BUILD_DIR/kernel.bin"
    echo "  - ISO:        $BUILD_DIR/homeserver.iso"
    echo ""
    echo "To test in QEMU, run:"
    echo "  make run"
    echo ""
}

# Run main
main
