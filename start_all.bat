@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
chcp 65001 >nul

set "ROOT=%cd%"
set "AI_MERGED_DIR=%ROOT%\local_ai\models\qwen2.5-0.5b-merged"
set "AI_TOKENIZER_CFG=%AI_MERGED_DIR%\tokenizer_config.json"

echo ==============================================
echo Start All: Backend + AI + Flutter Windows App
echo ==============================================

where flutter >nul 2>nul
if errorlevel 1 (
  echo [ERROR] flutter not found in PATH.
  pause
  exit /b 1
)

if not exist "backend\.venv312\Scripts\python.exe" (
  echo [ERROR] backend\.venv312\Scripts\python.exe not found.
  echo Prepare backend Python environment first.
  pause
  exit /b 1
)

call :is_port_open 8000
if "!PORT_OPEN!"=="1" (
  echo [OK] Backend 8000 is already running.
) else (
  echo [RUN] Starting backend ^(8000^)...
  start "monitoring-backend" cmd /k "cd /d %cd% && call start_backend.bat"
)

call :is_port_open 8008
if "!PORT_OPEN!"=="1" (
  echo [OK] AI service 8008 is already running.
) else (
  if not exist "local_ai\.venv_train\Scripts\python.exe" (
    echo [WARN] local_ai\.venv_train missing, skip AI startup.
  ) else (
    if exist "!AI_TOKENIZER_CFG!" (
      echo [OK] Usable merged model detected.
    ) else (
      if exist "local_ai\models\qwen2.5-0.5b-lora" (
        echo [RUN] merged model unavailable, auto-merging LoRA...
        local_ai\.venv_train\Scripts\python.exe local_ai\train\merge_lora.py
        if errorlevel 1 (
          echo [WARN] LoRA merge failed, AI chat will be unavailable.
        )
      ) else (
        echo [WARN] LoRA artifact not found, AI chat will be unavailable.
      )
    )

    if exist "!AI_TOKENIZER_CFG!" (
      echo [RUN] Starting AI service ^(8008^)...
      start "monitoring-ai" cmd /k "cd /d %ROOT% && set ""LOCAL_MODEL_PATH=%AI_MERGED_DIR%"" && set ""LOCAL_MODEL_NAME=expert-local"" && set ""LOCAL_MODEL_API_KEY=local-key"" && local_ai\.venv_train\Scripts\python.exe -m uvicorn local_ai.infer.openai_compatible_server:app --host 127.0.0.1 --port 8008"
    )
  )
)

echo [WAIT] Waiting for backend...
call :wait_port 8000 20
if "!PORT_OPEN!"=="0" (
  echo [ERROR] Backend 8000 failed to start. Check "monitoring-backend" window.
  pause
  exit /b 1
)

echo [WAIT] Waiting for AI service...
call :wait_port 8008 90
if "!PORT_OPEN!"=="1" (
  echo [OK] AI service is ready ^(8008^).
) else (
  echo [WARN] AI service not ready; other app features still work.
)

echo [RUN] Starting Flutter Windows App...
start "monitoring-app" cmd /k "cd /d %cd% && flutter run -d windows --dart-define=API_BASE_URL=http://127.0.0.1:8000"

echo.
echo ==============================================
echo Startup completed:
echo - Backend: http://127.0.0.1:8000
echo - AI Upstream: http://127.0.0.1:8008 (optional)
echo - App launched in new window
echo - Stop script: stop_all.bat
echo ==============================================
echo.
endlocal
exit /b 0

:is_port_open
set PORT_OPEN=0
for /f "tokens=5" %%a in ('netstat -ano ^| findstr /R /C:":%~1 .*LISTENING"') do (
  set PORT_OPEN=1
  goto :eof
)
goto :eof

:wait_port
set PORT_OPEN=0
set /a _retries=%~2
:wait_loop
call :is_port_open %~1
if "!PORT_OPEN!"=="1" goto :eof
set /a _retries-=1
if !_retries! LEQ 0 goto :eof
timeout /t 1 /nobreak >nul
goto :wait_loop
