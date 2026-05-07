# Home Server OS Makefile

CC = gcc
AS = nasm
LD = ld

CFLAGS = -Wall -Wextra -O2 -nostdlib -ffreestanding -fno-pie
ASFLAGS = -f elf64
LDFLAGS = -nostdlib -n

KERNEL_DIR = kernel
BOOT_DIR = bootloader
BUILD_DIR = build
ISO_DIR = $(BUILD_DIR)/iso

KERNEL_SOURCES = $(wildcard $(KERNEL_DIR)/core/*.c) \
                 $(wildcard $(KERNEL_DIR)/drivers/*.c) \
                 $(wildcard $(KERNEL_DIR)/fs/*.c) \
                 $(wildcard $(KERNEL_DIR)/net/*.c) \
                 $(wildcard $(KERNEL_DIR)/memory/*.c) \
                 $(wildcard $(KERNEL_DIR)/scheduler/*.c)

KERNEL_OBJECTS = $(KERNEL_SOURCES:.c=.o)

BOOT_SOURCES = $(wildcard $(BOOT_DIR)/*.asm)
BOOT_OBJECTS = $(BOOT_SOURCES:.asm=.o)

all: kernel bootloader iso

kernel: $(KERNEL_OBJECTS)
	@echo "Linking kernel..."
	$(LD) $(LDFLAGS) -T linker.ld -o $(BUILD_DIR)/kernel.bin $(KERNEL_OBJECTS)

bootloader: $(BOOT_OBJECTS)
	@echo "Building bootloader..."
	$(AS) $(ASFLAGS) $(BOOT_DIR)/boot.asm -o $(BUILD_DIR)/boot.bin

%.o: %.c
	@echo "Compiling $<..."
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.asm
	@echo "Assembling $<..."
	$(AS) $(ASFLAGS) $< -o $@

iso: kernel bootloader
	@echo "Creating ISO image..."
	mkdir -p $(ISO_DIR)/boot/grub
	cp $(BUILD_DIR)/kernel.bin $(ISO_DIR)/boot/
	cp grub.cfg $(ISO_DIR)/boot/grub/
	grub-mkrescue -o $(BUILD_DIR)/homeserver.iso $(ISO_DIR)

clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(BUILD_DIR)/*.bin $(BUILD_DIR)/*.iso $(BUILD_DIR)/iso
	find . -name "*.o" -delete

install:
	@echo "Installing Home Server OS..."
	cp $(BUILD_DIR)/homeserver.iso /boot/

run:
	@echo "Running in QEMU..."
	qemu-system-x86_64 -cdrom $(BUILD_DIR)/homeserver.iso -m 512M

test:
	@echo "Running tests..."
	cd tests && ./run_tests.sh

.PHONY: all kernel bootloader iso clean install run test
