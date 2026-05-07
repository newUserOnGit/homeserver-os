/*
 * Network Stack
 * TCP/IP implementation for home server
 */

#include <stdint.h>
#include <stddef.h>

#define MAX_CONNECTIONS 64
#define BUFFER_SIZE 1500

typedef struct {
    uint8_t octet[4];
} ipv4_addr_t;

typedef struct {
    uint8_t octet[6];
} mac_addr_t;

typedef enum {
    PROTO_ICMP = 1,
    PROTO_TCP = 6,
    PROTO_UDP = 17
} ip_protocol_t;

typedef struct {
    uint8_t version_ihl;
    uint8_t tos;
    uint16_t total_length;
    uint16_t identification;
    uint16_t flags_fragment;
    uint8_t ttl;
    uint8_t protocol;
    uint16_t checksum;
    ipv4_addr_t src_ip;
    ipv4_addr_t dst_ip;
} __attribute__((packed)) ip_header_t;

typedef struct {
    uint16_t src_port;
    uint16_t dst_port;
    uint32_t seq_num;
    uint32_t ack_num;
    uint8_t data_offset;
    uint8_t flags;
    uint16_t window;
    uint16_t checksum;
    uint16_t urgent_ptr;
} __attribute__((packed)) tcp_header_t;

typedef struct {
    uint16_t src_port;
    uint16_t dst_port;
    uint16_t length;
    uint16_t checksum;
} __attribute__((packed)) udp_header_t;

typedef enum {
    CONN_CLOSED,
    CONN_LISTEN,
    CONN_SYN_SENT,
    CONN_SYN_RECEIVED,
    CONN_ESTABLISHED,
    CONN_FIN_WAIT,
    CONN_CLOSE_WAIT,
    CONN_CLOSING,
    CONN_TIME_WAIT
} tcp_state_t;

typedef struct {
    uint32_t id;
    tcp_state_t state;
    ipv4_addr_t local_ip;
    ipv4_addr_t remote_ip;
    uint16_t local_port;
    uint16_t remote_port;
    uint32_t seq_num;
    uint32_t ack_num;
    uint8_t buffer[BUFFER_SIZE];
    uint32_t buffer_len;
} tcp_connection_t;

static tcp_connection_t connections[MAX_CONNECTIONS];
static ipv4_addr_t local_ip;
static mac_addr_t local_mac;

void network_init(ipv4_addr_t ip, mac_addr_t mac) {
    local_ip = ip;
    local_mac = mac;

    for (int i = 0; i < MAX_CONNECTIONS; i++) {
        connections[i].state = CONN_CLOSED;
        connections[i].id = i;
    }
}

uint16_t calculate_checksum(uint16_t *data, int len) {
    uint32_t sum = 0;
    while (len > 1) {
        sum += *data++;
        len -= 2;
    }
    if (len > 0) {
        sum += *(uint8_t*)data;
    }
    while (sum >> 16) {
        sum = (sum & 0xFFFF) + (sum >> 16);
    }
    return ~sum;
}

int tcp_listen(uint16_t port) {
    for (int i = 0; i < MAX_CONNECTIONS; i++) {
        if (connections[i].state == CONN_CLOSED) {
            connections[i].state = CONN_LISTEN;
            connections[i].local_port = port;
            connections[i].local_ip = local_ip;
            return i;
        }
    }
    return -1;
}

int tcp_connect(ipv4_addr_t remote_ip, uint16_t remote_port) {
    for (int i = 0; i < MAX_CONNECTIONS; i++) {
        if (connections[i].state == CONN_CLOSED) {
            connections[i].state = CONN_SYN_SENT;
            connections[i].remote_ip = remote_ip;
            connections[i].remote_port = remote_port;
            connections[i].local_ip = local_ip;
            return i;
        }
    }
    return -1;
}

int tcp_send(int conn_id, uint8_t *data, uint32_t len) {
    if (conn_id < 0 || conn_id >= MAX_CONNECTIONS) return -1;
    if (connections[conn_id].state != CONN_ESTABLISHED) return -1;

    if (len > BUFFER_SIZE) len = BUFFER_SIZE;

    for (uint32_t i = 0; i < len; i++) {
        connections[conn_id].buffer[i] = data[i];
    }
    connections[conn_id].buffer_len = len;

    return len;
}

int tcp_receive(int conn_id, uint8_t *buffer, uint32_t max_len) {
    if (conn_id < 0 || conn_id >= MAX_CONNECTIONS) return -1;
    if (connections[conn_id].state != CONN_ESTABLISHED) return -1;

    uint32_t len = connections[conn_id].buffer_len;
    if (len > max_len) len = max_len;

    for (uint32_t i = 0; i < len; i++) {
        buffer[i] = connections[conn_id].buffer[i];
    }

    return len;
}

void tcp_close(int conn_id) {
    if (conn_id < 0 || conn_id >= MAX_CONNECTIONS) return;
    connections[conn_id].state = CONN_FIN_WAIT;
}

uint32_t get_active_connections() {
    uint32_t count = 0;
    for (int i = 0; i < MAX_CONNECTIONS; i++) {
        if (connections[i].state != CONN_CLOSED) {
            count++;
        }
    }
    return count;
}
