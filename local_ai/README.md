# 本地 OpenAI 兼容部署 + 训练数据准备

## 说明

- 官方 OpenAI 闭源模型不能在本地直接部署。
- 本方案提供 **OpenAI 兼容 API**：`Ollama + LiteLLM`。
- 前端仍按 OpenAI 接口调用（`/v1/chat/completions`）。

## 一键启动

在项目根目录执行：

```powershell
.\start_local_openai.bat
```

启动后使用：

- Base URL: `http://127.0.0.1:4000/v1`
- API Key: `local-key`
- Model: `gpt-4o-mini`

## 导出训练数据（SFT）

将当前设备/告警数据导出为 `jsonl`：

```powershell
.\backend\.venv312\Scripts\python.exe .\backend\tools\export_sft_dataset.py
```

输出文件：

- `local_ai/data/train.jsonl`

格式是常见对话微调格式：每行一个 `messages` 数组，可直接用于后续 LoRA/SFT 工具链。

## 直接训练（LoRA）

在项目根目录执行：

```powershell
.\train_local_model.bat
```

默认会执行：

1. 导出训练数据（`local_ai/data/train.jsonl`）
2. 创建训练环境（`local_ai/.venv_train`）
3. 安装训练依赖（`local_ai/train/requirements.txt`）
4. 开始 LoRA 训练（基础模型：`Qwen/Qwen2.5-0.5B-Instruct`）

训练产物目录：

- LoRA 适配器：`local_ai/models/qwen2.5-0.5b-lora`
- 训练中间 checkpoint：`local_ai/models/qwen2.5-0.5b-lora/checkpoints`

如需覆盖参数，可以追加：

```powershell
.\train_local_model.bat --epochs 3 --batch-size 1 --grad-accum 8
```

## 训练后接入推理

在项目根目录执行：

```powershell
.\serve_trained_model.bat
```

该脚本会：

1. 将 LoRA 适配器合并到基础模型（输出 `local_ai/models/qwen2.5-0.5b-merged`）
2. 启动本地 OpenAI 兼容推理服务（`http://127.0.0.1:8008/v1`）
3. 提示你重启 LiteLLM 网关以加载 `expert-local` 路由

然后前端配置为：

- Base URL：`http://127.0.0.1:4000/v1`
- API Key：`local-key`
- Model：`expert-local`

说明：

- LiteLLM 路由已配置在 `local_ai/litellm.config.yaml`
- `expert-local` 会转发到你机器上的训练后推理服务

## 下一步（训练）

你可以用任意 SFT 工具训练开源模型（例如 LLaMA-Factory / Axolotl / Unsloth）。

典型流程：

1. 选一个基础模型（如 Qwen2.5-7B-Instruct）
2. 用 `local_ai/data/train.jsonl` 做 LoRA 微调
3. 合并或加载 LoRA 权重
4. 用 Ollama 或 vLLM 部署推理
5. 通过 LiteLLM 暴露 OpenAI 兼容接口给前端
