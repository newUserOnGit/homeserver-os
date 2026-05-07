# Техническая документация Home Server OS

## Оглавление
1. [Введение](#введение)
2. [Архитектура системы](#архитектура-системы)
3. [Компоненты ядра](#компоненты-ядра)
4. [API документация](#api-документация)
5. [Разработка](#разработка)
6. [Развертывание](#развертывание)

## Введение

Home Server OS - это специализированная операционная система для домашних серверов с поддержкой:
- Виртуализации (контейнеры и виртуальные машины)
- Сетевых сервисов
- Управления хранилищем
- Веб-интерфейса администрирования
- REST API

## Архитектура системы

### Уровни системы

```
┌─────────────────────────────────────────┐
│     Веб-интерфейс / REST API            │
├─────────────────────────────────────────┤
│     Пользовательское пространство       │
│  (Shell, Utils, Apps, Services)         │
├─────────────────────────────────────────┤
│          Системные библиотеки           │
├─────────────────────────────────────────┤
│              Ядро системы               │
│  (Scheduler, Memory, FS, Network)       │
├─────────────────────────────────────────┤
│             Драйверы устройств          │
│     (Storage, Network, USB)             │
├─────────────────────────────────────────┤
│              Оборудование               │
└─────────────────────────────────────────┘
```

## Компоненты ядра

### Менеджер памяти (kernel/memory/)

Управление физической и виртуальной памятью:
- Постраничное распределение (4KB страницы)
- Bitmap для отслеживания свободных фреймов
- Функции kmalloc/kfree для динамического выделения

**API:**
```c
void memory_init(uint32_t mem_size);
void* kmalloc(size_t size);
void kfree(void* ptr);
uint32_t get_memory_usage();
uint32_t get_free_memory();
```

### Планировщик задач (kernel/scheduler/)

Round-robin планировщик для многозадачности:
- Поддержка до 256 задач
- Приоритеты задач
- Временные кванты

**API:**
```c
void scheduler_init();
task_t* task_create(const char *name, void (*entry_point)(), uint32_t priority);
void task_terminate(task_t *task);
void scheduler_yield();
task_t* get_current_task();
```

### Файловая система (kernel/fs/)

Простая файловая система с поддержкой:
- Обычных файлов и директорий
- Символических ссылок
- Прав доступа
- Блоки по 4KB

**API:**
```c
void fs_init();
int fs_create(const char *path, file_type_t type);
int fs_write(int inode_id, const uint8_t *data, uint32_t size);
int fs_read(int inode_id, uint8_t *buffer, uint32_t size);
int fs_delete(int inode_id);
```

### Сетевой стек (kernel/net/)

TCP/IP стек с поддержкой:
- IPv4
- TCP и UDP протоколы
- До 64 одновременных соединений

**API:**
```c
void network_init(ipv4_addr_t ip, mac_addr_t mac);
int tcp_listen(uint16_t port);
int tcp_connect(ipv4_addr_t remote_ip, uint16_t remote_port);
int tcp_send(int conn_id, uint8_t *data, uint32_t len);
int tcp_receive(int conn_id, uint8_t *buffer, uint32_t max_len);
void tcp_close(int conn_id);
```

### Драйвер хранилища (drivers/storage/)

ATA/SATA драйвер для дисков:
- Поддержка Primary/Secondary Master/Slave
- LBA адресация
- Чтение/запись секторов

**API:**
```c
void storage_init();
int storage_read(int device, uint32_t lba, uint8_t *buffer, uint32_t sectors);
int storage_write(int device, uint32_t lba, const uint8_t *buffer, uint32_t sectors);
int storage_get_device_count();
uint32_t storage_get_device_size(int device);
```

## API документация

### REST API Endpoints

#### Системная информация
```
GET /api/system
Response: {
  "version": "0.1.0",
  "uptime": 3600,
  "processes": 12,
  "cpu_usage": 15
}
```

#### Память
```
GET /api/memory
Response: {
  "total": 16777216,
  "used": 4404019,
  "free": 12373197
}
```

#### Хранилище
```
GET /api/storage
Response: {
  "total": 1048576,
  "used": 350208,
  "free": 698368
}
```

#### Сеть
```
GET /api/network
Response: {
  "ip": "192.168.1.100",
  "rx_bytes": 131072000,
  "tx_bytes": 93323264,
  "connections": 24
}
```

#### Сервисы
```
GET /api/services
Response: {
  "services": [
    {"name": "web", "status": "running"},
    {"name": "ssh", "status": "running"}
  ]
}

POST /api/services
Body: {
  "name": "web",
  "action": "stop"
}
```

#### Контейнеры
```
GET /api/containers
Response: {
  "containers": [
    {"id": 1, "name": "web-app", "status": "running"}
  ],
  "total": 3,
  "max": 10
}
```

#### Виртуальные машины
```
GET /api/vms
Response: {
  "vms": [
    {"id": 1, "name": "test-vm", "status": "running"}
  ],
  "total": 1,
  "max": 5
}
```

## Разработка

### Требования

- GCC (кросс-компилятор для x86_64)
- NASM (ассемблер)
- GNU Make
- GRUB (для создания ISO)
- QEMU (для тестирования)

### Сборка

```bash
# Полная сборка
make all

# Только ядро
make kernel

# Только загрузчик
make bootloader

# Создание ISO образа
make iso

# Очистка
make clean
```

### Тестирование

```bash
# Запуск в QEMU
make run

# Запуск тестов
make test
```

### Структура проекта

```
NewProject/
├── kernel/           # Ядро системы
│   ├── core/        # Основные компоненты
│   ├── drivers/     # Драйверы
│   ├── fs/          # Файловая система
│   ├── net/         # Сетевой стек
│   ├── memory/      # Управление памятью
│   └── scheduler/   # Планировщик
├── bootloader/      # Загрузчик
├── system/          # Системные компоненты
│   ├── init/        # Инициализация
│   ├── services/    # Сервисы
│   └── libs/        # Библиотеки
├── drivers/         # Драйверы устройств
├── userspace/       # Пользовательское пространство
├── web/             # Веб-интерфейс
│   ├── admin-panel/ # Панель администрирования
│   └── api/         # REST API
├── virtualization/  # Виртуализация
├── config/          # Конфигурация
└── docs/            # Документация
```

## Развертывание

### Установка на физическое оборудование

1. Создайте загрузочный USB:
```bash
dd if=build/homeserver.iso of=/dev/sdX bs=4M
```

2. Загрузитесь с USB

3. Следуйте инструкциям установщика

### Установка в виртуальной машине

#### QEMU
```bash
qemu-system-x86_64 -cdrom build/homeserver.iso -m 512M -boot d
```

#### VirtualBox
1. Создайте новую VM (Type: Linux, Version: Other Linux 64-bit)
2. Выделите минимум 512MB RAM
3. Подключите ISO как CD-ROM
4. Запустите VM

#### VMware
1. Создайте новую VM
2. Выберите "Install from disc image"
3. Укажите путь к ISO
4. Настройте параметры и запустите

## Конфигурация

Основной файл конфигурации: `config/system.conf`

```ini
[system]
hostname = homeserver
timezone = UTC

[network]
interface = eth0
dhcp = true

[security]
firewall_enabled = true
ssh_enabled = true
ssh_port = 22

[virtualization]
containers_enabled = true
vms_enabled = true
```

## Безопасность

### Firewall

Встроенный межсетевой экран с поддержкой:
- Фильтрации по IP/порту
- Правил для входящего/исходящего трафика
- Логирования попыток подключения

### Аутентификация

- Поддержка пользователей и групп
- Хеширование паролей
- SSH ключи

## Мониторинг

Система мониторинга отслеживает:
- Использование CPU
- Использование памяти
- Дисковое пространство
- Сетевой трафик
- Состояние сервисов
- Логи системы

## Резервное копирование

Автоматическое резервное копирование:
- Ежедневные бэкапы
- Хранение 7 последних копий
- Инкрементальное копирование
- Восстановление из бэкапа

## Поддержка

- GitHub: https://github.com/homeserver-os
- Документация: https://docs.homeserver-os.org
- Форум: https://forum.homeserver-os.org

## Лицензия

MIT License - см. файл LICENSE
