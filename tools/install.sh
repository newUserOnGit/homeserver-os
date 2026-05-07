#!/bin/bash
# Installation script for Home Server OS

set -e

echo "=================================="
echo "Home Server OS Installer"
echo "=================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root${NC}"
    exit 1
fi

# Welcome message
echo -e "${BLUE}Welcome to Home Server OS Installation${NC}"
echo ""
echo "This installer will guide you through the installation process."
echo ""

# Disk selection
echo "Available disks:"
lsblk -d -o NAME,SIZE,TYPE | grep disk
echo ""
read -p "Enter target disk (e.g., sda): " TARGET_DISK

if [ ! -b "/dev/$TARGET_DISK" ]; then
    echo -e "${RED}Invalid disk: /dev/$TARGET_DISK${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}WARNING: All data on /dev/$TARGET_DISK will be erased!${NC}"
read -p "Continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Installation cancelled."
    exit 0
fi

# Partition disk
echo ""
echo "Partitioning disk..."
parted -s /dev/$TARGET_DISK mklabel gpt
parted -s /dev/$TARGET_DISK mkpart primary fat32 1MiB 512MiB
parted -s /dev/$TARGET_DISK set 1 esp on
parted -s /dev/$TARGET_DISK mkpart primary ext4 512MiB 100%

echo -e "${GREEN}✓ Disk partitioned${NC}"

# Format partitions
echo "Formatting partitions..."
mkfs.fat -F32 /dev/${TARGET_DISK}1
mkfs.ext4 -F /dev/${TARGET_DISK}2

echo -e "${GREEN}✓ Partitions formatted${NC}"

# Mount partitions
echo "Mounting partitions..."
mkdir -p /mnt/homeserver
mount /dev/${TARGET_DISK}2 /mnt/homeserver
mkdir -p /mnt/homeserver/boot
mount /dev/${TARGET_DISK}1 /mnt/homeserver/boot

echo -e "${GREEN}✓ Partitions mounted${NC}"

# Install bootloader
echo "Installing bootloader..."
mkdir -p /mnt/homeserver/boot/grub
cp build/kernel.bin /mnt/homeserver/boot/
cp grub.cfg /mnt/homeserver/boot/grub/
grub-install --target=x86_64-efi --efi-directory=/mnt/homeserver/boot --bootloader-id=HomeServerOS /dev/$TARGET_DISK

echo -e "${GREEN}✓ Bootloader installed${NC}"

# Install system files
echo "Installing system files..."
mkdir -p /mnt/homeserver/etc
mkdir -p /mnt/homeserver/var
mkdir -p /mnt/homeserver/home
mkdir -p /mnt/homeserver/root

cp -r config/* /mnt/homeserver/etc/

echo -e "${GREEN}✓ System files installed${NC}"

# Configure system
echo "Configuring system..."
read -p "Enter hostname [homeserver]: " HOSTNAME
HOSTNAME=${HOSTNAME:-homeserver}
echo "$HOSTNAME" > /mnt/homeserver/etc/hostname

read -p "Enter root password: " -s ROOT_PASSWORD
echo ""
echo "root:$ROOT_PASSWORD" | chpasswd -R /mnt/homeserver

echo -e "${GREEN}✓ System configured${NC}"

# Unmount
echo "Finalizing installation..."
sync
umount /mnt/homeserver/boot
umount /mnt/homeserver
rmdir /mnt/homeserver

echo ""
echo "=================================="
echo -e "${GREEN}Installation completed!${NC}"
echo "=================================="
echo ""
echo "You can now reboot and boot from /dev/$TARGET_DISK"
echo ""
read -p "Reboot now? (yes/no): " REBOOT

if [ "$REBOOT" = "yes" ]; then
    reboot
fi
