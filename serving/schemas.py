from pydantic import BaseModel
from typing import List, Literal, Optional


class Message(BaseModel):
    role: Literal["user"]
    content: str


class CompletionRequest(BaseModel):
    messages: List[Message]


class CompletionResponse(BaseModel):
    status: str
    response: Optional[List[dict]]


class StatusResponse(BaseModel):
    status: Literal["NOT_DEPLOYED", "PENDING", "DEPLOYING", "RUNNING"]


class ModelInfo(BaseModel):
    model_id: str


class ModelRequest(BaseModel):
    model_id: str


class GenericResponse(BaseModel):
    status: str
    model_id: Optional[str] = None
    message: Optional[str] = None
