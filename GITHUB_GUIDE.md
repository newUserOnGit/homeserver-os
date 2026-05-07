# 🚀 Инструкция по работе с GitHub

## 📋 Быстрый старт

### Шаг 1: Первоначальная настройка (один раз)

Запустите скрипт настройки:

**Windows (PowerShell):**
```powershell
cd C:\NewProject
.\github-setup.ps1
```

**Linux/Mac (Bash):**
```bash
cd /path/to/NewProject
chmod +x github-setup.sh
./github-setup.sh
```

Скрипт автоматически:
- ✅ Проверит установку Git
- ✅ Настроит ваше имя и email
- ✅ Инициализирует Git репозиторий
- ✅ Поможет настроить аутентификацию
- ✅ Создаст репозиторий на GitHub
- ✅ Сделает первый коммит и push

---

## 🔄 Ежедневное использование

После первоначальной настройки используйте простой скрипт для отправки изменений:

**Windows (PowerShell):**
```powershell
.\git-push.ps1
```

**Linux/Mac (Bash):**
```bash
./git-push.sh
```

Скрипт:
1. Покажет текущие изменения
2. Попросит ввести сообщение коммита (или создаст автоматическое)
3. Добавит все файлы
4. Создаст коммит
5. Отправит на GitHub

---

## 📝 Примеры использования

### Пример 1: Быстрое обновление

```powershell
# Запустите скрипт
.\git-push.ps1

# Введите сообщение или нажмите Enter для автоматического
# Готово! Изменения на GitHub
```

### Пример 2: С конкретным сообщением

```powershell
.\git-push.ps1
# Введите: "feat: add new kernel feature"
```

### Пример 3: Ручной способ

```powershell
git add .
git commit -m "feat: update documentation"
git push
```

---

## 🔐 Методы аутентификации

### Метод 1: GitHub CLI (Рекомендуется) ⭐

**Установка:**
```powershell
winget install GitHub.cli
```

**Аутентификация:**
```powershell
gh auth login
```

**Преимущества:**
- ✅ Самый простой способ
- ✅ Автоматическое управление токенами
- ✅ Работает из коробки

### Метод 2: SSH ключ

**Генерация ключа:**
```powershell
ssh-keygen -t ed25519 -C "your_email@example.com"
```

**Добавление на GitHub:**
1. Скопируйте содержимое `~/.ssh/id_ed25519.pub`
2. Перейдите на https://github.com/settings/ssh/new
3. Вставьте ключ и сохраните

**Преимущества:**
- ✅ Безопасно
- ✅ Не нужно вводить пароль
- ✅ Работает везде

### Метод 3: Personal Access Token (HTTPS)

**Создание токена:**
1. Перейдите на https://github.com/settings/tokens/new
2. Выберите права: `repo` (полный доступ)
3. Создайте токен и сохраните его

**Использование:**
```powershell
git remote set-url origin https://YOUR_TOKEN@github.com/username/repo.git
```

**Преимущества:**
- ✅ Работает везде
- ✅ Можно отозвать
- ⚠️ Нужно хранить токен безопасно

---

## 🎯 Типичные сценарии

### Сценарий 1: Ежедневная работа

```powershell
# Утром - получить последние изменения
git pull

# Работаете над проектом...

# Вечером - отправить изменения
.\git-push.ps1
```

### Сценарий 2: Работа с ветками

```powershell
# Создать новую ветку для функции
git checkout -b feature/new-feature

# Работаете...

# Отправить ветку
git push -u origin feature/new-feature

# Создать Pull Request на GitHub
gh pr create
```

### Сценарий 3: Исправление ошибки

```powershell
# Создать ветку для исправления
git checkout -b fix/bug-name

# Исправить ошибку...

# Отправить
.\git-push.ps1
# Введите: "fix: resolve memory leak in scheduler"
```

---

## 🛠️ Полезные команды

### Просмотр статуса
```powershell
git status              # Текущие изменения
git log --oneline       # История коммитов
git diff                # Изменения в файлах
```

### Отмена изменений
```powershell
git checkout -- file.c  # Отменить изменения в файле
git reset HEAD~1        # Отменить последний коммит (сохранить изменения)
git reset --hard HEAD~1 # Отменить последний коммит (удалить изменения)
```

### Работа с ветками
```powershell
git branch              # Список веток
git checkout main       # Переключиться на main
git merge feature/xxx   # Слить ветку
git branch -d feature/xxx # Удалить ветку
```

### Синхронизация
```powershell
git pull                # Получить изменения
git fetch               # Получить информацию о изменениях
git push                # Отправить изменения
```

---

## ❗ Решение проблем

### Проблема: "Permission denied"

**Решение:**
```powershell
# Проверьте аутентификацию
gh auth status

# Или перелогиньтесь
gh auth login
```

### Проблема: "Remote already exists"

**Решение:**
```powershell
# Удалите старый remote
git remote remove origin

# Добавьте новый
git remote add origin https://github.com/username/repo.git
```

### Проблема: "Failed to push"

**Решение:**
```powershell
# Сначала получите изменения
git pull --rebase

# Затем отправьте
git push
```

### Проблема: Конфликты при merge

**Решение:**
```powershell
# Посмотрите конфликтующие файлы
git status

# Отредактируйте файлы, удалив маркеры конфликтов
# <<<<<<< HEAD
# ваш код
# =======
# чужой код
# >>>>>>> branch

# Добавьте исправленные файлы
git add .

# Завершите merge
git commit
```

---

## 📚 Дополнительные ресурсы

### Документация
- Git: https://git-scm.com/doc
- GitHub: https://docs.github.com
- GitHub CLI: https://cli.github.com/manual/

### Обучение
- Git Tutorial: https://git-scm.com/docs/gittutorial
- GitHub Skills: https://skills.github.com
- Interactive Git: https://learngitbranching.js.org

### Шпаргалки
- Git Cheat Sheet: https://education.github.com/git-cheat-sheet-education.pdf
- GitHub Flow: https://guides.github.com/introduction/flow/

---

## 🎓 Conventional Commits

Используйте стандартные префиксы для коммитов:

```
feat:     новая функция
fix:      исправление бага
docs:     изменения в документации
style:    форматирование кода
refactor: рефакторинг
test:     добавление тестов
chore:    обновление зависимостей, конфигов
perf:     улучшение производительности
ci:       изменения в CI/CD
```

**Примеры:**
```powershell
git commit -m "feat(kernel): add memory paging support"
git commit -m "fix(network): resolve TCP timeout issue"
git commit -m "docs: update installation guide"
git commit -m "refactor(scheduler): optimize task switching"
```

---

## ✅ Чеклист перед push

- [ ] Код компилируется без ошибок
- [ ] Тесты проходят
- [ ] Документация обновлена
- [ ] Коммит имеет понятное сообщение
- [ ] Нет конфиденциальных данных (пароли, токены)
- [ ] .gitignore настроен правильно

---

## 🚀 Готово!

Теперь вы можете легко работать с GitHub:

1. **Первый раз:** `.\github-setup.ps1`
2. **Каждый день:** `.\git-push.ps1`
3. **Готово!** Ваш код на GitHub

**Вопросы?** Создайте issue на GitHub или обратитесь к документации.

---

*Последнее обновление: 2026-05-07*
