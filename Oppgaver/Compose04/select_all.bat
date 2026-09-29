@echo off
REM SQL SELECT script for Windows - Reads from .env file
for /f "eol=# delims== tokens=1,*" %%G in (.env) do set "%%G=%%H"

echo Running: SELECT * FROM %DB_TABLE_NAME%
echo Database: %DB_DATABASE%
echo User: %DB_USERNAME%
echo.

REM Run psql inside the postgres container (host "postgres" only resolves inside the Docker network)
docker compose --env-file .env exec -T postgres psql -U %DB_USERNAME% -d %DB_DATABASE% -c "SELECT * FROM %DB_TABLE_NAME%;"

if errorlevel 1 (
    echo Error: Query failed. Is the postgres container running?
    exit /b 1
)
