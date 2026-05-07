/*
 * Virtual Machine Management
 * Hypervisor for running virtual machines
 */

#include <stdint.h>
#include <stddef.h>

#define MAX_VMS 32
#define MAX_VM_NAME_LENGTH 64

typedef enum {
    VM_STOPPED,
    VM_STARTING,
    VM_RUNNING,
    VM_PAUSED,
    VM_STOPPING,
    VM_SUSPENDED
} vm_state_t;

typedef enum {
    VM_BIOS,
    VM_UEFI
} vm_firmware_t;

typedef struct {
    uint32_t cores;
    uint32_t threads_per_core;
} vm_cpu_config_t;

typedef struct {
    uint32_t size_mb;
    int ballooning_enabled;
} vm_memory_config_t;

typedef struct {
    char path[256];
    uint32_t size_gb;
    int is_boot_disk;
} vm_disk_t;

typedef struct {
    char bridge[32];
    char mac_address[18];
    int enabled;
} vm_network_t;

typedef struct {
    uint32_t id;
    char name[MAX_VM_NAME_LENGTH];
    vm_state_t state;
    vm_firmware_t firmware;
    vm_cpu_config_t cpu;
    vm_memory_config_t memory;
    vm_disk_t disks[8];
    int disk_count;
    vm_network_t network;
    uint64_t created_time;
    uint64_t started_time;
    uint32_t cpu_usage;
    uint32_t memory_usage;
    uint32_t uptime;
} vm_t;

static vm_t vms[MAX_VMS];
static int vm_count = 0;
static uint32_t next_vm_id = 1;
static int max_vms = 5;

void vm_init() {
    vm_count = 0;
    next_vm_id = 1;

    for (int i = 0; i < MAX_VMS; i++) {
        vms[i].state = VM_STOPPED;
        vms[i].id = 0;
    }
}

uint32_t vm_create(const char *name, vm_firmware_t firmware,
                   uint32_t cpu_cores, uint32_t memory_mb) {
    if (vm_count >= max_vms) return 0;

    vm_t *vm = &vms[vm_count];
    vm->id = next_vm_id++;
    vm->state = VM_STOPPED;
    vm->firmware = firmware;
    vm->created_time = 0; // Should be current time
    vm->started_time = 0;
    vm->cpu_usage = 0;
    vm->memory_usage = 0;
    vm->uptime = 0;
    vm->disk_count = 0;

    int i;
    for (i = 0; i < MAX_VM_NAME_LENGTH - 1 && name[i]; i++) {
        vm->name[i] = name[i];
    }
    vm->name[i] = '\0';

    vm->cpu.cores = cpu_cores;
    vm->cpu.threads_per_core = 1;

    vm->memory.size_mb = memory_mb;
    vm->memory.ballooning_enabled = 1;

    vm->network.enabled = 1;
    for (i = 0; i < 32; i++) {
        vm->network.bridge[i] = 0;
    }
    vm->network.bridge[0] = 'b';
    vm->network.bridge[1] = 'r';
    vm->network.bridge[2] = '0';

    // Generate MAC address
    vm->network.mac_address[0] = '5';
    vm->network.mac_address[1] = '2';
    vm->network.mac_address[2] = ':';
    vm->network.mac_address[3] = '5';
    vm->network.mac_address[4] = '4';
    vm->network.mac_address[5] = ':';
    vm->network.mac_address[6] = '0';
    vm->network.mac_address[7] = '0';
    vm->network.mac_address[8] = ':';
    vm->network.mac_address[9] = (vm->id / 100) % 10 + '0';
    vm->network.mac_address[10] = (vm->id / 10) % 10 + '0';
    vm->network.mac_address[11] = ':';
    vm->network.mac_address[12] = vm->id % 10 + '0';
    vm->network.mac_address[13] = '0';
    vm->network.mac_address[14] = ':';
    vm->network.mac_address[15] = '0';
    vm->network.mac_address[16] = '1';
    vm->network.mac_address[17] = '\0';

    vm_count++;
    return vm->id;
}

int vm_add_disk(uint32_t vm_id, const char *path, uint32_t size_gb, int is_boot) {
    for (int i = 0; i < vm_count; i++) {
        if (vms[i].id == vm_id) {
            if (vms[i].disk_count >= 8) return -1;

            vm_disk_t *disk = &vms[i].disks[vms[i].disk_count];
            int j;
            for (j = 0; j < 255 && path[j]; j++) {
                disk->path[j] = path[j];
            }
            disk->path[j] = '\0';
            disk->size_gb = size_gb;
            disk->is_boot_disk = is_boot;

            vms[i].disk_count++;
            return 0;
        }
    }
    return -1;
}

int vm_start(uint32_t vm_id) {
    for (int i = 0; i < vm_count; i++) {
        if (vms[i].id == vm_id) {
            if (vms[i].state != VM_STOPPED && vms[i].state != VM_SUSPENDED) {
                return -1;
            }

            vms[i].state = VM_STARTING;
            vms[i].started_time = 0; // Should be current time
            vms[i].state = VM_RUNNING;
            vms[i].uptime = 0;

            return 0;
        }
    }
    return -1;
}

int vm_stop(uint32_t vm_id) {
    for (int i = 0; i < vm_count; i++) {
        if (vms[i].id == vm_id) {
            if (vms[i].state != VM_RUNNING && vms[i].state != VM_PAUSED) {
                return -1;
            }

            vms[i].state = VM_STOPPING;
            vms[i].state = VM_STOPPED;

            return 0;
        }
    }
    return -1;
}

int vm_pause(uint32_t vm_id) {
    for (int i = 0; i < vm_count; i++) {
        if (vms[i].id == vm_id) {
            if (vms[i].state != VM_RUNNING) return -1;
            vms[i].state = VM_PAUSED;
            return 0;
        }
    }
    return -1;
}

int vm_resume(uint32_t vm_id) {
    for (int i = 0; i < vm_count; i++) {
        if (vms[i].id == vm_id) {
            if (vms[i].state != VM_PAUSED) return -1;
            vms[i].state = VM_RUNNING;
            return 0;
        }
    }
    return -1;
}

int vm_suspend(uint32_t vm_id) {
    for (int i = 0; i < vm_count; i++) {
        if (vms[i].id == vm_id) {
            if (vms[i].state != VM_RUNNING) return -1;
            vms[i].state = VM_SUSPENDED;
            return 0;
        }
    }
    return -1;
}

int vm_delete(uint32_t vm_id) {
    for (int i = 0; i < vm_count; i++) {
        if (vms[i].id == vm_id) {
            if (vms[i].state == VM_RUNNING) {
                vm_stop(vm_id);
            }

            for (int j = i; j < vm_count - 1; j++) {
                vms[j] = vms[j + 1];
            }
            vm_count--;
            return 0;
        }
    }
    return -1;
}

vm_t* vm_get(uint32_t vm_id) {
    for (int i = 0; i < vm_count; i++) {
        if (vms[i].id == vm_id) {
            return &vms[i];
        }
    }
    return NULL;
}

int vm_get_list(vm_t *buffer, int max_count) {
    int count = vm_count < max_count ? vm_count : max_count;
    for (int i = 0; i < count; i++) {
        buffer[i] = vms[i];
    }
    return count;
}

int vm_get_count() {
    return vm_count;
}

int vm_get_running_count() {
    int count = 0;
    for (int i = 0; i < vm_count; i++) {
        if (vms[i].state == VM_RUNNING) {
            count++;
        }
    }
    return count;
}

void vm_update_stats(uint32_t vm_id) {
    for (int i = 0; i < vm_count; i++) {
        if (vms[i].id == vm_id && vms[i].state == VM_RUNNING) {
            vms[i].cpu_usage = 20 + (vm_id % 40);
            vms[i].memory_usage = vms[i].memory.size_mb * (50 + (vm_id % 30)) / 100;
            vms[i].uptime++;
        }
    }
}

void vm_set_max(int max) {
    max_vms = max;
}

int vm_get_max() {
    return max_vms;
}
