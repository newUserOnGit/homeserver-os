# Git Push Helper Script (PowerShell)
# Автоматизирует процесс коммита и пуша

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Git Push Helper" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Check if git is initialized
if (-not (Test-Path ".git")) {
    Write-Host "Git не инициализирован. Инициализирую..." -ForegroundColor Yellow
    git init
    Write-Host "✓ Git инициализирован" -ForegroundColor Green
    Write-Host ""
}

# Check if remote exists
$remotes = git remote
if ($remotes -notcontains "origin") {
    Write-Host "Remote 'origin' не настроен" -ForegroundColor Yellow
    $repoUrl = Read-Host "Введите URL вашего GitHub репозитория"
    git remote add origin $repoUrl
    Write-Host "✓ Remote добавлен" -ForegroundColor Green
    Write-Host ""
}

# Show status
Write-Host "Текущий статус:" -ForegroundColor Blue
git status --short
Write-Host ""

# Ask for commit message
$commitMsg = Read-Host "Введите сообщение коммита (или Enter для автоматического)"

if ([string]::IsNullOrWhiteSpace($commitMsg)) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $commitMsg = "chore: update project files - $timestamp"
}

# Add all files
Write-Host "Добавляю файлы..." -ForegroundColor Yellow
git add .

# Commit
Write-Host "Создаю коммит..." -ForegroundColor Yellow
git commit -m $commitMsg

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Ошибка при создании коммита" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Коммит создан" -ForegroundColor Green
Write-Host ""

# Push
Write-Host "Отправляю на GitHub..." -ForegroundColor Yellow
git push -u origin main

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Ошибка при отправке на GitHub" -ForegroundColor Red
    Write-Host ""
    Write-Host "Возможные причины:"
    Write-Host "  1. Не настроена аутентификация (используйте 'gh auth login' или SSH ключ)"
    Write-Host "  2. Неверный URL репозитория"
    Write-Host "  3. Нет прав доступа к репозиторию"
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "✓ Успешно отправлено на GitHub!" -ForegroundColor Green
Write-Host ""
