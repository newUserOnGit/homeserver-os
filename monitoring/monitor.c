/*
 * Monitoring System
 * System monitoring and logging
 */

#include <stdint.h>
#include <stddef.h>

#define MAX_LOG_ENTRIES 1000
#define MAX_METRICS 50

typedef enum {
    LOG_DEBUG,
    LOG_INFO,
    LOG_WARNING,
    LOG_ERROR,
    LOG_CRITICAL
} log_level_t;

typedef struct {
    uint64_t timestamp;
    log_level_t level;
    char message[256];
    char component[64];
} log_entry_t;

typedef struct {
    char name[64];
    uint32_t value;
    uint64_t timestamp;
} metric_t;

typedef struct {
    uint32_t cpu_usage;
    uint32_t memory_usage;
    uint32_t disk_usage;
    uint32_t network_rx;
    uint32_t network_tx;
    uint32_t active_processes;
    uint32_t active_connections;
    uint64_t uptime;
} system_stats_t;

static log_entry_t log_buffer[MAX_LOG_ENTRIES];
static int log_head = 0;
static int log_count = 0;

static metric_t metrics[MAX_METRICS];
static int metric_count = 0;

static system_stats_t current_stats;
static uint64_t boot_time = 0;

void monitoring_init() {
    log_head = 0;
    log_count = 0;
    metric_count = 0;
    boot_time = 0; // Should be set to actual boot time

    for (int i = 0; i < MAX_LOG_ENTRIES; i++) {
        log_buffer[i].timestamp = 0;
        log_buffer[i].level = LOG_INFO;
        for (int j = 0; j < 256; j++) {
            log_buffer[i].message[j] = 0;
        }
    }

    current_stats.cpu_usage = 0;
    current_stats.memory_usage = 0;
    current_stats.disk_usage = 0;
    current_stats.network_rx = 0;
    current_stats.network_tx = 0;
    current_stats.active_processes = 0;
    current_stats.active_connections = 0;
    current_stats.uptime = 0;
}

void log_message(log_level_t level, const char *component, const char *message) {
    log_entry_t *entry = &log_buffer[log_head];

    entry->timestamp = current_stats.uptime;
    entry->level = level;

    int i;
    for (i = 0; i < 63 && component[i]; i++) {
        entry->component[i] = component[i];
    }
    entry->component[i] = '\0';

    for (i = 0; i < 255 && message[i]; i++) {
        entry->message[i] = message[i];
    }
    entry->message[i] = '\0';

    log_head = (log_head + 1) % MAX_LOG_ENTRIES;
    if (log_count < MAX_LOG_ENTRIES) {
        log_count++;
    }
}

int get_logs(log_entry_t *buffer, int max_entries, log_level_t min_level) {
    int count = 0;
    int start = (log_head - log_count + MAX_LOG_ENTRIES) % MAX_LOG_ENTRIES;

    for (int i = 0; i < log_count && count < max_entries; i++) {
        int idx = (start + i) % MAX_LOG_ENTRIES;
        if (log_buffer[idx].level >= min_level) {
            buffer[count++] = log_buffer[idx];
        }
    }

    return count;
}

void record_metric(const char *name, uint32_t value) {
    for (int i = 0; i < metric_count; i++) {
        int match = 1;
        for (int j = 0; j < 64 && name[j]; j++) {
            if (metrics[i].name[j] != name[j]) {
                match = 0;
                break;
            }
        }
        if (match) {
            metrics[i].value = value;
            metrics[i].timestamp = current_stats.uptime;
            return;
        }
    }

    if (metric_count < MAX_METRICS) {
        int i;
        for (i = 0; i < 63 && name[i]; i++) {
            metrics[metric_count].name[i] = name[i];
        }
        metrics[metric_count].name[i] = '\0';
        metrics[metric_count].value = value;
        metrics[metric_count].timestamp = current_stats.uptime;
        metric_count++;
    }
}

uint32_t get_metric(const char *name) {
    for (int i = 0; i < metric_count; i++) {
        int match = 1;
        for (int j = 0; j < 64 && name[j]; j++) {
            if (metrics[i].name[j] != name[j]) {
                match = 0;
                break;
            }
        }
        if (match) {
            return metrics[i].value;
        }
    }
    return 0;
}

void update_system_stats() {
    // Update CPU usage
    current_stats.cpu_usage = 15; // Placeholder

    // Update memory usage
    current_stats.memory_usage = get_memory_usage();

    // Update disk usage
    current_stats.disk_usage = fs_get_used_space();

    // Update network stats
    current_stats.network_rx += 1024;
    current_stats.network_tx += 512;

    // Update process count
    current_stats.active_processes = get_task_count();

    // Update connection count
    current_stats.active_connections = get_active_connections();

    // Update uptime
    current_stats.uptime++;

    // Record metrics
    record_metric("cpu_usage", current_stats.cpu_usage);
    record_metric("memory_usage", current_stats.memory_usage);
    record_metric("disk_usage", current_stats.disk_usage);
    record_metric("network_rx", current_stats.network_rx);
    record_metric("network_tx", current_stats.network_tx);
}

system_stats_t get_system_stats() {
    return current_stats;
}

void check_alerts() {
    if (current_stats.cpu_usage > 90) {
        log_message(LOG_WARNING, "Monitor", "High CPU usage detected");
    }

    if (current_stats.memory_usage > get_free_memory() * 0.9) {
        log_message(LOG_WARNING, "Monitor", "Low memory available");
    }

    if (current_stats.disk_usage > fs_get_free_space() * 0.9) {
        log_message(LOG_WARNING, "Monitor", "Low disk space");
    }
}

int get_log_count() {
    return log_count;
}

int get_metric_count() {
    return metric_count;
}
