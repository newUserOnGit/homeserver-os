/*
 * Filesystem Implementation
 * Simple filesystem for home server OS
 */

#include <stdint.h>
#include <stddef.h>

#define MAX_FILES 1024
#define MAX_FILENAME 256
#define BLOCK_SIZE 4096
#define MAX_BLOCKS 65536

typedef enum {
    FILE_TYPE_REGULAR,
    FILE_TYPE_DIRECTORY,
    FILE_TYPE_SYMLINK
} file_type_t;

typedef struct {
    char name[MAX_FILENAME];
    file_type_t type;
    uint32_t size;
    uint32_t blocks[128];
    uint32_t block_count;
    uint32_t permissions;
    uint32_t owner_id;
    uint32_t group_id;
    uint64_t created_time;
    uint64_t modified_time;
    uint64_t accessed_time;
} inode_t;

typedef struct {
    uint32_t magic;
    uint32_t version;
    uint32_t block_size;
    uint32_t total_blocks;
    uint32_t free_blocks;
    uint32_t total_inodes;
    uint32_t free_inodes;
    uint32_t root_inode;
} superblock_t;

static superblock_t superblock;
static inode_t inodes[MAX_FILES];
static uint8_t block_bitmap[MAX_BLOCKS / 8];
static uint8_t inode_bitmap[MAX_FILES / 8];

void fs_init() {
    superblock.magic = 0x48534653; // "HSFS"
    superblock.version = 1;
    superblock.block_size = BLOCK_SIZE;
    superblock.total_blocks = MAX_BLOCKS;
    superblock.free_blocks = MAX_BLOCKS;
    superblock.total_inodes = MAX_FILES;
    superblock.free_inodes = MAX_FILES;
    superblock.root_inode = 0;

    for (int i = 0; i < MAX_BLOCKS / 8; i++) {
        block_bitmap[i] = 0;
    }

    for (int i = 0; i < MAX_FILES / 8; i++) {
        inode_bitmap[i] = 0;
    }

    // Create root directory
    inodes[0].type = FILE_TYPE_DIRECTORY;
    inodes[0].size = 0;
    inodes[0].block_count = 0;
    inodes[0].permissions = 0755;
    inodes[0].owner_id = 0;
    inodes[0].group_id = 0;
    for (int i = 0; i < MAX_FILENAME; i++) {
        inodes[0].name[i] = 0;
    }
    inodes[0].name[0] = '/';

    inode_bitmap[0] |= 1;
    superblock.free_inodes--;
}

static int allocate_block() {
    for (int i = 0; i < MAX_BLOCKS / 8; i++) {
        if (block_bitmap[i] != 0xFF) {
            for (int j = 0; j < 8; j++) {
                if (!(block_bitmap[i] & (1 << j))) {
                    block_bitmap[i] |= (1 << j);
                    superblock.free_blocks--;
                    return i * 8 + j;
                }
            }
        }
    }
    return -1;
}

static void free_block(int block) {
    if (block < 0 || block >= MAX_BLOCKS) return;
    int byte = block / 8;
    int bit = block % 8;
    block_bitmap[byte] &= ~(1 << bit);
    superblock.free_blocks++;
}

static int allocate_inode() {
    for (int i = 0; i < MAX_FILES / 8; i++) {
        if (inode_bitmap[i] != 0xFF) {
            for (int j = 0; j < 8; j++) {
                if (!(inode_bitmap[i] & (1 << j))) {
                    inode_bitmap[i] |= (1 << j);
                    superblock.free_inodes--;
                    return i * 8 + j;
                }
            }
        }
    }
    return -1;
}

static void free_inode(int inode) {
    if (inode < 0 || inode >= MAX_FILES) return;
    int byte = inode / 8;
    int bit = inode % 8;
    inode_bitmap[byte] &= ~(1 << bit);
    superblock.free_inodes++;
}

int fs_create(const char *path, file_type_t type) {
    int inode_id = allocate_inode();
    if (inode_id < 0) return -1;

    inode_t *inode = &inodes[inode_id];
    inode->type = type;
    inode->size = 0;
    inode->block_count = 0;
    inode->permissions = 0644;
    inode->owner_id = 0;
    inode->group_id = 0;

    for (int i = 0; i < MAX_FILENAME && path[i]; i++) {
        inode->name[i] = path[i];
    }

    return inode_id;
}

int fs_write(int inode_id, const uint8_t *data, uint32_t size) {
    if (inode_id < 0 || inode_id >= MAX_FILES) return -1;

    inode_t *inode = &inodes[inode_id];
    uint32_t blocks_needed = (size + BLOCK_SIZE - 1) / BLOCK_SIZE;

    if (blocks_needed > 128) return -1;

    for (uint32_t i = 0; i < blocks_needed; i++) {
        int block = allocate_block();
        if (block < 0) return -1;
        inode->blocks[i] = block;
    }

    inode->block_count = blocks_needed;
    inode->size = size;

    return size;
}

int fs_read(int inode_id, uint8_t *buffer, uint32_t size) {
    if (inode_id < 0 || inode_id >= MAX_FILES) return -1;

    inode_t *inode = &inodes[inode_id];
    if (size > inode->size) size = inode->size;

    return size;
}

int fs_delete(int inode_id) {
    if (inode_id < 0 || inode_id >= MAX_FILES) return -1;

    inode_t *inode = &inodes[inode_id];

    for (uint32_t i = 0; i < inode->block_count; i++) {
        free_block(inode->blocks[i]);
    }

    free_inode(inode_id);
    return 0;
}

uint32_t fs_get_free_space() {
    return superblock.free_blocks * BLOCK_SIZE / 1024; // KB
}

uint32_t fs_get_used_space() {
    return (superblock.total_blocks - superblock.free_blocks) * BLOCK_SIZE / 1024; // KB
}
