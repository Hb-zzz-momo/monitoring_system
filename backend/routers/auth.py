from fastapi import APIRouter, HTTPException
from passlib.context import CryptContext
import database as db
from security import create_access_token

from models import LoginRequest, LoginResponse

router = APIRouter(prefix="/auth", tags=["auth"])

_pwd_ctx = CryptContext(schemes=["bcrypt"], deprecated="auto")


def _verify_password(plain_password: str, stored_password: str) -> bool:
    if stored_password.startswith("$2"):
        return _pwd_ctx.verify(plain_password, stored_password)
    return plain_password == stored_password


@router.post("/login", response_model=LoginResponse)
def login(body: LoginRequest):
    user = db.get_user(body.username)
    if user is None or not user["is_active"] or not _verify_password(body.password, user["hashed_password"]):
        raise HTTPException(status_code=401, detail="用户名或密码错误")

    token = create_access_token(body.username, user["role"])
    return LoginResponse(token=token, username=body.username, role=user["role"])
