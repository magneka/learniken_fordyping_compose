@echo off
setlocal

cd /d "%~dp0"

if "%~1"=="up" (
    docker compose up -d
) else if "%~1"=="down" (
    docker compose down -v --rmi local
) else (
    echo Usage: %~nx0 {up^|down}
    exit /b 1
)
