@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0"

for /f "usebackq tokens=1,* delims==" %%A in (".env") do (
    set "%%A=%%B"
)

docker exec -i learniken_compose03_mysql mysql -u"%MYSQL_USER%" -p"%MYSQL_PASSWORD%" "%MYSQL_DATABASE%" -e "SELECT * FROM customer;"
