import os
from typing import Any, Literal

import torch
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from transformers import AutoModelForCausalLM, AutoTokenizer


MODEL_PATH = os.getenv("LOCAL_MODEL_PATH", "local_ai/models/qwen2.5-0.5b-merged")
MODEL_NAME = os.getenv("LOCAL_MODEL_NAME", "expert-local")
API_KEY = os.getenv("LOCAL_MODEL_API_KEY", "local-key")

app = FastAPI(title="Local OpenAI-Compatible Inference", version="1.0.0")


class ChatMessage(BaseModel):
    role: Literal["system", "user", "assistant"]
    content: str


class ChatCompletionRequest(BaseModel):
    model: str
    messages: list[ChatMessage]
    temperature: float = 0.7
    max_tokens: int = 512


class ChoiceMessage(BaseModel):
    role: str
    content: str


class Choice(BaseModel):
    index: int
    message: ChoiceMessage
    finish_reason: str


class ChatCompletionResponse(BaseModel):
    id: str
    object: str
    created: int
    model: str
    choices: list[Choice]


def _build_prompt(tokenizer: AutoTokenizer, messages: list[dict[str, str]]) -> str:
    return tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)


@app.on_event("startup")
def load_model() -> None:
    global tokenizer
    global model

    if not os.path.exists(MODEL_PATH):
        raise RuntimeError(f"Model path not found: {MODEL_PATH}")

    tokenizer = AutoTokenizer.from_pretrained(MODEL_PATH, use_fast=False)
    if tokenizer.pad_token is None:
        tokenizer.pad_token = tokenizer.eos_token

    model = AutoModelForCausalLM.from_pretrained(
        MODEL_PATH,
        torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32,
        device_map="auto" if torch.cuda.is_available() else None,
    )


@app.get("/v1/models")
def list_models() -> dict[str, Any]:
    return {
        "object": "list",
        "data": [{"id": MODEL_NAME, "object": "model", "owned_by": "local"}],
    }


@app.post("/v1/chat/completions", response_model=ChatCompletionResponse)
def chat_completions(req: ChatCompletionRequest) -> ChatCompletionResponse:
    if req.model != MODEL_NAME:
        raise HTTPException(status_code=400, detail=f"Unsupported model: {req.model}, expected: {MODEL_NAME}")

    if not req.messages:
        raise HTTPException(status_code=400, detail="messages is required")

    prompt = _build_prompt(tokenizer, [m.model_dump() for m in req.messages])
    inputs = tokenizer(prompt, return_tensors="pt")

    if torch.cuda.is_available():
        inputs = {k: v.to(model.device) for k, v in inputs.items()}

    with torch.no_grad():
        outputs = model.generate(
            **inputs,
            max_new_tokens=req.max_tokens,
            temperature=req.temperature,
            do_sample=req.temperature > 0,
            pad_token_id=tokenizer.eos_token_id,
        )

    generated_ids = outputs[0][inputs["input_ids"].shape[1] :]
    text = tokenizer.decode(generated_ids, skip_special_tokens=True).strip()

    import time

    return ChatCompletionResponse(
        id=f"chatcmpl-local-{int(time.time() * 1000)}",
        object="chat.completion",
        created=int(time.time()),
        model=MODEL_NAME,
        choices=[
            Choice(
                index=0,
                message=ChoiceMessage(role="assistant", content=text),
                finish_reason="stop",
            )
        ],
    )
