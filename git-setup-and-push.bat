@echo off
REM Git Setup and Push Script for Custom Server OS (Windows)
REM Автоматическая настройка Git и отправка на GitHub

echo ================================================================
echo.
echo         Custom Server OS - Git Setup ^& Push
echo.
echo ================================================================
echo.

cd /d "%~dp0"

REM Проверка наличия Git
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Git не установлен!
    echo Установите Git: https://git-scm.com/downloads
    pause
    exit /b 1
)

echo [OK] Git установлен
git --version
echo.

REM Инициализация Git репозитория
if not exist ".git" (
    echo [INFO] Инициализация Git репозитория...
    git init
    echo [OK] Git репозиторий инициализирован
) else (
    echo [OK] Git репозиторий уже существует
)
echo.

REM Создание .gitignore
if not exist ".gitignore" (
    echo [INFO] Создание .gitignore...
    (
        echo # Build artifacts
        echo build/kernel-output/
        echo build/rootfs/
        echo build/iso/
        echo *.iso
        echo *.bin
        echo *.o
        echo *.ko
        echo.
        echo # Compiled files
        echo *.out
        echo *.exe
        echo *.dll
        echo *.so
        echo.
        echo # Temporary files
        echo *.tmp
        echo *.swp
        echo *~
        echo .DS_Store
        echo Thumbs.db
        echo.
        echo # IDE
        echo .vscode/
        echo .idea/
        echo.
        echo # Logs
        echo *.log
        echo.
        echo # Don't ignore build scripts
        echo !build/scripts/
    ) > .gitignore
    echo [OK] .gitignore создан
) else (
    echo [OK] .gitignore уже существует
)
echo.

REM Проверка настройки пользователя
git config user.name >nul 2>nul
if %errorlevel% neq 0 (
    echo [INFO] Настройка Git пользователя...
    set /p git_name="Введите ваше имя: "
    set /p git_email="Введите ваш email: "
    git config user.name "%git_name%"
    git config user.email "%git_email%"
    echo [OK] Git пользователь настроен
) else (
    echo [OK] Git пользователь настроен
)
echo.

REM Проверка удаленного репозитория
git remote | findstr "origin" >nul 2>nul
if %errorlevel% neq 0 (
    echo [INFO] Настройка удаленного репозитория...
    echo.
    echo Создайте новый репозиторий на GitHub:
    echo   1. Перейдите на https://github.com/new
    echo   2. Название: custom-server-os
    echo   3. Описание: Custom Server OS - Linux Edition
    echo   4. Выберите Public или Private
    echo   5. НЕ создавайте README, .gitignore или LICENSE
    echo   6. Нажмите 'Create repository'
    echo.
    set /p repo_url="Введите URL репозитория: "
    git remote add origin "%repo_url%"
    echo [OK] Удаленный репозиторий добавлен
) else (
    echo [OK] Удаленный репозиторий уже настроен
    git remote -v
)
echo.

REM Добавление файлов
echo [INFO] Добавление файлов в Git...
git add .
echo [OK] Файлы добавлены
echo.

REM Статус
echo [INFO] Статус репозитория:
git status --short
echo.

REM Создание коммита
echo [INFO] Создание коммита...
git commit -m "feat: integrate Linux kernel 6.12.28" -m "- Added Linux kernel 6.12.28 from C:/core" -m "- Created optimized kernel configuration" -m "- Set up build system (Makefile + scripts)" -m "- Added comprehensive documentation" -m "- Version: 0.2.0"
echo [OK] Коммит создан
echo.

REM Отправка на GitHub
echo [INFO] Отправка на GitHub...
echo.
echo Выберите действие:
echo   1) Отправить в новую ветку 'main'
echo   2) Отправить в существующую ветку
echo   3) Отменить (не отправлять)
echo.
set /p choice="Ваш выбор (1-3): "

if "%choice%"=="1" (
    echo [INFO] Отправка в ветку 'main'...
    git branch -M main
    git push -u origin main
    echo [OK] Изменения отправлены!
) else if "%choice%"=="2" (
    set /p branch_name="Введите название ветки: "
    echo [INFO] Отправка в ветку '%branch_name%'...
    git checkout -b "%branch_name%" 2>nul || git checkout "%branch_name%"
    git push -u origin "%branch_name%"
    echo [OK] Изменения отправлены!
) else if "%choice%"=="3" (
    echo [INFO] Отправка отменена
    echo Для отправки позже выполните: git push -u origin main
    pause
    exit /b 0
) else (
    echo [ERROR] Неверный выбор
    pause
    exit /b 1
)

echo.
echo ================================================================
echo.
echo                    [OK] ГОТОВО!
echo.
echo ================================================================
echo.
echo Проект успешно отправлен на GitHub!
echo.
pause
