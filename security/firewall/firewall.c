/*
 * Security System
 * Firewall and authentication
 */

#include <stdint.h>
#include <stddef.h>

#define MAX_FIREWALL_RULES 256
#define MAX_USERS 64
#define MAX_USERNAME_LENGTH 32
#define MAX_PASSWORD_HASH_LENGTH 64

typedef enum {
    RULE_ALLOW,
    RULE_DENY
} rule_action_t;

typedef enum {
    PROTO_ANY,
    PROTO_TCP,
    PROTO_UDP,
    PROTO_ICMP
} protocol_t;

typedef enum {
    DIR_INBOUND,
    DIR_OUTBOUND,
    DIR_BOTH
} direction_t;

typedef struct {
    uint32_t id;
    rule_action_t action;
    protocol_t protocol;
    direction_t direction;
    uint32_t src_ip;
    uint32_t dst_ip;
    uint16_t src_port;
    uint16_t dst_port;
    int enabled;
    char description[128];
} firewall_rule_t;

typedef struct {
    uint32_t blocked_packets;
    uint32_t allowed_packets;
    uint32_t total_packets;
    uint64_t last_block_time;
    uint32_t last_blocked_ip;
} firewall_stats_t;

typedef struct {
    uint32_t id;
    char username[MAX_USERNAME_LENGTH];
    char password_hash[MAX_PASSWORD_HASH_LENGTH];
    uint32_t uid;
    uint32_t gid;
    int is_admin;
    int enabled;
    uint64_t last_login;
    uint32_t failed_attempts;
} user_t;

static firewall_rule_t firewall_rules[MAX_FIREWALL_RULES];
static int rule_count = 0;
static uint32_t next_rule_id = 1;
static int firewall_enabled = 1;
static firewall_stats_t firewall_stats;

static user_t users[MAX_USERS];
static int user_count = 0;
static uint32_t next_user_id = 1;

// Firewall functions

void firewall_init() {
    rule_count = 0;
    next_rule_id = 1;
    firewall_enabled = 1;

    firewall_stats.blocked_packets = 0;
    firewall_stats.allowed_packets = 0;
    firewall_stats.total_packets = 0;
    firewall_stats.last_block_time = 0;
    firewall_stats.last_blocked_ip = 0;

    // Add default rules
    firewall_add_rule(RULE_ALLOW, PROTO_TCP, DIR_INBOUND, 0, 0, 0, 22, "Allow SSH");
    firewall_add_rule(RULE_ALLOW, PROTO_TCP, DIR_INBOUND, 0, 0, 0, 80, "Allow HTTP");
    firewall_add_rule(RULE_ALLOW, PROTO_TCP, DIR_INBOUND, 0, 0, 0, 443, "Allow HTTPS");
    firewall_add_rule(RULE_ALLOW, PROTO_TCP, DIR_INBOUND, 0, 0, 0, 8080, "Allow Admin Panel");
}

uint32_t firewall_add_rule(rule_action_t action, protocol_t protocol, direction_t direction,
                           uint32_t src_ip, uint32_t dst_ip, uint16_t src_port,
                           uint16_t dst_port, const char *description) {
    if (rule_count >= MAX_FIREWALL_RULES) return 0;

    firewall_rule_t *rule = &firewall_rules[rule_count];
    rule->id = next_rule_id++;
    rule->action = action;
    rule->protocol = protocol;
    rule->direction = direction;
    rule->src_ip = src_ip;
    rule->dst_ip = dst_ip;
    rule->src_port = src_port;
    rule->dst_port = dst_port;
    rule->enabled = 1;

    int i;
    for (i = 0; i < 127 && description[i]; i++) {
        rule->description[i] = description[i];
    }
    rule->description[i] = '\0';

    rule_count++;
    return rule->id;
}

int firewall_remove_rule(uint32_t rule_id) {
    for (int i = 0; i < rule_count; i++) {
        if (firewall_rules[i].id == rule_id) {
            for (int j = i; j < rule_count - 1; j++) {
                firewall_rules[j] = firewall_rules[j + 1];
            }
            rule_count--;
            return 0;
        }
    }
    return -1;
}

int firewall_check_packet(protocol_t protocol, direction_t direction,
                          uint32_t src_ip, uint32_t dst_ip,
                          uint16_t src_port, uint16_t dst_port) {
    if (!firewall_enabled) return 1;

    firewall_stats.total_packets++;

    for (int i = 0; i < rule_count; i++) {
        firewall_rule_t *rule = &firewall_rules[i];
        if (!rule->enabled) continue;

        int match = 1;

        if (rule->protocol != PROTO_ANY && rule->protocol != protocol) {
            match = 0;
        }

        if (rule->direction != DIR_BOTH && rule->direction != direction) {
            match = 0;
        }

        if (rule->src_ip != 0 && rule->src_ip != src_ip) {
            match = 0;
        }

        if (rule->dst_ip != 0 && rule->dst_ip != dst_ip) {
            match = 0;
        }

        if (rule->src_port != 0 && rule->src_port != src_port) {
            match = 0;
        }

        if (rule->dst_port != 0 && rule->dst_port != dst_port) {
            match = 0;
        }

        if (match) {
            if (rule->action == RULE_ALLOW) {
                firewall_stats.allowed_packets++;
                return 1;
            } else {
                firewall_stats.blocked_packets++;
                firewall_stats.last_block_time = 0; // Should be current time
                firewall_stats.last_blocked_ip = src_ip;
                return 0;
            }
        }
    }

    // Default deny
    firewall_stats.blocked_packets++;
    return 0;
}

void firewall_enable() {
    firewall_enabled = 1;
}

void firewall_disable() {
    firewall_enabled = 0;
}

int firewall_is_enabled() {
    return firewall_enabled;
}

firewall_stats_t firewall_get_stats() {
    return firewall_stats;
}

int firewall_get_rules(firewall_rule_t *buffer, int max_count) {
    int count = rule_count < max_count ? rule_count : max_count;
    for (int i = 0; i < count; i++) {
        buffer[i] = firewall_rules[i];
    }
    return count;
}

// Authentication functions

void auth_init() {
    user_count = 0;
    next_user_id = 1;

    // Create default admin user
    auth_create_user("admin", "admin", 0, 0, 1);
}

static uint32_t simple_hash(const char *str) {
    uint32_t hash = 5381;
    int c;
    while ((c = *str++)) {
        hash = ((hash << 5) + hash) + c;
    }
    return hash;
}

uint32_t auth_create_user(const char *username, const char *password,
                          uint32_t uid, uint32_t gid, int is_admin) {
    if (user_count >= MAX_USERS) return 0;

    user_t *user = &users[user_count];
    user->id = next_user_id++;
    user->uid = uid;
    user->gid = gid;
    user->is_admin = is_admin;
    user->enabled = 1;
    user->last_login = 0;
    user->failed_attempts = 0;

    int i;
    for (i = 0; i < MAX_USERNAME_LENGTH - 1 && username[i]; i++) {
        user->username[i] = username[i];
    }
    user->username[i] = '\0';

    uint32_t hash = simple_hash(password);
    for (i = 0; i < 8; i++) {
        user->password_hash[i] = (hash >> (i * 4)) & 0xFF;
    }
    user->password_hash[8] = '\0';

    user_count++;
    return user->id;
}

int auth_verify_user(const char *username, const char *password) {
    uint32_t password_hash = simple_hash(password);

    for (int i = 0; i < user_count; i++) {
        user_t *user = &users[i];
        if (!user->enabled) continue;

        int match = 1;
        for (int j = 0; j < MAX_USERNAME_LENGTH && username[j]; j++) {
            if (user->username[j] != username[j]) {
                match = 0;
                break;
            }
        }

        if (match) {
            uint32_t stored_hash = 0;
            for (int j = 0; j < 8; j++) {
                stored_hash |= ((uint32_t)user->password_hash[j]) << (j * 4);
            }

            if (stored_hash == password_hash) {
                user->last_login = 0; // Should be current time
                user->failed_attempts = 0;
                return user->id;
            } else {
                user->failed_attempts++;
                if (user->failed_attempts >= 5) {
                    user->enabled = 0; // Lock account after 5 failed attempts
                }
                return -1;
            }
        }
    }

    return -1;
}

int auth_delete_user(uint32_t user_id) {
    for (int i = 0; i < user_count; i++) {
        if (users[i].id == user_id) {
            for (int j = i; j < user_count - 1; j++) {
                users[j] = users[j + 1];
            }
            user_count--;
            return 0;
        }
    }
    return -1;
}

int auth_is_admin(uint32_t user_id) {
    for (int i = 0; i < user_count; i++) {
        if (users[i].id == user_id) {
            return users[i].is_admin;
        }
    }
    return 0;
}

int auth_get_users(user_t *buffer, int max_count) {
    int count = user_count < max_count ? user_count : max_count;
    for (int i = 0; i < count; i++) {
        buffer[i] = users[i];
    }
    return count;
}

int auth_get_user_count() {
    return user_count;
}
