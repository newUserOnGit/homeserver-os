/*
 * Memory Manager
 * Physical and virtual memory management
 */

#include <stdint.h>
#include <stddef.h>

#define PAGE_SIZE 4096
#define MEMORY_POOL_SIZE (1024 * 1024 * 16) // 16MB

typedef struct {
    uint32_t present    : 1;
    uint32_t rw         : 1;
    uint32_t user       : 1;
    uint32_t accessed   : 1;
    uint32_t dirty      : 1;
    uint32_t unused     : 7;
    uint32_t frame      : 20;
} page_t;

typedef struct {
    page_t pages[1024];
} page_table_t;

typedef struct {
    page_table_t *tables[1024];
    uint32_t physical_tables[1024];
    uint32_t physical_addr;
} page_directory_t;

static uint32_t *memory_bitmap;
static uint32_t total_frames;
static uint32_t used_frames;

void memory_init(uint32_t mem_size) {
    total_frames = mem_size / PAGE_SIZE;
    used_frames = 0;

    // Initialize bitmap
    uint32_t bitmap_size = total_frames / 32;
    memory_bitmap = (uint32_t*)0x100000;

    for (uint32_t i = 0; i < bitmap_size; i++) {
        memory_bitmap[i] = 0;
    }
}

static void set_frame(uint32_t frame_addr) {
    uint32_t frame = frame_addr / PAGE_SIZE;
    uint32_t idx = frame / 32;
    uint32_t off = frame % 32;
    memory_bitmap[idx] |= (1 << off);
    used_frames++;
}

static void clear_frame(uint32_t frame_addr) {
    uint32_t frame = frame_addr / PAGE_SIZE;
    uint32_t idx = frame / 32;
    uint32_t off = frame % 32;
    memory_bitmap[idx] &= ~(1 << off);
    used_frames--;
}

static uint32_t test_frame(uint32_t frame_addr) {
    uint32_t frame = frame_addr / PAGE_SIZE;
    uint32_t idx = frame / 32;
    uint32_t off = frame % 32;
    return (memory_bitmap[idx] & (1 << off));
}

static uint32_t first_free_frame() {
    for (uint32_t i = 0; i < total_frames / 32; i++) {
        if (memory_bitmap[i] != 0xFFFFFFFF) {
            for (uint32_t j = 0; j < 32; j++) {
                uint32_t test = 1 << j;
                if (!(memory_bitmap[i] & test)) {
                    return i * 32 + j;
                }
            }
        }
    }
    return (uint32_t)-1;
}

void* kmalloc(size_t size) {
    uint32_t frame = first_free_frame();
    if (frame == (uint32_t)-1) {
        return NULL;
    }

    set_frame(frame * PAGE_SIZE);
    return (void*)(frame * PAGE_SIZE);
}

void kfree(void* ptr) {
    if (ptr == NULL) return;
    clear_frame((uint32_t)ptr);
}

uint32_t get_memory_usage() {
    return (used_frames * PAGE_SIZE) / 1024; // KB
}

uint32_t get_free_memory() {
    return ((total_frames - used_frames) * PAGE_SIZE) / 1024; // KB
}
