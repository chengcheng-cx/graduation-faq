
@echo off
chcp 65001 >nul
setlocal
title Graduation FAQ - GitHub Update

:: Switch to the directory containing this script
cd /d "%~dp0"

echo =====================================
echo   Graduation FAQ - Website Update
echo =====================================
echo.

:: Check Git
git --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git is not installed or not in PATH.
    goto :failed
)

:: Check repository
git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git repository not found.
    goto :failed
)

:: Stage changes
git add -A
if errorlevel 1 goto :failed

:: Check for changes
git diff --cached --quiet
if not errorlevel 1 (
    echo [INFO] No changes detected.
    goto :finish
)

:: Create commit
git commit -m "Update graduation FAQ"
if errorlevel 1 goto :failed

:: Push to GitHub
echo.
echo [INFO] Uploading to GitHub...
git push origin main
if errorlevel 1 goto :failed

echo.
echo [SUCCESS] GitHub updated successfully!
echo GitHub Pages will deploy automatically.
goto :finish

:failed
echo.
echo [ERROR] Update failed. Check the messages above.

:finish
echo.
pause
endlocal
