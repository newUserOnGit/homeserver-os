# 🚀 Как отправить проект на GitHub

## Быстрый способ (Windows)

### Вариант 1: Использовать BAT скрипт (Рекомендуется)

1. Откройте проводник Windows
2. Перейдите в `C:\Custom-server-os`
3. Дважды кликните на файл: **`git-setup-and-push.bat`**
4. Следуйте инструкциям на экране

### Вариант 2: Использовать Bash скрипт (в Git Bash)

1. Откройте Git Bash в директории `C:\Custom-server-os`
2. Выполните:
   ```bash
   bash git-setup-and-push.sh
   ```

---

## Пошаговая инструкция (вручную)

### Шаг 1: Создайте репозиторий на GitHub

1. Перейдите на https://github.com/new
2. Заполните:
   - **Repository name:** `custom-server-os`
   - **Description:** `Custom Server OS - Linux Edition based on Linux Kernel 6.12.28`
   - **Visibility:** Public или Private (на ваш выбор)
3. **НЕ** ставьте галочки:
   - ❌ Add a README file
   - ❌ Add .gitignore
   - ❌ Choose a license
4. Нажмите **"Create repository"**
5. Скопируйте URL репозитория (например: `https://github.com/username/custom-server-os.git`)

### Шаг 2: Инициализируйте Git в проекте

Откройте PowerShell или Git Bash в `C:\Custom-server-os` и выполните:

```bash
# Инициализация Git
git init

# Настройка пользователя (если еще не настроено)
git config user.name "Ваше Имя"
git config user.email "your.email@example.com"

# Добавление удаленного репозитория
git remote add origin https://github.com/username/custom-server-os.git
```

### Шаг 3: Добавьте файлы и создайте коммит

```bash
# Добавить все файлы
git add .

# Создать коммит
git commit -m "feat: integrate Linux kernel 6.12.28

- Added Linux kernel 6.12.28 from C:/core
- Created optimized kernel configuration for server use
- Set up build system (Makefile + scripts)
- Added comprehensive documentation
- Configured KVM virtualization support
- Enabled container support (namespaces, cgroups)
- Set up network stack (bridge, VLAN, firewall)
- Added LVM/RAID support

Version: 0.2.0
Status: Ready for build in Linux environment"
```

### Шаг 4: Отправьте на GitHub

```bash
# Переименовать ветку в main (если нужно)
git branch -M main

# Отправить на GitHub
git push -u origin main
```

---

## Если возникли проблемы

### Проблема: Git не установлен

**Решение:** Установите Git
- Скачайте: https://git-scm.com/downloads
- Установите с настройками по умолчанию
- Перезапустите терминал

### Проблема: Ошибка аутентификации

**Решение:** Используйте Personal Access Token

1. Перейдите на https://github.com/settings/tokens
2. Нажмите "Generate new token (classic)"
3. Выберите срок действия и права доступа (минимум: `repo`)
4. Скопируйте токен
5. При запросе пароля используйте токен вместо пароля

### Проблема: Большой размер репозитория

**Решение:** Ядро Linux занимает 1.6 GB

Если GitHub отклоняет push из-за размера:

1. Используйте Git LFS для больших файлов:
   ```bash
   git lfs install
   git lfs track "linux-kernel/**"
   git add .gitattributes
   git commit -m "chore: add Git LFS tracking"
   git push -u origin main
   ```

2. Или создайте отдельный репозиторий без ядра:
   ```bash
   # Добавьте в .gitignore
   echo "linux-kernel/" >> .gitignore
   git add .gitignore
   git commit -m "chore: exclude linux kernel from repo"
   ```

---

## После успешной отправки

Ваш проект будет доступен по адресу:
```
https://github.com/username/custom-server-os
```

### Рекомендуемые следующие шаги:

1. **Добавьте описание репозитория** на GitHub
2. **Добавьте темы (topics):**
   - `linux`
   - `operating-system`
   - `server`
   - `kernel`
   - `virtualization`
3. **Создайте Release:**
   - Перейдите в "Releases"
   - Нажмите "Create a new release"
   - Tag: `v0.2.0`
   - Title: `v0.2.0 - Linux Kernel Integration`
   - Описание: скопируйте из `INTEGRATION_COMPLETE.md`

---

## Полезные команды Git

```bash
# Проверить статус
git status

# Посмотреть изменения
git diff

# Посмотреть историю коммитов
git log --oneline

# Отправить изменения
git push

# Получить изменения
git pull

# Создать новую ветку
git checkout -b feature/new-feature

# Переключиться на ветку
git checkout main

# Посмотреть удаленные репозитории
git remote -v
```

---

## Структура коммитов (для будущих изменений)

Используйте Conventional Commits:

```
feat: добавление новой функции
fix: исправление бага
docs: изменения в документации
style: форматирование кода
refactor: рефакторинг
test: добавление тестов
chore: обновление зависимостей, конфигурации
```

Примеры:
```bash
git commit -m "feat: add web admin panel"
git commit -m "fix: resolve kernel build error"
git commit -m "docs: update README with build instructions"
```

---

## Нужна помощь?

- **GitHub Docs:** https://docs.github.com
- **Git Docs:** https://git-scm.com/doc
- **Проблемы с проектом:** Создайте Issue в репозитории

---

**Удачи с вашим проектом! 🚀**
