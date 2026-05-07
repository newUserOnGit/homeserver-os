# Custom Server OS - Main Makefile
# Linux-based distribution for home servers

.PHONY: all kernel rootfs iso clean help test run

# Directories
BUILD_DIR = build
SCRIPTS_DIR = $(BUILD_DIR)/scripts
KERNEL_OUTPUT = $(BUILD_DIR)/kernel-output
ROOTFS_DIR = $(BUILD_DIR)/rootfs
ISO_FILE = $(BUILD_DIR)/custom-server-os.iso

# Default target
all: kernel rootfs iso

# Build kernel
kernel:
	@echo "Building Linux kernel..."
	@bash $(SCRIPTS_DIR)/build-kernel.sh

# Build root filesystem
rootfs:
	@echo "Building root filesystem..."
	@bash $(SCRIPTS_DIR)/build-rootfs.sh

# Build ISO image
iso: kernel rootfs
	@echo "Building ISO image..."
	@bash $(SCRIPTS_DIR)/build-iso.sh

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(BUILD_DIR)/kernel-output
	rm -rf $(BUILD_DIR)/rootfs
	rm -rf $(BUILD_DIR)/iso
	rm -f $(ISO_FILE)
	@echo "Clean complete."

# Deep clean (including kernel build)
distclean: clean
	@echo "Deep cleaning..."
	cd linux-kernel && make mrproper
	@echo "Deep clean complete."

# Test in QEMU
test: iso
	@echo "Testing in QEMU..."
	qemu-system-x86_64 -cdrom $(ISO_FILE) -m 512M -enable-kvm

# Run in QEMU (alias for test)
run: test

# Run with more memory
run-2g: iso
	@echo "Testing in QEMU with 2GB RAM..."
	qemu-system-x86_64 -cdrom $(ISO_FILE) -m 2048M -enable-kvm

# Run with network
run-net: iso
	@echo "Testing in QEMU with network..."
	qemu-system-x86_64 -cdrom $(ISO_FILE) -m 512M -enable-kvm \
		-netdev user,id=net0 -device e1000,netdev=net0

# Check system requirements
check:
	@echo "Checking system requirements..."
	@command -v gcc >/dev/null 2>&1 || { echo "gcc not found"; exit 1; }
	@command -v make >/dev/null 2>&1 || { echo "make not found"; exit 1; }
	@command -v grub-mkrescue >/dev/null 2>&1 || command -v grub2-mkrescue >/dev/null 2>&1 || { echo "grub-mkrescue not found"; exit 1; }
	@command -v cpio >/dev/null 2>&1 || { echo "cpio not found"; exit 1; }
	@command -v gzip >/dev/null 2>&1 || { echo "gzip not found"; exit 1; }
	@echo "All requirements satisfied!"

# Show build information
info:
	@echo "Custom Server OS - Build Information"
	@echo "====================================="
	@echo "Kernel source: linux-kernel/"
	@echo "Build directory: $(BUILD_DIR)/"
	@echo "ISO output: $(ISO_FILE)"
	@echo ""
	@if [ -f $(ISO_FILE) ]; then \
		echo "ISO Status: Built"; \
		echo "ISO Size: $$(du -h $(ISO_FILE) | cut -f1)"; \
	else \
		echo "ISO Status: Not built"; \
	fi
	@echo ""

# Help
help:
	@echo "Custom Server OS - Build System"
	@echo "================================"
	@echo ""
	@echo "Available targets:"
	@echo "  all        - Build everything (kernel + rootfs + iso)"
	@echo "  kernel     - Build Linux kernel only"
	@echo "  rootfs     - Build root filesystem only"
	@echo "  iso        - Build bootable ISO image"
	@echo "  clean      - Remove build artifacts"
	@echo "  distclean  - Deep clean (including kernel)"
	@echo "  test/run   - Test ISO in QEMU"
	@echo "  run-2g     - Test with 2GB RAM"
	@echo "  run-net    - Test with network"
	@echo "  check      - Check system requirements"
	@echo "  info       - Show build information"
	@echo "  help       - Show this help message"
	@echo ""
	@echo "Quick start:"
	@echo "  make check    # Check requirements"
	@echo "  make all      # Build everything"
	@echo "  make test     # Test in QEMU"
	@echo ""
