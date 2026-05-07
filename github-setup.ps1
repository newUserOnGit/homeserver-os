# GitHub Setup Script (PowerShell)
# Первоначальная настройка GitHub для проекта

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "GitHub Setup - Home Server OS" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Check if git is installed
Write-Host "Проверка установки Git..." -ForegroundColor Yellow
$gitInstalled = Get-Command git -ErrorAction SilentlyContinue

if (-not $gitInstalled) {
    Write-Host "✗ Git не установлен!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Установите Git:"
    Write-Host "  Windows: winget install Git.Git"
    Write-Host "  Или скачайте с https://git-scm.com/download/win"
    Write-Host ""
    exit 1
}

Write-Host "✓ Git установлен" -ForegroundColor Green
Write-Host ""

# Check if GitHub CLI is installed
Write-Host "Проверка GitHub CLI..." -ForegroundColor Yellow
$ghInstalled = Get-Command gh -ErrorAction SilentlyContinue

if (-not $ghInstalled) {
    Write-Host "⚠ GitHub CLI не установлен (опционально)" -ForegroundColor Yellow
    Write-Host "  Для установки: winget install GitHub.cli" -ForegroundColor Gray
    Write-Host ""
    $useGH = $false
} else {
    Write-Host "✓ GitHub CLI установлен" -ForegroundColor Green
    $useGH = $true
    Write-Host ""
}

# Configure Git user
Write-Host "Настройка Git пользователя:" -ForegroundColor Blue
Write-Host ""

$currentName = git config --global user.name
$currentEmail = git config --global user.email

if ($currentName) {
    Write-Host "Текущее имя: $currentName" -ForegroundColor Gray
    $name = Read-Host "Введите ваше имя (или Enter для использования текущего)"
    if ([string]::IsNullOrWhiteSpace($name)) {
        $name = $currentName
    }
} else {
    $name = Read-Host "Введите ваше имя"
}

if ($currentEmail) {
    Write-Host "Текущий email: $currentEmail" -ForegroundColor Gray
    $email = Read-Host "Введите ваш email (или Enter для использования текущего)"
    if ([string]::IsNullOrWhiteSpace($email)) {
        $email = $currentEmail
    }
} else {
    $email = Read-Host "Введите ваш email"
}

git config --global user.name "$name"
git config --global user.email "$email"

Write-Host "✓ Git пользователь настроен" -ForegroundColor Green
Write-Host ""

# Initialize repository
Write-Host "Инициализация репозитория..." -ForegroundColor Yellow

if (Test-Path ".git") {
    Write-Host "⚠ Git уже инициализирован" -ForegroundColor Yellow
} else {
    git init
    Write-Host "✓ Git репозиторий инициализирован" -ForegroundColor Green
}
Write-Host ""

# Choose authentication method
Write-Host "Выберите метод аутентификации:" -ForegroundColor Blue
Write-Host "  1. GitHub CLI (gh auth login) - Рекомендуется"
Write-Host "  2. SSH ключ"
Write-Host "  3. HTTPS (потребуется токен)"
Write-Host ""

$authChoice = Read-Host "Выберите метод (1-3)"

switch ($authChoice) {
    "1" {
        if ($useGH) {
            Write-Host ""
            Write-Host "Запуск GitHub CLI аутентификации..." -ForegroundColor Yellow
            gh auth login

            if ($LASTEXITCODE -eq 0) {
                Write-Host "✓ Аутентификация успешна" -ForegroundColor Green
            } else {
                Write-Host "✗ Ошибка аутентификации" -ForegroundColor Red
                exit 1
            }
        } else {
            Write-Host "✗ GitHub CLI не установлен" -ForegroundColor Red
            Write-Host "Установите: winget install GitHub.cli" -ForegroundColor Yellow
            exit 1
        }
    }
    "2" {
        Write-Host ""
        Write-Host "Настройка SSH ключа:" -ForegroundColor Yellow
        Write-Host ""

        $sshPath = "$env:USERPROFILE\.ssh\id_ed25519"

        if (Test-Path $sshPath) {
            Write-Host "✓ SSH ключ уже существует: $sshPath" -ForegroundColor Green
        } else {
            Write-Host "Генерация SSH ключа..." -ForegroundColor Yellow
            ssh-keygen -t ed25519 -C "$email" -f $sshPath
            Write-Host "✓ SSH ключ создан" -ForegroundColor Green
        }

        Write-Host ""
        Write-Host "Публичный ключ:" -ForegroundColor Blue
        Get-Content "$sshPath.pub"
        Write-Host ""
        Write-Host "Скопируйте ключ выше и добавьте на GitHub:" -ForegroundColor Yellow
        Write-Host "  https://github.com/settings/ssh/new" -ForegroundColor Cyan
        Write-Host ""
        Read-Host "Нажмите Enter после добавления ключа на GitHub"
    }
    "3" {
        Write-Host ""
        Write-Host "Для HTTPS аутентификации вам понадобится Personal Access Token" -ForegroundColor Yellow
        Write-Host "Создайте токен здесь:" -ForegroundColor Yellow
        Write-Host "  https://github.com/settings/tokens/new" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Права для токена:" -ForegroundColor Yellow
        Write-Host "  ✓ repo (полный доступ к репозиториям)" -ForegroundColor Gray
        Write-Host ""
        Read-Host "Нажмите Enter после создания токена"
    }
}

Write-Host ""

# Create repository
Write-Host "Создание репозитория на GitHub:" -ForegroundColor Blue
Write-Host ""

$repoName = Read-Host "Введите название репозитория (по умолчанию: homeserver-os)"
if ([string]::IsNullOrWhiteSpace($repoName)) {
    $repoName = "homeserver-os"
}

$repoDesc = "Home Server OS - Operating system for home servers"
$repoPublic = Read-Host "Публичный репозиторий? (y/n, по умолчанию: y)"

if ([string]::IsNullOrWhiteSpace($repoPublic) -or $repoPublic -eq "y") {
    $visibility = "--public"
} else {
    $visibility = "--private"
}

Write-Host ""

if ($useGH -and $authChoice -eq "1") {
    Write-Host "Создание репозитория через GitHub CLI..." -ForegroundColor Yellow
    gh repo create $repoName $visibility --description "$repoDesc" --source=. --remote=origin

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Репозиторий создан" -ForegroundColor Green
    } else {
        Write-Host "✗ Ошибка при создании репозитория" -ForegroundColor Red
        Write-Host "Создайте репозиторий вручную на https://github.com/new" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "Создайте репозиторий вручную:" -ForegroundColor Yellow
    Write-Host "  1. Перейдите на https://github.com/new" -ForegroundColor Cyan
    Write-Host "  2. Название: $repoName" -ForegroundColor Gray
    Write-Host "  3. Описание: $repoDesc" -ForegroundColor Gray
    Write-Host "  4. НЕ инициализируйте с README" -ForegroundColor Red
    Write-Host ""

    $username = Read-Host "Введите ваш GitHub username"

    if ($authChoice -eq "2") {
        $repoUrl = "git@github.com:$username/$repoName.git"
    } else {
        $repoUrl = "https://github.com/$username/$repoName.git"
    }

    Write-Host ""
    Write-Host "Добавление remote..." -ForegroundColor Yellow

    $existingRemote = git remote get-url origin 2>$null
    if ($existingRemote) {
        git remote set-url origin $repoUrl
    } else {
        git remote add origin $repoUrl
    }

    Write-Host "✓ Remote добавлен: $repoUrl" -ForegroundColor Green
}

Write-Host ""

# Initial commit and push
Write-Host "Создание первого коммита..." -ForegroundColor Yellow

git add .
git commit -m "feat: initial commit - Home Server OS v0.1.0

- Complete kernel implementation
- Web interface and REST API
- Virtualization support (containers and VMs)
- Security features (firewall, authentication)
- Monitoring and backup systems
- Full documentation"

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Ошибка при создании коммита" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Коммит создан" -ForegroundColor Green
Write-Host ""

Write-Host "Отправка на GitHub..." -ForegroundColor Yellow
git branch -M main
git push -u origin main

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Ошибка при отправке на GitHub" -ForegroundColor Red
    Write-Host ""
    Write-Host "Попробуйте отправить вручную:" -ForegroundColor Yellow
    Write-Host "  git push -u origin main" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Green
Write-Host "✓ Настройка завершена!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""

$remoteUrl = git remote get-url origin
Write-Host "Ваш репозиторий:" -ForegroundColor Blue
Write-Host "  $remoteUrl" -ForegroundColor Cyan
Write-Host ""

Write-Host "Для последующих обновлений используйте:" -ForegroundColor Yellow
Write-Host "  .\git-push.ps1" -ForegroundColor Cyan
Write-Host ""

Write-Host "Или вручную:" -ForegroundColor Yellow
Write-Host "  git add ." -ForegroundColor Gray
Write-Host "  git commit -m 'your message'" -ForegroundColor Gray
Write-Host "  git push" -ForegroundColor Gray
Write-Host ""
