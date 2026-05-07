#!/bin/bash
# Скрипт для очистки проекта перед отправкой на GitHub

set -e

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                                                                  ║"
echo "║              Очистка проекта для GitHub                          ║"
echo "║                                                                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

cd "$(dirname "$0")"

echo "🗑️  Удаление временных и служебных файлов..."
echo ""

# Удаление старых README и инструкций
echo "📝 Удаление старых файлов документации..."
rm -f README.old.md
rm -f FINAL_REPORT.txt
rm -f PROJECT_COMPLETE.txt
rm -f PROJECT_FINISHED.txt
rm -f GITHUB_SETUP_COMPLETE.txt
rm -f REBOOT_REQUIRED.txt
rm -f USE_BAT_FILE.txt
rm -f ИСПОЛЬЗУЙТЕ_BAT_ФАЙЛ.txt
rm -f START_HERE.txt
rm -f QUICK_START_EN.txt
rm -f QUICK_START_GITHUB.txt
rm -f SIMPLE_GITHUB_GUIDE.md
rm -f GITHUB_GUIDE.md
rm -f GITHUB_README.md
rm -f WSL_INSTALLATION_STATUS.md

# Удаление Git-скриптов (они уже не нужны)
echo "🔧 Удаление Git-скриптов..."
rm -f git-push.sh
rm -f git-push.bat
rm -f git-push.ps1
rm -f github-setup.ps1
rm -f simple-git-push.ps1
rm -f git-setup-and-push.sh
rm -f git-setup-and-push.bat
rm -f update-repo.sh
rm -f resolve-conflicts.sh

# Удаление временных инструкций
echo "📋 Удаление временных инструкций..."
rm -f PUSH_TO_GITHUB.txt
rm -f UPDATE_EXISTING_REPO.txt
rm -f RESOLVE_CONFLICTS.txt
rm -f GIT_PUSH_GUIDE.md
rm -f GITHUB_PUSH_SUCCESS.txt
rm -f FINAL_STATUS.txt
rm -f ISOLATION_OPTIONS.md
rm -f PROJECT_STRUCTURE.md

# Удаление служебных скриптов
echo "🛠️  Удаление служебных скриптов..."
rm -f quickstart.sh
rm -f status.sh

echo ""
echo "✅ Файлы удалены!"
echo ""

# Обновление .gitignore
echo "📝 Обновление .gitignore..."
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

# Linux kernel source (1.6GB)
linux-kernel/

# Git scripts (not needed in repo)
git-*.sh
git-*.bat
git-*.ps1
*-git-*.sh
*-git-*.bat

# Temporary docs
*_OLD.*
*_TEMP.*
TEMP_*

# Don't ignore build scripts
!build/scripts/
EOF

echo "✅ .gitignore обновлен"
echo ""

# Показать оставшиеся файлы
echo "📊 Оставшиеся файлы документации:"
ls -1 *.md *.txt 2>/dev/null | grep -v "README.md" || echo "  (только README.md)"
echo ""

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                                                                  ║"
echo "║                    ✅ ОЧИСТКА ЗАВЕРШЕНА!                         ║"
echo "║                                                                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "Проект готов к отправке на GitHub!"
echo ""
