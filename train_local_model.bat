@echo off
setlocal
cd /d "%~dp0"
chcp 65001 >nul

set "ROOT=%cd%"
set "BACKEND_PY=%ROOT%\backend\.venv312\Scripts\python.exe"
set "TRAIN_PY=%ROOT%\local_ai\.venv_train\Scripts\python.exe"
set "TRAIN_DATA=%ROOT%\local_ai\data\train.jsonl"
set "LORA_DIR=%ROOT%\local_ai\models\qwen2.5-0.5b-lora"

echo [1/4] 导出训练数据...
if not exist "%BACKEND_PY%" (
  echo [ERROR] 未找到 backend\.venv312，请先完成后端环境初始化。
  pause
  exit /b 1
)
"%BACKEND_PY%" backend\tools\export_sft_dataset.py
if errorlevel 1 (
  echo [ERROR] 导出训练数据失败。
  pause
  exit /b 1
)

echo [2/4] 准备训练虚拟环境...
if not exist "%TRAIN_PY%" (
  py -3.12 -m venv local_ai\.venv_train
  if errorlevel 1 (
    echo [ERROR] 创建 local_ai\.venv_train 失败，请确认已安装 Python 3.12。
    pause
    exit /b 1
  )
  set "TRAIN_PY=%ROOT%\local_ai\.venv_train\Scripts\python.exe"
)

echo [3/4] 安装训练依赖...
"%TRAIN_PY%" -m pip install --upgrade pip
"%TRAIN_PY%" -m pip install -r local_ai\train\requirements.txt
if errorlevel 1 (
  echo [ERROR] 安装训练依赖失败。
  pause
  exit /b 1
)

echo [4/4] 开始 LoRA 训练...
"%TRAIN_PY%" local_ai\train\train_lora.py %*
if errorlevel 1 (
  echo [ERROR] 训练失败。
  pause
  exit /b 1
)

echo.
echo 训练完成。
if exist "%LORA_DIR%" (
  echo 适配器输出目录: %LORA_DIR%
) else (
  echo [WARN] 未检测到适配器目录: %LORA_DIR%
)

if exist "%TRAIN_DATA%" (
  echo 训练数据目录: %TRAIN_DATA%
) else (
  echo [WARN] 未检测到训练数据文件: %TRAIN_DATA%
)

endlocal
exit /b 0
