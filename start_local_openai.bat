@echo off
setlocal
cd /d "%~dp0"

where docker >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Docker 未安装或未加入 PATH。
  echo 请先安装 Docker Desktop。
  pause
  exit /b 1
)

echo [1/3] 启动本地 LLM 服务 (Ollama + LiteLLM)...
docker compose -f local_ai\docker-compose.yml up -d
if errorlevel 1 (
  echo [ERROR] Docker Compose 启动失败。
  pause
  exit /b 1
)

echo [2/3] 拉取模型 qwen2.5:7b（首次会较慢）...
docker exec monitoring_ollama ollama pull qwen2.5:7b
if errorlevel 1 (
  echo [ERROR] 模型拉取失败，请检查网络后重试。
  pause
  exit /b 1
)

echo [3/3] 完成。
echo OpenAI 兼容地址: http://127.0.0.1:4000/v1
echo API Key: local-key
echo Model: gpt-4o-mini
echo.
echo 你可以在 AI 配置里填：
echo   Base URL = http://127.0.0.1:4000/v1
echo   API Key  = local-key
echo   Model    = gpt-4o-mini

endlocal
