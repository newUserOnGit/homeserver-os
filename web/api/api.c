/*
 * REST API Server
 * HTTP API for Home Server OS management
 */

#include <stdint.h>
#include <stddef.h>

#define MAX_ROUTES 64
#define MAX_PATH_LENGTH 256

typedef enum {
    HTTP_GET,
    HTTP_POST,
    HTTP_PUT,
    HTTP_DELETE
} http_method_t;

typedef struct {
    int status_code;
    char *body;
    uint32_t body_length;
    char *content_type;
} http_response_t;

typedef struct {
    http_method_t method;
    char path[MAX_PATH_LENGTH];
    char *body;
    uint32_t body_length;
} http_request_t;

typedef http_response_t (*route_handler_t)(http_request_t *req);

typedef struct {
    http_method_t method;
    char path[MAX_PATH_LENGTH];
    route_handler_t handler;
} route_t;

static route_t routes[MAX_ROUTES];
static int route_count = 0;

// API Handlers

http_response_t api_get_system_info(http_request_t *req) {
    http_response_t res;
    res.status_code = 200;
    res.content_type = "application/json";
    res.body = "{"
        "\"version\":\"0.1.0\","
        "\"uptime\":3600,"
        "\"processes\":12,"
        "\"cpu_usage\":15"
    "}";
    res.body_length = 0;
    for (char *p = res.body; *p; p++) res.body_length++;
    return res;
}

http_response_t api_get_memory_info(http_request_t *req) {
    http_response_t res;
    res.status_code = 200;
    res.content_type = "application/json";
    res.body = "{"
        "\"total\":16777216,"
        "\"used\":4404019,"
        "\"free\":12373197"
    "}";
    res.body_length = 0;
    for (char *p = res.body; *p; p++) res.body_length++;
    return res;
}

http_response_t api_get_storage_info(http_request_t *req) {
    http_response_t res;
    res.status_code = 200;
    res.content_type = "application/json";
    res.body = "{"
        "\"total\":1048576,"
        "\"used\":350208,"
        "\"free\":698368"
    "}";
    res.body_length = 0;
    for (char *p = res.body; *p; p++) res.body_length++;
    return res;
}

http_response_t api_get_network_info(http_request_t *req) {
    http_response_t res;
    res.status_code = 200;
    res.content_type = "application/json";
    res.body = "{"
        "\"ip\":\"192.168.1.100\","
        "\"rx_bytes\":131072000,"
        "\"tx_bytes\":93323264,"
        "\"connections\":24"
    "}";
    res.body_length = 0;
    for (char *p = res.body; *p; p++) res.body_length++;
    return res;
}

http_response_t api_get_services(http_request_t *req) {
    http_response_t res;
    res.status_code = 200;
    res.content_type = "application/json";
    res.body = "{"
        "\"services\":["
            "{\"name\":\"web\",\"status\":\"running\"},"
            "{\"name\":\"ssh\",\"status\":\"running\"},"
            "{\"name\":\"dns\",\"status\":\"running\"},"
            "{\"name\":\"ftp\",\"status\":\"stopped\"}"
        "]"
    "}";
    res.body_length = 0;
    for (char *p = res.body; *p; p++) res.body_length++;
    return res;
}

http_response_t api_control_service(http_request_t *req) {
    http_response_t res;
    res.status_code = 200;
    res.content_type = "application/json";
    res.body = "{\"status\":\"success\",\"message\":\"Service updated\"}";
    res.body_length = 0;
    for (char *p = res.body; *p; p++) res.body_length++;
    return res;
}

http_response_t api_get_containers(http_request_t *req) {
    http_response_t res;
    res.status_code = 200;
    res.content_type = "application/json";
    res.body = "{"
        "\"containers\":["
            "{\"id\":1,\"name\":\"web-app\",\"status\":\"running\"},"
            "{\"id\":2,\"name\":\"database\",\"status\":\"running\"},"
            "{\"id\":3,\"name\":\"cache\",\"status\":\"running\"}"
        "],"
        "\"total\":3,"
        "\"max\":10"
    "}";
    res.body_length = 0;
    for (char *p = res.body; *p; p++) res.body_length++;
    return res;
}

http_response_t api_get_vms(http_request_t *req) {
    http_response_t res;
    res.status_code = 200;
    res.content_type = "application/json";
    res.body = "{"
        "\"vms\":["
            "{\"id\":1,\"name\":\"test-vm\",\"status\":\"running\"}"
        "],"
        "\"total\":1,"
        "\"max\":5"
    "}";
    res.body_length = 0;
    for (char *p = res.body; *p; p++) res.body_length++;
    return res;
}

http_response_t api_not_found(http_request_t *req) {
    http_response_t res;
    res.status_code = 404;
    res.content_type = "application/json";
    res.body = "{\"error\":\"Not found\"}";
    res.body_length = 0;
    for (char *p = res.body; *p; p++) res.body_length++;
    return res;
}

void api_register_route(http_method_t method, const char *path, route_handler_t handler) {
    if (route_count >= MAX_ROUTES) return;

    routes[route_count].method = method;
    for (int i = 0; i < MAX_PATH_LENGTH && path[i]; i++) {
        routes[route_count].path[i] = path[i];
    }
    routes[route_count].handler = handler;
    route_count++;
}

void api_init() {
    route_count = 0;

    api_register_route(HTTP_GET, "/api/system", api_get_system_info);
    api_register_route(HTTP_GET, "/api/memory", api_get_memory_info);
    api_register_route(HTTP_GET, "/api/storage", api_get_storage_info);
    api_register_route(HTTP_GET, "/api/network", api_get_network_info);
    api_register_route(HTTP_GET, "/api/services", api_get_services);
    api_register_route(HTTP_POST, "/api/services", api_control_service);
    api_register_route(HTTP_GET, "/api/containers", api_get_containers);
    api_register_route(HTTP_GET, "/api/vms", api_get_vms);
}

http_response_t api_handle_request(http_request_t *req) {
    for (int i = 0; i < route_count; i++) {
        if (routes[i].method != req->method) continue;

        int match = 1;
        for (int j = 0; j < MAX_PATH_LENGTH; j++) {
            if (routes[i].path[j] != req->path[j]) {
                match = 0;
                break;
            }
            if (routes[i].path[j] == '\0') break;
        }

        if (match) {
            return routes[i].handler(req);
        }
    }

    return api_not_found(req);
}
