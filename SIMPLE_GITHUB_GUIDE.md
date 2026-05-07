# 🚀 Простая инструкция по работе с GitHub (БЕЗ GitHub CLI)

## 📦 Что нужно установить

### Только Git (обязательно)

**Способ 1: Прямая загрузка (Рекомендуется)**
1. Перейдите на https://git-scm.com/download/win
2. Скачайте установщик
3. Запустите и следуйте инструкциям
4. Готово!

**Способ 2: Через Chocolatey (если установлен)**
```powershell
choco install git
```

**Способ 3: Через Scoop (если установлен)**
```powershell
scoop install git
```

**Проверка установки:**
```powershell
git --version
# Должно показать: git version 2.x.x
```

---

## 🎯 Быстрый старт (3 шага)

### Шаг 1: Создайте репозиторий на GitHub

1. Перейдите на https://github.com/new
2. Введите название: `homeserver-os`
3. Описание: `Home Server OS - Operating system for home servers`
4. **ВАЖНО:** НЕ ставьте галочку "Add a README file"
5. Нажмите "Create repository"
6. **Скопируйте URL** репозитория (например: `https://github.com/username/homeserver-os.git`)

### Шаг 2: Создайте Personal Access Token

1. Перейдите на https://github.com/settings/tokens/new
2. Название: `homeserver-os-token`
3. Срок действия: `90 days` (или больше)
4. Выберите права:
   - ✅ `repo` (полный доступ к репозиториям)
5. Нажмите "Generate token"
6. **ВАЖНО:** Скопируйте токен и сохраните в безопасном месте!
   - Токен выглядит так: `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`
   - Вы больше не сможете его увидеть!

### Шаг 3: Используйте простой скрипт

```powershell
cd C:\NewProject
.\simple-git-push.ps1
```

Скрипт спросит:
1. Ваш GitHub username
2. Название репозитория
3. Метод аутентификации (выберите HTTPS)

При первом push Git попросит:
- **Username:** ваш GitHub username
- **Password:** вставьте ваш Personal Access Token (НЕ пароль!)

---

## 📝 Ежедневное использование

После первой настройки просто запускайте:

```powershell
cd C:\NewProject
.\simple-git-push.ps1
```

Введите сообщение коммита или нажмите Enter для автоматического.

Готово! 🚀

---

## 🔐 Сохранение учетных данных (чтобы не вводить каждый раз)

После первого успешного push выполните:

```powershell
git config --global credential.helper store
```

Теперь Git запомнит ваш токен, и вам не нужно будет вводить его каждый раз!

---

## 🎓 Альтернативный способ: SSH ключ (более безопасный)

### Создание SSH ключа:

```powershell
# Генерация ключа
ssh-keygen -t ed25519 -C "your_email@example.com"

# Нажмите Enter 3 раза (использовать настройки по умолчанию)

# Скопируйте публичный ключ
cat ~/.ssh/id_ed25519.pub
```

### Добавление на GitHub:

1. Перейдите на https://github.com/settings/ssh/new
2. Название: `My Computer`
3. Вставьте содержимое `id_ed25519.pub`
4. Нажмите "Add SSH key"

### Использование SSH:

При настройке в скрипте выберите метод "2. SSH"

URL будет: `git@github.com:username/homeserver-os.git`

---

## 📋 Ручной способ (без скриптов)

Если хотите делать всё вручную:

### Первый раз:

```powershell
cd C:\NewProject

# Инициализация
git init

# Настройка пользователя
git config --global user.name "Your Name"
git config --global user.email "your_email@example.com"

# Добавление remote
git remote add origin https://github.com/username/homeserver-os.git

# Первый коммит
git add .
git commit -m "feat: initial commit - Home Server OS v0.1.0"

# Отправка
git branch -M main
git push -u origin main
```

### Каждый день:

```powershell
cd C:\NewProject

# Добавить изменения
git add .

# Создать коммит
git commit -m "feat: your message here"

# Отправить на GitHub
git push
```

---

## ❗ Решение проблем

### Проблема: "git не является внутренней командой"

**Решение:** Git не установлен или не добавлен в PATH
```powershell
# Переустановите Git с https://git-scm.com/download/win
# При установке выберите "Add to PATH"
```

### Проблема: "Authentication failed"

**Решение:** Неверный токен или username
- Убедитесь, что используете **токен**, а не пароль
- Проверьте, что токен имеет права `repo`
- Создайте новый токен если старый истек

### Проблема: "Repository not found"

**Решение:** Репозиторий не существует или неверный URL
- Проверьте, что репозиторий создан на GitHub
- Проверьте правильность URL
- Убедитесь, что username написан правильно

### Проблема: "Failed to push"

**Решение:** Нужно сначала получить изменения
```powershell
git pull --rebase
git push
```

---

## 💡 Полезные команды

```powershell
# Посмотреть статус
git status

# Посмотреть изменения
git diff

# История коммитов
git log --oneline

# Отменить изменения в файле
git checkout -- filename

# Посмотреть remote URL
git remote -v

# Изменить remote URL
git remote set-url origin NEW_URL
```

---

## 🎯 Сравнение методов

| Метод | Сложность | Безопасность | Удобство |
|-------|-----------|--------------|----------|
| **Personal Access Token (HTTPS)** | ⭐⭐ Легко | ⭐⭐⭐ Хорошо | ⭐⭐⭐ Отлично |
| **SSH ключ** | ⭐⭐⭐ Средне | ⭐⭐⭐⭐ Отлично | ⭐⭐⭐⭐ Отлично |
| **GitHub CLI** | ⭐ Очень легко | ⭐⭐⭐⭐ Отлично | ⭐⭐⭐⭐⭐ Идеально |

**Рекомендация:** Начните с Personal Access Token (HTTPS), это самый простой способ!

---

## 📚 Дополнительные ресурсы

- Git документация: https://git-scm.com/doc
- GitHub документация: https://docs.github.com
- Создание токена: https://github.com/settings/tokens
- SSH ключи: https://docs.github.com/en/authentication/connecting-to-github-with-ssh

---

## ✅ Чеклист готовности

- [ ] Git установлен (`git --version`)
- [ ] Создан аккаунт на GitHub
- [ ] Создан репозиторий на GitHub
- [ ] Создан Personal Access Token
- [ ] Токен сохранен в безопасном месте
- [ ] Готовы использовать `simple-git-push.ps1`

---

## 🎉 Готово!

Теперь вы можете работать с GitHub без GitHub CLI:

1. **Первый раз:** Создайте репозиторий и токен
2. **Запустите:** `.\simple-git-push.ps1`
3. **Каждый день:** Просто запускайте `.\simple-git-push.ps1`

Это так же просто, как с GitHub CLI! 🚀

---

*Создано для Home Server OS Project*  
*Дата: 2026-05-07*
