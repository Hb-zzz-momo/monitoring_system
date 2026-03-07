@echo off
setlocal
cd /d "%~dp0"
chcp 65001 >nul

set "PYTHONUTF8=1"
set "PYTHONIOENCODING=utf-8"

set "ROOT=%cd%"
set "TRAIN_PY=%ROOT%\local_ai\.venv_train\Scripts\python.exe"
set "LORA_DIR=%ROOT%\local_ai\models\qwen2.5-0.5b-lora"
set "MERGED_DIR=%ROOT%\local_ai\models\qwen2.5-0.5b-merged-runtime"

if not exist "%TRAIN_PY%" (
  echo [ERROR] 未找到 local_ai\.venv_train，请先执行训练脚本。
  pause
  exit /b 1
)

if not exist "%LORA_DIR%" (
  echo [ERROR] 未找到 LoRA 训练产物 local_ai\models\qwen2.5-0.5b-lora
  echo 请先运行 .\train_local_model.bat
  pause
  exit /b 1
)

echo [0/3] 检查并停止旧的模型服务...
taskkill /F /FI "WINDOWTITLE eq trained-model-api*" >nul 2>nul
for /f "tokens=5" %%a in ('netstat -ano ^| findstr /R /C:":8008 .*LISTENING"') do (
  taskkill /F /PID %%a >nul 2>nul
)

if exist "%MERGED_DIR%" (
  rmdir /s /q "%MERGED_DIR%" >nul 2>nul
)

echo [1/3] 合并 LoRA 到完整模型...
"%TRAIN_PY%" local_ai\train\merge_lora.py --output-dir "%MERGED_DIR%"
if errorlevel 1 (
  echo [ERROR] LoRA 合并失败。
  pause
  exit /b 1
)

if not exist "%MERGED_DIR%\tokenizer_config.json" (
  echo [ERROR] 未检测到合并后模型目录: %MERGED_DIR%
  pause
  exit /b 1
)

echo [2/3] 启动训练后推理服务 (http://127.0.0.1:8008/v1)...
set LOCAL_MODEL_PATH=%MERGED_DIR%
set LOCAL_MODEL_NAME=expert-local
set LOCAL_MODEL_API_KEY=local-key
start "trained-model-api" cmd /c "cd /d %ROOT% && set PYTHONUTF8=1 && set PYTHONIOENCODING=utf-8 && \"%TRAIN_PY%\" -m uvicorn local_ai.infer.openai_compatible_server:app --host 0.0.0.0 --port 8008"

echo [3/3] 完成。若你使用 LiteLLM 网关，请重启它以加载 expert-local 路由：
echo     docker compose -f local_ai\docker-compose.yml restart litellm
echo.
echo 前端配置建议：
echo Base URL = http://127.0.0.1:4000/v1
echo API Key  = local-key
echo Model    = expert-local

endlocal
exit /b 0
