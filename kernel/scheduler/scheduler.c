/*
 * Task Scheduler
 * Round-robin scheduler for multitasking
 */

#include <stdint.h>
#include <stddef.h>

#define MAX_TASKS 256
#define TASK_STACK_SIZE 4096

typedef enum {
    TASK_READY,
    TASK_RUNNING,
    TASK_BLOCKED,
    TASK_TERMINATED
} task_state_t;

typedef struct {
    uint32_t eax, ebx, ecx, edx;
    uint32_t esi, edi, ebp;
    uint32_t eip, esp;
    uint32_t eflags;
} registers_t;

typedef struct task {
    uint32_t id;
    char name[32];
    task_state_t state;
    uint32_t priority;
    uint32_t time_slice;
    registers_t regs;
    uint32_t stack[TASK_STACK_SIZE];
    struct task *next;
} task_t;

static task_t *task_list = NULL;
static task_t *current_task = NULL;
static uint32_t next_task_id = 1;

void scheduler_init() {
    task_list = NULL;
    current_task = NULL;
    next_task_id = 1;
}

task_t* task_create(const char *name, void (*entry_point)(), uint32_t priority) {
    task_t *task = (task_t*)kmalloc(sizeof(task_t));
    if (!task) return NULL;

    task->id = next_task_id++;
    for (int i = 0; i < 32 && name[i]; i++) {
        task->name[i] = name[i];
    }
    task->state = TASK_READY;
    task->priority = priority;
    task->time_slice = 10;

    task->regs.eip = (uint32_t)entry_point;
    task->regs.esp = (uint32_t)&task->stack[TASK_STACK_SIZE - 1];
    task->regs.eflags = 0x202;

    task->next = task_list;
    task_list = task;

    return task;
}

void task_terminate(task_t *task) {
    if (!task) return;
    task->state = TASK_TERMINATED;
}

task_t* scheduler_next() {
    if (!current_task) {
        current_task = task_list;
        return current_task;
    }

    task_t *next = current_task->next;
    while (next) {
        if (next->state == TASK_READY) {
            return next;
        }
        next = next->next;
    }

    next = task_list;
    while (next && next != current_task) {
        if (next->state == TASK_READY) {
            return next;
        }
        next = next->next;
    }

    return current_task;
}

void scheduler_switch() {
    if (!current_task) return;

    task_t *next_task = scheduler_next();
    if (next_task == current_task) return;

    if (current_task->state == TASK_RUNNING) {
        current_task->state = TASK_READY;
    }

    next_task->state = TASK_RUNNING;
    current_task = next_task;
}

void scheduler_yield() {
    scheduler_switch();
}

task_t* get_current_task() {
    return current_task;
}

uint32_t get_task_count() {
    uint32_t count = 0;
    task_t *task = task_list;
    while (task) {
        if (task->state != TASK_TERMINATED) {
            count++;
        }
        task = task->next;
    }
    return count;
}
