from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from uuid import uuid4
import random
import time
from datetime import datetime, timedelta
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

app = FastAPI()

mock_username = "test"
mock_password = "test"
mock_otp = "123456"

sessions = {}

ACCESS_TOKEN_EXPIRATION = timedelta(minutes=30)
REFRESH_TOKEN_EXPIRATION = timedelta(days=7)

# CORS middleware for handling cross-origin requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def generate_access_token(user: str):
    token = f"access_token_for_{user}_{int(time.time())}"
    expiration_time = datetime.utcnow() + ACCESS_TOKEN_EXPIRATION
    return token, expiration_time

def generate_refresh_token(user: str):
    token = f"refresh_token_for_{user}_{int(time.time())}"
    expiration_time = datetime.utcnow() + REFRESH_TOKEN_EXPIRATION
    return token, expiration_time

class LoginRequest(BaseModel):
    username: str
    password: str


class OtpVerificationRequest(BaseModel):
    session_id: str
    otp: str


class RefreshTokenRequest(BaseModel):
    refresh_token: str


@app.post("/api/v1/login")
async def login(request: LoginRequest):
    if request.username == mock_username and request.password == mock_password:
        session_id = str(uuid4())
        sessions[session_id] = {
            "user": request.username,
            "otp": mock_otp,
            "is_verified": False
        }
        access_token, access_token_expiration = generate_access_token(request.username)
        refresh_token, refresh_token_expiration = generate_refresh_token(request.username)

        print(f"Session Created: session_id={session_id}, otp={mock_otp}")

        return {
            "login_status": "pending",
            "session_id": session_id,
            "otp": mock_otp
        }
    else:
        raise HTTPException(status_code=400, detail="Invalid username or password")


@app.post("/api/v1/verify_otp")
async def verify_otp(request: OtpVerificationRequest):
    session = sessions.get(request.session_id)

    if not session:
        raise HTTPException(status_code=400, detail="Session not found")

    if session["otp"] == request.otp:
        session["is_verified"] = True
        access_token, _ = generate_access_token(session["user"])
        refresh_token, _ = generate_refresh_token(session["user"])

        return {
            "login_status": "success",
            "access_token": access_token,
            "refresh_token": refresh_token
        }
    else:
        raise HTTPException(status_code=400, detail="Invalid OTP")


@app.post("/api/v1/token/refresh/")
async def refresh_token(request: RefreshTokenRequest):
    session = None
    for s in sessions.values():
        if s.get("refresh_token") == request.refresh_token:
            session = s
            break

    if not session:
        raise HTTPException(status_code=400, detail="Invalid refresh token")

    if datetime.utcnow() > session["refresh_token_expiration"]:
        raise HTTPException(status_code=401, detail="Refresh token expired")

    new_access_token, _ = generate_access_token(session["user"])
    session["access_token"] = new_access_token
    session["access_token_expiration"] = datetime.utcnow() + ACCESS_TOKEN_EXPIRATION

    return {"access_token": new_access_token}


if __name__ == "__main__":
    uvicorn.run("test:app", host="127.0.0.1", port=8001, reload=True)
