# WSL2 Installation Progress

Date: 2026-05-07
Time: 09:21 UTC

## Status: REBOOT REQUIRED

### Completed Steps:

✅ **Step 1: Enable WSL Feature**
```
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux
```
Status: SUCCESS

✅ **Step 2: Enable Virtual Machine Platform**
```
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform
```
Status: SUCCESS

### Next Steps:

⏳ **Step 3: REBOOT COMPUTER** (REQUIRED!)

После перезагрузки выполните:

```powershell
# 1. Установить WSL2 как версию по умолчанию
wsl --set-default-version 2

# 2. Установить Ubuntu 22.04
wsl --install -d Ubuntu-22.04

# 3. Запустить Ubuntu (первый запуск)
wsl

# 4. Создать пользователя и пароль (будет запрошено)

# 5. Обновить систему
sudo apt update && sudo apt upgrade -y

# 6. Установить инструменты для сборки
sudo apt install -y build-essential git vim nano \
    libncurses-dev flex bison libssl-dev libelf-dev \
    bc python3 python3-pip qemu-system-x86

# 7. Создать ссылки на проект
ln -s /mnt/c/NewProject ~/homeserver-os
ln -s /mnt/c/core/linux-6.12.28 ~/linux-kernel

# 8. Начать работу
cd ~/linux-kernel
make defconfig
```

## Important Notes

⚠️ **ОБЯЗАТЕЛЬНО ПЕРЕЗАГРУЗИТЕ КОМПЬЮТЕР СЕЙЧАС!**

Без перезагрузки WSL не будет работать.

## After Reboot

После перезагрузки откройте PowerShell и выполните:

```powershell
wsl --set-default-version 2
wsl --install -d Ubuntu-22.04
```

Или просто скажите мне "continue" и я продолжу установку автоматически.

## Troubleshooting

Если после перезагрузки возникнут проблемы:

1. **Проверить статус WSL:**
   ```powershell
   wsl --status
   ```

2. **Список доступных дистрибутивов:**
   ```powershell
   wsl --list --online
   ```

3. **Обновить WSL:**
   ```powershell
   wsl --update
   ```

---

**ПЕРЕЗАГРУЗИТЕ КОМПЬЮТЕР СЕЙЧАС!**

После перезагрузки вернитесь сюда и скажите "continue".
