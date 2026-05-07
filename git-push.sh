#!/bin/bash
# Git Push Helper Script
# Автоматизирует процесс коммита и пуша

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=================================="
echo "Git Push Helper"
echo "=================================="
echo ""

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}Git не инициализирован. Инициализирую...${NC}"
    git init
    echo -e "${GREEN}✓ Git инициализирован${NC}"
    echo ""
fi

# Check if remote exists
if ! git remote | grep -q "origin"; then
    echo -e "${YELLOW}Remote 'origin' не настроен${NC}"
    read -p "Введите URL вашего GitHub репозитория: " REPO_URL
    git remote add origin "$REPO_URL"
    echo -e "${GREEN}✓ Remote добавлен${NC}"
    echo ""
fi

# Show status
echo -e "${BLUE}Текущий статус:${NC}"
git status --short
echo ""

# Ask for commit message
read -p "Введите сообщение коммита (или Enter для автоматического): " COMMIT_MSG

if [ -z "$COMMIT_MSG" ]; then
    # Generate automatic commit message
    COMMIT_MSG="chore: update project files - $(date '+%Y-%m-%d %H:%M:%S')"
fi

# Add all files
echo -e "${YELLOW}Добавляю файлы...${NC}"
git add .

# Commit
echo -e "${YELLOW}Создаю коммит...${NC}"
git commit -m "$COMMIT_MSG"

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Ошибка при создании коммита${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Коммит создан${NC}"
echo ""

# Push
echo -e "${YELLOW}Отправляю на GitHub...${NC}"
git push -u origin main

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Ошибка при отправке на GitHub${NC}"
    echo ""
    echo "Возможные причины:"
    echo "  1. Не настроена аутентификация (используйте 'gh auth login' или SSH ключ)"
    echo "  2. Неверный URL репозитория"
    echo "  3. Нет прав доступа к репозиторию"
    echo ""
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Успешно отправлено на GitHub!${NC}"
echo ""
