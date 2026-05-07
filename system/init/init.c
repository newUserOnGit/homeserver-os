/*
 * System Initialization
 * Init system for Home Server OS
 */

#include <stdint.h>
#include <stddef.h>

extern void memory_init(uint32_t mem_size);
extern void scheduler_init();
extern void fs_init();
extern void network_init();
extern void storage_init();

typedef struct {
    const char *name;
    void (*init_func)();
    int enabled;
    int initialized;
} service_t;

static service_t services[] = {
    {"Memory Manager", (void(*)())memory_init, 1, 0},
    {"Task Scheduler", scheduler_init, 1, 0},
    {"Filesystem", fs_init, 1, 0},
    {"Storage Driver", storage_init, 1, 0},
    {"Network Stack", (void(*)())network_init, 1, 0},
    {NULL, NULL, 0, 0}
};

void init_system() {
    for (int i = 0; services[i].name != NULL; i++) {
        if (services[i].enabled) {
            services[i].init_func();
            services[i].initialized = 1;
        }
    }
}

int get_service_status(const char *name) {
    for (int i = 0; services[i].name != NULL; i++) {
        int match = 1;
        for (int j = 0; services[i].name[j] && name[j]; j++) {
            if (services[i].name[j] != name[j]) {
                match = 0;
                break;
            }
        }
        if (match) {
            return services[i].initialized;
        }
    }
    return -1;
}

void enable_service(const char *name) {
    for (int i = 0; services[i].name != NULL; i++) {
        int match = 1;
        for (int j = 0; services[i].name[j] && name[j]; j++) {
            if (services[i].name[j] != name[j]) {
                match = 0;
                break;
            }
        }
        if (match) {
            services[i].enabled = 1;
            return;
        }
    }
}

void disable_service(const char *name) {
    for (int i = 0; services[i].name != NULL; i++) {
        int match = 1;
        for (int j = 0; services[i].name[j] && name[j]; j++) {
            if (services[i].name[j] != name[j]) {
                match = 0;
                break;
            }
        }
        if (match) {
            services[i].enabled = 0;
            return;
        }
    }
}

int get_enabled_services_count() {
    int count = 0;
    for (int i = 0; services[i].name != NULL; i++) {
        if (services[i].enabled) {
            count++;
        }
    }
    return count;
}

int get_initialized_services_count() {
    int count = 0;
    for (int i = 0; services[i].name != NULL; i++) {
        if (services[i].initialized) {
            count++;
        }
    }
    return count;
}
