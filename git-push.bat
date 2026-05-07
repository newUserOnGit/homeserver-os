@echo off
chcp 65001 >nul
echo ==================================
echo Simple Git Push
echo ==================================
echo.

REM Check if git is installed
where git >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Git is not installed!
    echo.
    echo Install Git from: https://git-scm.com/download/win
    echo.
    pause
    exit /b 1
)

echo [OK] Git is installed
echo.

REM Check if git is initialized
if not exist ".git" (
    echo Git not initialized. Initializing...
    git init
    echo [OK] Git initialized
    echo.

    echo Setting up remote repository:
    echo.
    echo First, create a repository on GitHub:
    echo   1. Go to https://github.com/new
    echo   2. Repository name: homeserver-os
    echo   3. DO NOT initialize with README
    echo   4. Click 'Create repository'
    echo.

    set /p username="Enter your GitHub username: "
    set /p reponame="Enter repository name (default: homeserver-os): "

    if "%reponame%"=="" set reponame=homeserver-os

    echo.
    echo Choose authentication method:
    echo   1. HTTPS (requires token)
    echo   2. SSH (if SSH key is configured)
    echo.

    set /p authmethod="Choose method (1 or 2): "

    if "%authmethod%"=="2" (
        set repourl=git@github.com:%username%/%reponame%.git
    ) else (
        set repourl=https://github.com/%username%/%reponame%.git
        echo.
        echo For HTTPS you will need a Personal Access Token:
        echo   1. Go to https://github.com/settings/tokens/new
        echo   2. Select scope: repo (full access)
        echo   3. Generate token and save it
        echo   4. On first push, Git will ask for username and token
        echo.
        pause
    )

    git remote add origin !repourl!
    echo [OK] Remote added: !repourl!
    echo.
)

REM Show status
echo Current status:
git status --short
echo.

REM Ask for commit message
set /p commitmsg="Enter commit message (or press Enter for automatic): "

if "%commitmsg%"=="" (
    for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set mydate=%%c-%%a-%%b
    for /f "tokens=1-2 delims=: " %%a in ('time /t') do set mytime=%%a:%%b
    set commitmsg=chore: update project files - !mydate! !mytime!
)

echo.
echo Adding files...
git add .

echo Creating commit...
git commit -m "%commitmsg%"

if %errorlevel% neq 0 (
    echo [ERROR] Error creating commit
    echo   (Maybe no changes to commit)
    pause
    exit /b 1
)

echo [OK] Commit created
echo.

echo Pushing to GitHub...
echo.

REM Get current branch
for /f "tokens=*" %%i in ('git branch --show-current') do set currentbranch=%%i

if "%currentbranch%"=="" (
    git branch -M main
    set currentbranch=main
)

git push -u origin %currentbranch%

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Error pushing to GitHub
    echo.
    echo Possible reasons:
    echo   1. Wrong username or token
    echo   2. Repository does not exist on GitHub
    echo   3. No access to repository
    echo.
    echo For HTTPS authentication:
    echo   Username: your GitHub username
    echo   Password: your Personal Access Token (NOT password!)
    echo.
    pause
    exit /b 1
)

echo.
echo [SUCCESS] Successfully pushed to GitHub!
echo.
pause
