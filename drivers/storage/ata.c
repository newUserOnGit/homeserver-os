/*
 * Storage Driver
 * SATA/IDE disk driver
 */

#include <stdint.h>
#include <stddef.h>

#define ATA_PRIMARY_IO 0x1F0
#define ATA_SECONDARY_IO 0x170
#define ATA_PRIMARY_CONTROL 0x3F6
#define ATA_SECONDARY_CONTROL 0x376

#define ATA_DATA 0
#define ATA_ERROR 1
#define ATA_SECTOR_COUNT 2
#define ATA_LBA_LOW 3
#define ATA_LBA_MID 4
#define ATA_LBA_HIGH 5
#define ATA_DRIVE 6
#define ATA_STATUS 7
#define ATA_COMMAND 7

#define ATA_CMD_READ_SECTORS 0x20
#define ATA_CMD_WRITE_SECTORS 0x30
#define ATA_CMD_IDENTIFY 0xEC

#define ATA_STATUS_BSY 0x80
#define ATA_STATUS_DRQ 0x08
#define ATA_STATUS_ERR 0x01

typedef struct {
    uint16_t base_io;
    uint16_t control_io;
    uint8_t drive;
    uint32_t size_sectors;
    char model[41];
    char serial[21];
} ata_device_t;

static ata_device_t devices[4];
static int device_count = 0;

static uint8_t inb(uint16_t port) {
    uint8_t ret;
    __asm__ volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

static void outb(uint16_t port, uint8_t val) {
    __asm__ volatile ("outb %0, %1" : : "a"(val), "Nd"(port));
}

static void ata_wait(uint16_t base) {
    while (inb(base + ATA_STATUS) & ATA_STATUS_BSY);
}

static int ata_identify(ata_device_t *dev) {
    outb(dev->base_io + ATA_DRIVE, 0xA0 | (dev->drive << 4));
    outb(dev->base_io + ATA_SECTOR_COUNT, 0);
    outb(dev->base_io + ATA_LBA_LOW, 0);
    outb(dev->base_io + ATA_LBA_MID, 0);
    outb(dev->base_io + ATA_LBA_HIGH, 0);
    outb(dev->base_io + ATA_COMMAND, ATA_CMD_IDENTIFY);

    uint8_t status = inb(dev->base_io + ATA_STATUS);
    if (status == 0) return -1;

    ata_wait(dev->base_io);

    if (inb(dev->base_io + ATA_STATUS) & ATA_STATUS_ERR) {
        return -1;
    }

    uint16_t data[256];
    for (int i = 0; i < 256; i++) {
        data[i] = inb(dev->base_io + ATA_DATA) | (inb(dev->base_io + ATA_DATA) << 8);
    }

    dev->size_sectors = (data[61] << 16) | data[60];

    for (int i = 0; i < 20; i++) {
        dev->model[i * 2] = data[27 + i] >> 8;
        dev->model[i * 2 + 1] = data[27 + i] & 0xFF;
    }
    dev->model[40] = '\0';

    return 0;
}

void storage_init() {
    device_count = 0;

    // Primary master
    devices[device_count].base_io = ATA_PRIMARY_IO;
    devices[device_count].control_io = ATA_PRIMARY_CONTROL;
    devices[device_count].drive = 0;
    if (ata_identify(&devices[device_count]) == 0) {
        device_count++;
    }

    // Primary slave
    devices[device_count].base_io = ATA_PRIMARY_IO;
    devices[device_count].control_io = ATA_PRIMARY_CONTROL;
    devices[device_count].drive = 1;
    if (ata_identify(&devices[device_count]) == 0) {
        device_count++;
    }

    // Secondary master
    devices[device_count].base_io = ATA_SECONDARY_IO;
    devices[device_count].control_io = ATA_SECONDARY_CONTROL;
    devices[device_count].drive = 0;
    if (ata_identify(&devices[device_count]) == 0) {
        device_count++;
    }

    // Secondary slave
    devices[device_count].base_io = ATA_SECONDARY_IO;
    devices[device_count].control_io = ATA_SECONDARY_CONTROL;
    devices[device_count].drive = 1;
    if (ata_identify(&devices[device_count]) == 0) {
        device_count++;
    }
}

int storage_read(int device, uint32_t lba, uint8_t *buffer, uint32_t sectors) {
    if (device < 0 || device >= device_count) return -1;

    ata_device_t *dev = &devices[device];

    outb(dev->base_io + ATA_DRIVE, 0xE0 | (dev->drive << 4) | ((lba >> 24) & 0x0F));
    outb(dev->base_io + ATA_SECTOR_COUNT, sectors);
    outb(dev->base_io + ATA_LBA_LOW, lba & 0xFF);
    outb(dev->base_io + ATA_LBA_MID, (lba >> 8) & 0xFF);
    outb(dev->base_io + ATA_LBA_HIGH, (lba >> 16) & 0xFF);
    outb(dev->base_io + ATA_COMMAND, ATA_CMD_READ_SECTORS);

    for (uint32_t s = 0; s < sectors; s++) {
        ata_wait(dev->base_io);
        for (int i = 0; i < 256; i++) {
            uint16_t data = inb(dev->base_io + ATA_DATA) | (inb(dev->base_io + ATA_DATA) << 8);
            buffer[s * 512 + i * 2] = data & 0xFF;
            buffer[s * 512 + i * 2 + 1] = data >> 8;
        }
    }

    return sectors;
}

int storage_write(int device, uint32_t lba, const uint8_t *buffer, uint32_t sectors) {
    if (device < 0 || device >= device_count) return -1;

    ata_device_t *dev = &devices[device];

    outb(dev->base_io + ATA_DRIVE, 0xE0 | (dev->drive << 4) | ((lba >> 24) & 0x0F));
    outb(dev->base_io + ATA_SECTOR_COUNT, sectors);
    outb(dev->base_io + ATA_LBA_LOW, lba & 0xFF);
    outb(dev->base_io + ATA_LBA_MID, (lba >> 8) & 0xFF);
    outb(dev->base_io + ATA_LBA_HIGH, (lba >> 16) & 0xFF);
    outb(dev->base_io + ATA_COMMAND, ATA_CMD_WRITE_SECTORS);

    for (uint32_t s = 0; s < sectors; s++) {
        ata_wait(dev->base_io);
        for (int i = 0; i < 256; i++) {
            uint16_t data = buffer[s * 512 + i * 2] | (buffer[s * 512 + i * 2 + 1] << 8);
            outb(dev->base_io + ATA_DATA, data & 0xFF);
            outb(dev->base_io + ATA_DATA, data >> 8);
        }
    }

    return sectors;
}

int storage_get_device_count() {
    return device_count;
}

uint32_t storage_get_device_size(int device) {
    if (device < 0 || device >= device_count) return 0;
    return devices[device].size_sectors * 512 / 1024 / 1024; // MB
}
