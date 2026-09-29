@echo off
setlocal

set "HOST=%~1"
if "%HOST%"=="" set "HOST=http://localhost:8085"

echo Testing %HOST%/weatherforecast
curl -sS -w "\nHTTP %%{http_code} in %%{time_total}s\n" "%HOST%/weatherforecast"
