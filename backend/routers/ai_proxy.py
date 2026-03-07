import json
import os
from urllib import request, error

from fastapi import APIRouter, Depends, HTTPException, Request
from fastapi.responses import JSONResponse
from security import get_current_user

router = APIRouter(prefix="/v1", tags=["ai-proxy"])


def _get_upstream_base() -> str:
    return os.getenv("AI_UPSTREAM_BASE", "http://127.0.0.1:8008/v1").rstrip("/")


@router.post("/chat/completions")
async def chat_completions(request_in: Request, _current_user: dict = Depends(get_current_user)):
    body = await request_in.body()
    upstream_url = f"{_get_upstream_base()}/chat/completions"

    headers = {"Content-Type": "application/json"}
    auth = request_in.headers.get("authorization")
    if auth:
        headers["Authorization"] = auth

    req = request.Request(upstream_url, data=body, headers=headers, method="POST")

    try:
        with request.urlopen(req, timeout=60) as resp:
            raw = resp.read()
            try:
                payload = json.loads(raw.decode("utf-8"))
            except Exception:
                payload = {"raw": raw.decode("utf-8", errors="replace")}
            return JSONResponse(status_code=resp.status, content=payload)
    except error.HTTPError as exc:
        raw = exc.read().decode("utf-8", errors="replace")
        try:
            payload = json.loads(raw)
        except Exception:
            payload = {"detail": raw}
        return JSONResponse(status_code=exc.code, content=payload)
    except Exception as exc:
        raise HTTPException(status_code=502, detail=f"AI 上游不可用: {exc}")
