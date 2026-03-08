from typing import Optional

from fastapi import APIRouter, HTTPException, status
from passlib.context import CryptContext
import database as db
from security import create_access_token

from models import LoginRequest, LoginResponse, RegisterRequest, RegisterResponse

router = APIRouter(prefix="/auth", tags=["auth"])

_pwd_ctx = CryptContext(schemes=["bcrypt"], deprecated="auto")


def _verify_password(plain_password: str, stored_password: str) -> bool:
    if stored_password.startswith("$2"):
        return _pwd_ctx.verify(plain_password, stored_password)
    return plain_password == stored_password


def _clean_optional(value: Optional[str]) -> Optional[str]:
    if value is None:
        return None
    text = value.strip()
    return text if text else None


@router.post("/register", response_model=RegisterResponse, status_code=status.HTTP_201_CREATED)
def register(body: RegisterRequest):
    username = body.username.strip()
    if not username or any(ch.isspace() for ch in username):
        raise HTTPException(status_code=400, detail="用户名不能为空且不能包含空白字符")

    if db.get_user(username) is not None:
        raise HTTPException(status_code=409, detail="用户名已存在")

    try:
        user = db.create_user(
            username=username,
            hashed_password=_pwd_ctx.hash(body.password),
            role="operator",
            display_name=_clean_optional(body.displayName),
            email=_clean_optional(body.email),
            phone=_clean_optional(body.phone),
        )
    except ValueError as exc:
        raise HTTPException(status_code=409, detail="用户名已存在") from exc
    token = create_access_token(user["username"], user["role"])
    return RegisterResponse(
        token=token,
        username=user["username"],
        role=user["role"],
        displayName=user.get("display_name"),
        email=user.get("email"),
        phone=user.get("phone"),
    )


@router.post("/login", response_model=LoginResponse)
def login(body: LoginRequest):
    user = db.get_user(body.username)
    if user is None or not user["is_active"] or not _verify_password(body.password, user["hashed_password"]):
        raise HTTPException(status_code=401, detail="用户名或密码错误")

    token = create_access_token(body.username, user["role"])
    return LoginResponse(
        token=token,
        username=body.username,
        role=user["role"],
        displayName=user.get("display_name"),
        email=user.get("email"),
        phone=user.get("phone"),
    )
