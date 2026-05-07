# Custom Server OS - Linux Edition

<div align="center">

![Version](https://img.shields.io/badge/version-0.2.0-blue.svg)
![Kernel](https://img.shields.io/badge/kernel-Linux%206.12.28-green.svg)
![License](https://img.shields.io/badge/license-GPL%2FMIT-green.svg)
![Platform](https://img.shields.io/badge/platform-x86__64-lightgrey.svg)
![Status](https://img.shields.io/badge/status-development-orange.svg)

**Специализированная операционная система для домашних серверов на базе Linux**

[Возможности](#возможности) • [Быстрый старт](#быстрый-старт) • [Документация](#документация) • [Архитектура](#архитектура)

</div>

---

## 📋 О проекте

Custom Server OS - это Linux-дистрибутив, специально разработанный для домашних серверов. Основан на ядре Linux 6.12.28 с кастомной конфигурацией и уникальными компонентами для управления сервером.

### ✨ Возможности

- 🐧 **Linux Kernel 6.12.28** - Стабильное production-ready ядро
- 🖥️ **Веб-интерфейс** - Современная панель управления
- 🔌 **REST API** - Полный программный доступ
- 📦 **Контейнеризация** - Docker/LXC поддержка
- 💻 **Виртуализация** - KVM/QEMU интеграция
- 💾 **Автоматический бэкап** - Защита данных
- 🔒 **Встроенный Firewall** - iptables/nftables
- 📊 **Мониторинг** - Отслеживание ресурсов
- 🌐 **Полный TCP/IP стек** - IPv4/IPv6 поддержка

## 🏗️ Архитектура

```
Custom Server OS
├── Linux Kernel 6.12.28
│   ├── KVM виртуализация
│   ├── Namespaces/cgroups (контейнеры)
│   ├── Netfilter (firewall)
│   ├── Device Mapper (LVM/RAID)
│   └── Современные ФС (ext4, btrfs, xfs)
│
├── Userspace
│   ├── Init система
│   ├── Базовые утилиты
│   └── Системные сервисы
│
└── Custom Components
    ├── Web Admin Panel
    ├── REST API
    ├── Container Manager
    ├── VM Manager
    └── Monitoring System
```

## 🚀 Быстрый старт

### Системные требования

**Для сборки:**
- Linux система (Ubuntu/Debian/Fedora)
- GCC компилятор
- Make
- GRUB tools (grub-mkrescue)
- 4GB+ свободного места
- 4GB+ RAM

**Для запуска:**
- Процессор: x86_64 с поддержкой виртуализации
- RAM: 512 MB минимум, 2GB+ рекомендуется
- Диск: 4 GB минимум

### Сборка системы

```bash
# 1. Перейдите в директорию проекта
cd C:/Custom-server-os

# 2. Проверьте зависимости
make check

# 3. Соберите систему (займет 30-60 минут)
make all

# 4. Протестируйте в QEMU
make test
```

### Детальная сборка

```bash
# Собрать только ядро
make kernel

# Собрать только rootfs
make rootfs

# Собрать ISO образ
make iso

# Очистить артефакты сборки
make clean

# Полная очистка (включая ядро)
make distclean
```

### Тестирование

```bash
# Базовый тест (512MB RAM)
make test

# Тест с 2GB RAM
make run-2g

# Тест с сетью
make run-net

# Информация о сборке
make info
```

## 📚 Структура проекта

```
custom-server-os/
├── linux-kernel/          # Ядро Linux 6.12.28
├── kernel/                # Старое ядро (справочно)
├── config/
│   ├── kernel.config      # Конфигурация ядра
│   └── system.conf        # Системная конфигурация
├── build/
│   ├── scripts/           # Скрипты сборки
│   │   ├── build-kernel.sh
│   │   ├── build-rootfs.sh
│   │   └── build-iso.sh
│   ├── kernel-output/     # Собранное ядро
│   ├── rootfs/            # Корневая ФС
│   └── custom-server-os.iso
├── web/                   # Веб-интерфейс
├── docs/                  # Документация
├── tests/                 # Тесты
└── Makefile              # Главный файл сборки
```

## 🔧 Конфигурация ядра

Ядро настроено специально для серверного использования:

### Включено:
- ✅ KVM виртуализация (Intel/AMD)
- ✅ Namespaces и cgroups (контейнеры)
- ✅ Bridge, VLAN, VXLAN (сетевая виртуализация)
- ✅ Device Mapper (LVM, RAID 0/1/5/6/10)
- ✅ ext4, btrfs, xfs, overlay (файловые системы)
- ✅ iptables/nftables (firewall)
- ✅ SELinux/AppArmor (безопасность)

### Отключено:
- ❌ Графические драйверы
- ❌ Звуковые карты
- ❌ Bluetooth
- ❌ Wireless

## 🖥️ Использование

### Загрузка ISO

```bash
# Записать на USB (Linux)
sudo dd if=build/custom-server-os.iso of=/dev/sdX bs=4M status=progress

# Или запустить в VirtualBox/VMware
```

### Первый запуск

1. Загрузитесь с ISO
2. Войдите как `root` (без пароля)
3. Настройте сеть: `dhclient eth0`
4. Откройте веб-интерфейс: `http://IP:8080`

## 🔌 REST API

```bash
# Системная информация
curl http://localhost:8081/api/system

# Управление контейнерами
curl http://localhost:8081/api/containers

# Управление VM
curl http://localhost:8081/api/vms

# Мониторинг
curl http://localhost:8081/api/monitoring
```

## 📖 Документация

- **[Стратегия интеграции](INTEGRATION_STRATEGY.md)** - Детали интеграции Linux
- **[План интеграции](INTEGRATION_PLAN.md)** - Этапы интеграции
- **[Техническая документация](docs/technical.md)** - Архитектура и API
- **[Руководство разработчика](CONTRIBUTING.md)** - Участие в разработке

## 🗺️ Roadmap

### v0.2.0 (Текущая) - Linux Integration ✓
- [x] Интеграция ядра Linux 6.12.28
- [x] Кастомная конфигурация ядра
- [x] Система сборки
- [ ] Минимальный userspace
- [ ] Загрузка в QEMU

### v0.3.0 - Core Features
- [ ] Веб-интерфейс управления
- [ ] REST API
- [ ] Базовая контейнеризация
- [ ] Базовая виртуализация

### v0.4.0 - Advanced Features
- [ ] Docker интеграция
- [ ] KVM/libvirt интеграция
- [ ] Система мониторинга
- [ ] Автоматический backup

### v1.0.0 - Production Ready
- [ ] Стабильный релиз
- [ ] Полная документация
- [ ] Автоматические обновления
- [ ] Security hardening

## 🤝 Участие в разработке

Мы приветствуем вклад в проект!

```bash
# 1. Форкните репозиторий
# 2. Создайте ветку
git checkout -b feature/amazing-feature

# 3. Внесите изменения и закоммитьте
git commit -m 'feat: add amazing feature'

# 4. Запушьте
git push origin feature/amazing-feature

# 5. Откройте Pull Request
```

## 📄 Лицензия

- **Ядро Linux:** GPL v2 (см. linux-kernel/COPYING)
- **Custom компоненты:** MIT License (см. LICENSE)

## 🙏 Благодарности

- Linux Kernel разработчикам
- Сообществу open source
- Всем контрибьюторам проекта

## 📞 Контакты

- **GitHub:** https://github.com/yourusername/custom-server-os
- **Issues:** https://github.com/yourusername/custom-server-os/issues

## ⚠️ Важно

Это проект в активной разработке. Не используйте в production без тщательного тестирования.

---

<div align="center">

**Сделано с ❤️ для сообщества домашних серверов**

**Powered by Linux Kernel 6.12.28**

</div>
