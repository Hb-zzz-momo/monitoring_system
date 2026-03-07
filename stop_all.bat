@echo off
setlocal
cd /d "%~dp0"
chcp 65001 >nul

echo ==============================================
echo Stop All: Backend + AI + Flutter App
echo ==============================================

for %%T in ("monitoring-backend" "monitoring-ai" "monitoring-ai-setup" "monitoring-app") do (
  taskkill /F /FI "WINDOWTITLE eq %%~T*" >nul 2>nul
)

for %%P in (8000 8008) do (
  for /f "tokens=5" %%a in ('netstat -ano ^| findstr /R /C:":%%P .*LISTENING"') do (
    taskkill /F /PID %%a >nul 2>nul
  )
)

echo [OK] Stop command executed.
echo If any terminal remains, close it manually.
echo ==============================================

endlocal
exit /b 0
