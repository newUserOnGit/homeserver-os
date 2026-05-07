#!/bin/bash
# Скрипт для обновления существующего репозитория
# Репозиторий: https://github.com/newUserOnGit/homeserver-os.git

set -e

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                                                                  ║"
echo "║     Обновление репозитория homeserver-os                         ║"
echo "║                                                                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# Переход в директорию проекта
cd "$(dirname "$0")"
PROJECT_DIR=$(pwd)

echo "📁 Директория: $PROJECT_DIR"
echo "🔗 Репозиторий: https://github.com/newUserOnGit/homeserver-os.git"
echo ""

# Инициализация Git (если нужно)
if [ ! -d ".git" ]; then
    echo "🔧 Инициализация Git..."
    git init
    echo "✅ Git инициализирован"
else
    echo "✅ Git уже инициализирован"
fi
echo ""

# Добавление удаленного репозитория
if ! git remote | grep -q "origin"; then
    echo "🔧 Добавление удаленного репозитория..."
    git remote add origin https://github.com/newUserOnGit/homeserver-os.git
    echo "✅ Удаленный репозиторий добавлен"
else
    echo "✅ Удаленный репозиторий уже настроен"
    git remote set-url origin https://github.com/newUserOnGit/homeserver-os.git
fi
echo ""

# Создание .gitignore
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

# Temporary files
*.tmp
*.swp
*~
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/

# Logs
*.log

# Exclude Linux kernel source (too large for GitHub)
linux-kernel/

# Don't ignore build scripts
!build/scripts/
EOF
echo "✅ .gitignore создан (ядро Linux исключено)"
echo ""

# Добавление файлов
echo "📦 Добавление файлов..."
git add .
echo "✅ Файлы добавлены"
echo ""

# Создание коммита
echo "💾 Создание коммита..."
git commit -m "feat: integrate Linux kernel 6.12.28

Major update: Integration of Linux kernel 6.12.28

Changes:
- Integrated Linux kernel 6.12.28 (source excluded from repo)
- Created optimized kernel configuration
- Set up automated build system
- Added comprehensive documentation
- Configured virtualization and container support

Version: 0.2.0
Status: Ready for build

Note: Linux kernel source (1.6GB) excluded from repository.
Download from: https://kernel.org/ (version 6.12.28)

Co-Authored-By: Claude Sonnet 4 (1M context) <noreply@anthropic.com>"
echo "✅ Коммит создан"
echo ""

# Получение изменений из репозитория
echo "📥 Получение изменений из GitHub..."
git fetch origin main || true
echo ""

# Выбор стратегии обновления
echo "Выберите стратегию обновления:"
echo "  1) Создать новую ветку 'linux-integration' (Рекомендуется)"
echo "  2) Обновить ветку 'main' напрямую"
echo "  3) Отменить"
echo ""
read -p "Ваш выбор (1-3): " choice

case $choice in
    1)
        echo ""
        echo "📤 Создание ветки 'linux-integration'..."
        git checkout -b linux-integration 2>/dev/null || git checkout linux-integration
        git push -u origin linux-integration
        echo ""
        echo "✅ Ветка 'linux-integration' создана и отправлена!"
        echo ""
        echo "🔗 Создайте Pull Request:"
        echo "   https://github.com/newUserOnGit/homeserver-os/compare/main...linux-integration"
        ;;
    2)
        echo ""
        echo "📤 Обновление ветки 'main'..."
        git checkout main 2>/dev/null || git checkout -b main
        git pull origin main --allow-unrelated-histories --no-rebase || true
        git push origin main
        echo ""
        echo "✅ Ветка 'main' обновлена!"
        ;;
    3)
        echo ""
        echo "❌ Отменено"
        exit 0
        ;;
    *)
        echo ""
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
echo "🎉 Репозиторий обновлен!"
echo ""
echo "🔗 Ваш репозиторий:"
echo "   https://github.com/newUserOnGit/homeserver-os"
echo ""
