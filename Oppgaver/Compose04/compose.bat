@echo off
REM Docker Compose helper script for learniken_compose04
REM Loads configuration from .env file

REM Load .env file into environment
for /f "eol=# delims== tokens=1,*" %%G in (.env) do set "%%G=%%H"

if "%1%"=="" (
    echo Usage: compose.bat [up^|down^|delete]
    echo.
    echo Commands:
    echo   up      - Start the PostgreSQL database
    echo   down    - Stop the PostgreSQL database
    echo   delete  - Stop and remove containers, networks, and volumes
    exit /b 1
)

if /i "%1%"=="up" (
    echo Starting PostgreSQL database with .env configuration...
    docker compose --env-file .env up -d
    exit /b %ERRORLEVEL%
)

if /i "%1%"=="down" (
    echo Stopping PostgreSQL database...
    docker compose --env-file .env down
    exit /b %ERRORLEVEL%
)

if /i "%1%"=="delete" (
    echo Stopping and removing PostgreSQL database with volumes...
    docker compose --env-file .env down -v
    exit /b %ERRORLEVEL%
)

echo Invalid command: %1%
echo Usage: compose.bat [up^|down^|delete]
exit /b 1
