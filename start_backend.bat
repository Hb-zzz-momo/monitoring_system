@echo off
setlocal
cd /d "%~dp0"

if not exist "backend\.venv312\Scripts\python.exe" (
  echo [ERROR] Python 3.12 venv not found: backend\.venv312
  echo Please run setup first.
  pause
  exit /b 1
)

echo Starting FastAPI backend on http://127.0.0.1:8000
echo Docs: http://127.0.0.1:8000/docs
echo.

"backend\.venv312\Scripts\python.exe" -m uvicorn main:app --reload --app-dir "backend" --host 127.0.0.1 --port 8000

endlocal
