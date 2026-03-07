import os
from datetime import datetime, timedelta, timezone
from typing import Any

from fastapi import Depends, HTTPException, WebSocket, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt

_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "change-me-in-production-use-a-long-random-string")
_ALGORITHM = "HS256"
_TOKEN_EXPIRE_MINUTES = 60 * 8

_bearer_scheme = HTTPBearer(auto_error=False)


def create_access_token(username: str, role: str) -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=_TOKEN_EXPIRE_MINUTES)
    payload = {"sub": username, "role": role, "exp": expire}
    return jwt.encode(payload, _SECRET_KEY, algorithm=_ALGORITHM)


def _decode_token(token: str) -> dict[str, Any]:
    try:
        payload = jwt.decode(token, _SECRET_KEY, algorithms=[_ALGORITHM])
    except JWTError as exc:
        raise HTTPException(status_code=401, detail="令牌无效或已过期") from exc

    username = payload.get("sub")
    role = payload.get("role")
    if not username or not role:
        raise HTTPException(status_code=401, detail="令牌缺少必要声明")
    return {"username": username, "role": role}


def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(_bearer_scheme),
) -> dict[str, Any]:
    if credentials is None or credentials.scheme.lower() != "bearer":
        raise HTTPException(status_code=401, detail="缺少认证令牌")
    return _decode_token(credentials.credentials)


def require_admin(current_user: dict[str, Any] = Depends(get_current_user)) -> dict[str, Any]:
    if current_user["role"] != "admin":
        raise HTTPException(status_code=403, detail="仅管理员可执行该操作")
    return current_user


def authenticate_websocket(websocket: WebSocket) -> dict[str, Any]:
    auth_header = websocket.headers.get("authorization", "")
    token: str | None = None

    if auth_header.lower().startswith("bearer "):
        token = auth_header[7:].strip()
    if not token:
        token = websocket.query_params.get("token")

    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="WebSocket 缺少 token",
        )

    return _decode_token(token)