#!/bin/bash
# Git Setup and Push Script for Custom Server OS
# Автоматическая настройка Git и отправка на GitHub

set -e

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                                                                  ║"
echo "║         Custom Server OS - Git Setup & Push                      ║"
echo "║                                                                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# Переход в директорию проекта
cd "$(dirname "$0")"
PROJECT_DIR=$(pwd)

echo "📁 Директория проекта: $PROJECT_DIR"
echo ""

# Проверка наличия Git
if ! command -v git &> /dev/null; then
    echo "❌ Git не установлен!"
    echo "Установите Git: https://git-scm.com/downloads"
    exit 1
fi

echo "✅ Git установлен: $(git --version)"
echo ""

# Инициализация Git репозитория (если еще не инициализирован)
if [ ! -d ".git" ]; then
    echo "🔧 Инициализация Git репозитория..."
    git init
    echo "✅ Git репозиторий инициализирован"
else
    echo "✅ Git репозиторий уже существует"
fi
echo ""

# Создание .gitignore если его нет
if [ ! -f ".gitignore" ]; then
    echo "📝 Создание .gitignore..."
    cat > .gitignore << 'EOF'
# Build artifacts
build/kernel-output/
build/rootfs/
build/iso/
*.iso
*.bin
*.o
*.ko

# Compiled files
*.out
*.exe
*.dll
*.so
*.dylib

# Temporary files
*.tmp
*.swp
*.swo
*~
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.sublime-*

# Logs
*.log

# Don't ignore build scripts
!build/scripts/
EOF
    echo "✅ .gitignore создан"
else
    echo "✅ .gitignore уже существует"
fi
echo ""

# Настройка Git пользователя (если не настроено)
if [ -z "$(git config user.name)" ]; then
    echo "⚙️ Настройка Git пользователя..."
    read -p "Введите ваше имя: " git_name
    read -p "Введите ваш email: " git_email
    git config user.name "$git_name"
    git config user.email "$git_email"
    echo "✅ Git пользователь настроен"
else
    echo "✅ Git пользователь: $(git config user.name) <$(git config user.email)>"
fi
echo ""

# Проверка удаленного репозитория
if git remote | grep -q "origin"; then
    echo "✅ Удаленный репозиторий уже настроен:"
    git remote -v
else
    echo "⚙️ Настройка удаленного репозитория..."
    echo ""
    echo "Создайте новый репозиторий на GitHub:"
    echo "  1. Перейдите на https://github.com/new"
    echo "  2. Название: custom-server-os"
    echo "  3. Описание: Custom Server OS - Linux Edition"
    echo "  4. Выберите Public или Private"
    echo "  5. НЕ создавайте README, .gitignore или LICENSE"
    echo "  6. Нажмите 'Create repository'"
    echo ""
    read -p "Введите URL репозитория (например: https://github.com/username/custom-server-os.git): " repo_url
    git remote add origin "$repo_url"
    echo "✅ Удаленный репозиторий добавлен"
fi
echo ""

# Добавление файлов
echo "📦 Добавление файлов в Git..."
git add .
echo "✅ Файлы добавлены"
echo ""

# Проверка статуса
echo "📊 Статус репозитория:"
git status --short | head -20
echo ""

# Создание коммита
echo "💾 Создание коммита..."
COMMIT_MSG="feat: integrate Linux kernel 6.12.28

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

git commit -m "$COMMIT_MSG"
echo "✅ Коммит создан"
echo ""

# Отправка на GitHub
echo "🚀 Отправка на GitHub..."
echo ""
echo "Выберите действие:"
echo "  1) Отправить в новую ветку 'main'"
echo "  2) Отправить в существующую ветку"
echo "  3) Отменить (не отправлять)"
echo ""
read -p "Ваш выбор (1-3): " choice

case $choice in
    1)
        echo "📤 Отправка в ветку 'main'..."
        git branch -M main
        git push -u origin main
        echo "✅ Изменения отправлены!"
        ;;
    2)
        read -p "Введите название ветки: " branch_name
        echo "📤 Отправка в ветку '$branch_name'..."
        git checkout -b "$branch_name" 2>/dev/null || git checkout "$branch_name"
        git push -u origin "$branch_name"
        echo "✅ Изменения отправлены!"
        ;;
    3)
        echo "❌ Отправка отменена"
        echo "Для отправки позже выполните: git push -u origin main"
        exit 0
        ;;
    *)
        echo "❌ Неверный выбор"
        exit 1
        ;;
esac

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                                                                  ║"
echo "║                    ✅ ГОТОВО!                                    ║"
echo "║                                                                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "🎉 Проект успешно отправлен на GitHub!"
echo ""
echo "📍 Ваш репозиторий:"
git remote get-url origin
echo ""
echo "🔗 Откройте в браузере:"
REPO_URL=$(git remote get-url origin)
REPO_URL=${REPO_URL%.git}
REPO_URL=${REPO_URL/git@github.com:/https://github.com/}
echo "$REPO_URL"
echo ""
