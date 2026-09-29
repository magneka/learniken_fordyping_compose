@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

for /f "usebackq tokens=1,2 delims==" %%A in (".env") do (
    if not "%%A"=="" if not "%%A:~0,1%%"=="#" set "%%A=%%B"
)

docker compose exec -T db /opt/mssql-tools18/bin/sqlcmd ^
    -C -S localhost -U sa -P "%DB_PASSWORD%" -d "%DB_DATABASE%" ^
    -Q "SELECT * FROM customer;"
