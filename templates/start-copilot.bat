@echo off
rem start-copilot.bat - jalankan copilot2api-go (hidden, log ke copilot-go.log)
rem Path absolut ke direktori repo - sesuaikan kalau clone di tempat lain
cd /d %~dp0
set "PATH=C:\Users\TUF Gaming A15\AppData\Local\hermes\node;C:\Program Files\nodejs;%PATH%"
copilot-go.exe --web-port 3000 --proxy-port 4141 >> copilot-go.log 2>&1