from fastapi import FastAPI, Request, Header
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse, StreamingResponse
from config import API_KEY
from schema import ChatRequest
from services.qdrant_service import QdrantService
from services.llm_service import LlmService
from typing import Any

app = FastAPI()

@app.exception_handler(RequestValidationError)
def request_validation(request: Request, exc: RequestValidationError):
    return JSONResponse(
        status_code=422,
        content={
            "message": exc.errors(),
            "success": False
        }
    )

@app.get("/")
def root():
    return responseFormat("AI Service Running", True)

@app.post("/chat")
def send_chat(request: ChatRequest, kwanzx_key: str = Header(...)):
    if kwanzx_key != API_KEY:
        return responseFormat("Invalid APIKE", False, status_code=401)

    if request.documents:
        qdrant_service = QdrantService()
        qdrant_service.store_qdrant(request.documents)

    llm_service = LlmService(request.conversation_id)
    return StreamingResponse(
        content=llm_service.generate_chat(request),
        media_type="application/x-ndjson"
    )

def responseFormat(message: Any, success: bool, status_code: int = 200, data: Any = None):
    return JSONResponse(
        status_code=status_code,
        content={
            "message": message,
            "success": success,
            "data": data
        }
    )