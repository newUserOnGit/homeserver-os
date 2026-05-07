/*
 * Container Management
 * Lightweight containerization system
 */

#include <stdint.h>
#include <stddef.h>

#define MAX_CONTAINERS 64
#define MAX_NAME_LENGTH 64
#define MAX_IMAGE_LENGTH 128

typedef enum {
    CONTAINER_STOPPED,
    CONTAINER_STARTING,
    CONTAINER_RUNNING,
    CONTAINER_PAUSED,
    CONTAINER_STOPPING
} container_state_t;

typedef struct {
    uint32_t cpu_limit;      // Percentage
    uint32_t memory_limit;   // MB
    uint32_t disk_limit;     // MB
    uint32_t network_limit;  // KB/s
} resource_limits_t;

typedef struct {
    uint32_t id;
    char name[MAX_NAME_LENGTH];
    char image[MAX_IMAGE_LENGTH];
    container_state_t state;
    resource_limits_t limits;
    uint32_t pid;
    uint64_t created_time;
    uint64_t started_time;
    uint32_t cpu_usage;
    uint32_t memory_usage;
    uint32_t network_rx;
    uint32_t network_tx;
    uint16_t exposed_ports[16];
    int port_count;
} container_t;

static container_t containers[MAX_CONTAINERS];
static int container_count = 0;
static uint32_t next_container_id = 1;
static int max_containers = 10;

void container_init() {
    container_count = 0;
    next_container_id = 1;

    for (int i = 0; i < MAX_CONTAINERS; i++) {
        containers[i].state = CONTAINER_STOPPED;
        containers[i].id = 0;
    }
}

uint32_t container_create(const char *name, const char *image, resource_limits_t *limits) {
    if (container_count >= max_containers) return 0;

    container_t *container = &containers[container_count];
    container->id = next_container_id++;
    container->state = CONTAINER_STOPPED;
    container->pid = 0;
    container->created_time = 0; // Should be current time
    container->started_time = 0;
    container->cpu_usage = 0;
    container->memory_usage = 0;
    container->network_rx = 0;
    container->network_tx = 0;
    container->port_count = 0;

    int i;
    for (i = 0; i < MAX_NAME_LENGTH - 1 && name[i]; i++) {
        container->name[i] = name[i];
    }
    container->name[i] = '\0';

    for (i = 0; i < MAX_IMAGE_LENGTH - 1 && image[i]; i++) {
        container->image[i] = image[i];
    }
    container->image[i] = '\0';

    if (limits) {
        container->limits = *limits;
    } else {
        container->limits.cpu_limit = 100;
        container->limits.memory_limit = 512;
        container->limits.disk_limit = 10240;
        container->limits.network_limit = 10240;
    }

    container_count++;
    return container->id;
}

int container_start(uint32_t container_id) {
    for (int i = 0; i < container_count; i++) {
        if (containers[i].id == container_id) {
            if (containers[i].state != CONTAINER_STOPPED) return -1;

            containers[i].state = CONTAINER_STARTING;
            containers[i].pid = next_container_id * 1000; // Simulated PID
            containers[i].started_time = 0; // Should be current time
            containers[i].state = CONTAINER_RUNNING;

            return 0;
        }
    }
    return -1;
}

int container_stop(uint32_t container_id) {
    for (int i = 0; i < container_count; i++) {
        if (containers[i].id == container_id) {
            if (containers[i].state != CONTAINER_RUNNING) return -1;

            containers[i].state = CONTAINER_STOPPING;
            containers[i].state = CONTAINER_STOPPED;
            containers[i].pid = 0;

            return 0;
        }
    }
    return -1;
}

int container_pause(uint32_t container_id) {
    for (int i = 0; i < container_count; i++) {
        if (containers[i].id == container_id) {
            if (containers[i].state != CONTAINER_RUNNING) return -1;
            containers[i].state = CONTAINER_PAUSED;
            return 0;
        }
    }
    return -1;
}

int container_resume(uint32_t container_id) {
    for (int i = 0; i < container_count; i++) {
        if (containers[i].id == container_id) {
            if (containers[i].state != CONTAINER_PAUSED) return -1;
            containers[i].state = CONTAINER_RUNNING;
            return 0;
        }
    }
    return -1;
}

int container_delete(uint32_t container_id) {
    for (int i = 0; i < container_count; i++) {
        if (containers[i].id == container_id) {
            if (containers[i].state == CONTAINER_RUNNING) {
                container_stop(container_id);
            }

            for (int j = i; j < container_count - 1; j++) {
                containers[j] = containers[j + 1];
            }
            container_count--;
            return 0;
        }
    }
    return -1;
}

int container_expose_port(uint32_t container_id, uint16_t port) {
    for (int i = 0; i < container_count; i++) {
        if (containers[i].id == container_id) {
            if (containers[i].port_count >= 16) return -1;
            containers[i].exposed_ports[containers[i].port_count++] = port;
            return 0;
        }
    }
    return -1;
}

container_t* container_get(uint32_t container_id) {
    for (int i = 0; i < container_count; i++) {
        if (containers[i].id == container_id) {
            return &containers[i];
        }
    }
    return NULL;
}

int container_get_list(container_t *buffer, int max_count) {
    int count = container_count < max_count ? container_count : max_count;
    for (int i = 0; i < count; i++) {
        buffer[i] = containers[i];
    }
    return count;
}

int container_get_count() {
    return container_count;
}

int container_get_running_count() {
    int count = 0;
    for (int i = 0; i < container_count; i++) {
        if (containers[i].state == CONTAINER_RUNNING) {
            count++;
        }
    }
    return count;
}

void container_update_stats(uint32_t container_id) {
    for (int i = 0; i < container_count; i++) {
        if (containers[i].id == container_id && containers[i].state == CONTAINER_RUNNING) {
            containers[i].cpu_usage = 10 + (container_id % 30);
            containers[i].memory_usage = 128 + (container_id * 32);
            containers[i].network_rx += 1024;
            containers[i].network_tx += 512;
        }
    }
}

void container_set_max(int max) {
    max_containers = max;
}

int container_get_max() {
    return max_containers;
}
