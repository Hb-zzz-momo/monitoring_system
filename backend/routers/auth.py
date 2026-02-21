import os
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, HTTPException
from jose import jwt
from passlib.context import CryptContext

from models import LoginRequest, LoginResponse

router = APIRouter(prefix="/auth", tags=["auth"])

# Secret key – override via JWT_SECRET_KEY env-var in production.
_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "change-me-in-production-use-a-long-random-string")
_ALGORITHM = "HS256"
_TOKEN_EXPIRE_MINUTES = 60 * 8  # 8 hours

_pwd_ctx = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Pre-hashed passwords for demo accounts.
_USERS = {
    "demo":  {"hashed_password": _pwd_ctx.hash("demo123"),  "role": "operator"},
    "admin": {"hashed_password": _pwd_ctx.hash("admin123"), "role": "admin"},
}


def _create_token(username: str, role: str) -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=_TOKEN_EXPIRE_MINUTES)
    payload = {"sub": username, "role": role, "exp": expire}
    return jwt.encode(payload, _SECRET_KEY, algorithm=_ALGORITHM)


@router.post("/login", response_model=LoginResponse)
def login(body: LoginRequest):
    user = _USERS.get(body.username)
    if user is None or not _pwd_ctx.verify(body.password, user["hashed_password"]):
        raise HTTPException(status_code=401, detail="用户名或密码错误")

    token = _create_token(body.username, user["role"])
    return LoginResponse(token=token, username=body.username, role=user["role"])
