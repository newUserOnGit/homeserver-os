# 🚀 Автоматизация работы с GitHub

Этот проект включает скрипты для автоматизации работы с GitHub.

## 📦 Доступные скрипты

### 1. `github-setup.ps1` - Первоначальная настройка

**Что делает:**
- ✅ Проверяет установку Git и GitHub CLI
- ✅ Настраивает Git пользователя (имя и email)
- ✅ Инициализирует Git репозиторий
- ✅ Помогает настроить аутентификацию (GitHub CLI, SSH или HTTPS)
- ✅ Создает репозиторий на GitHub
- ✅ Делает первый коммит и push

**Использование:**
```powershell
.\github-setup.ps1
```

**Когда использовать:** Один раз при первой настройке проекта

---

### 2. `git-push.ps1` - Быстрый push изменений

**Что делает:**
- ✅ Показывает текущие изменения
- ✅ Запрашивает сообщение коммита
- ✅ Добавляет все файлы (git add .)
- ✅ Создает коммит
- ✅ Отправляет на GitHub (git push)

**Использование:**
```powershell
.\git-push.ps1
```

**Когда использовать:** Каждый раз когда нужно отправить изменения на GitHub

---

### 3. `git-push.sh` - Bash версия для Linux/Mac

То же самое что `git-push.ps1`, но для Unix систем.

**Использование:**
```bash
chmod +x git-push.sh
./git-push.sh
```

---

## 🎯 Быстрый старт

### Шаг 1: Первоначальная настройка (один раз)

```powershell
# Перейдите в папку проекта
cd C:\NewProject

# Запустите скрипт настройки
.\github-setup.ps1

# Следуйте инструкциям на экране
```

### Шаг 2: Ежедневное использование

```powershell
# Когда нужно отправить изменения
.\git-push.ps1

# Введите сообщение коммита или нажмите Enter
# Готово!
```

---

## 🔐 Рекомендуемая аутентификация

### Вариант 1: GitHub CLI (Самый простой) ⭐

```powershell
# Установите GitHub CLI
winget install GitHub.cli

# Авторизуйтесь
gh auth login

# Готово! Теперь можно использовать скрипты
```

### Вариант 2: SSH ключ (Самый безопасный)

```powershell
# Сгенерируйте ключ
ssh-keygen -t ed25519 -C "your_email@example.com"

# Скопируйте публичный ключ
cat ~/.ssh/id_ed25519.pub

# Добавьте на GitHub:
# https://github.com/settings/ssh/new
```

---

## 📝 Примеры использования

### Пример 1: Первая настройка

```powershell
PS C:\NewProject> .\github-setup.ps1

==================================
GitHub Setup - Home Server OS
==================================

Проверка установки Git...
✓ Git установлен

Настройка Git пользователя:
Введите ваше имя: John Doe
Введите ваш email: john@example.com
✓ Git пользователь настроен

Выберите метод аутентификации:
  1. GitHub CLI (gh auth login) - Рекомендуется
  2. SSH ключ
  3. HTTPS (потребуется токен)

Выберите метод (1-3): 1

Запуск GitHub CLI аутентификации...
✓ Аутентификация успешна

Создание репозитория на GitHub:
Введите название репозитория: homeserver-os
Публичный репозиторий? (y/n): y

✓ Репозиторий создан
✓ Коммит создан
✓ Отправлено на GitHub

==================================
✓ Настройка завершена!
==================================

Ваш репозиторий:
  https://github.com/johndoe/homeserver-os

Для последующих обновлений используйте:
  .\git-push.ps1
```

### Пример 2: Ежедневное использование

```powershell
PS C:\NewProject> .\git-push.ps1

==================================
Git Push Helper
==================================

Текущий статус:
 M kernel/core/kernel.c
 M docs/technical.md
?? new-feature.c

Введите сообщение коммита: feat: add new kernel feature

Добавляю файлы...
Создаю коммит...
✓ Коммит создан

Отправляю на GitHub...
✓ Успешно отправлено на GitHub!
```

### Пример 3: Автоматическое сообщение

```powershell
PS C:\NewProject> .\git-push.ps1

Введите сообщение коммита: [нажали Enter]

# Автоматически создаст:
# "chore: update project files - 2026-05-07 07:57:25"
```

---

## ❗ Устранение проблем

### Проблема: "git не является внутренней командой"

**Решение:** Установите Git
```powershell
winget install Git.Git
```

### Проблема: "Permission denied (publickey)"

**Решение:** Настройте SSH ключ или используйте GitHub CLI
```powershell
gh auth login
```

### Проблема: "Remote already exists"

**Решение:** Удалите и добавьте заново
```powershell
git remote remove origin
git remote add origin https://github.com/username/repo.git
```

### Проблема: "Failed to push some refs"

**Решение:** Сначала получите изменения
```powershell
git pull --rebase
git push
```

---

## 🎓 Советы

### 1. Используйте осмысленные сообщения коммитов

**Плохо:**
```
update
fix
changes
```

**Хорошо:**
```
feat: add memory paging support
fix: resolve TCP timeout in network stack
docs: update installation guide
```

### 2. Коммитьте часто

Лучше делать много маленьких коммитов, чем один большой.

### 3. Проверяйте перед push

```powershell
# Посмотрите что изменилось
git status
git diff

# Убедитесь что все работает
make test
```

### 4. Используйте .gitignore

Не коммитьте:
- Бинарные файлы (*.bin, *.o)
- Временные файлы (*.tmp, *.log)
- Конфиденциальные данные (пароли, токены)

---

## 📚 Дополнительная информация

Полная документация: [GITHUB_GUIDE.md](GITHUB_GUIDE.md)

### Основные команды Git

```powershell
git status          # Посмотреть изменения
git log             # История коммитов
git diff            # Изменения в файлах
git branch          # Список веток
git checkout -b xxx # Создать новую ветку
git pull            # Получить изменения
git push            # Отправить изменения
```

### Полезные ссылки

- Git документация: https://git-scm.com/doc
- GitHub документация: https://docs.github.com
- GitHub CLI: https://cli.github.com
- Интерактивное обучение: https://learngitbranching.js.org

---

## ✅ Чеклист

Перед использованием убедитесь:

- [ ] Git установлен (`git --version`)
- [ ] GitHub CLI установлен (опционально) (`gh --version`)
- [ ] Настроен Git пользователь (`git config --global user.name`)
- [ ] Настроена аутентификация (GitHub CLI, SSH или токен)
- [ ] Создан репозиторий на GitHub

После этого просто используйте `.\git-push.ps1` для отправки изменений!

---

## 🎉 Готово!

Теперь работа с GitHub стала проще:

1. **Первый раз:** `.\github-setup.ps1`
2. **Каждый день:** `.\git-push.ps1`
3. **Profit!** 🚀

---

*Создано для Home Server OS Project*  
*Дата: 2026-05-07*
