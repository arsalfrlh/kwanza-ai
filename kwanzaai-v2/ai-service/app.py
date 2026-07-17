from fastapi import FastAPI, Header, HTTPException
from fastapi.responses import StreamingResponse
from model import ChatRequest
from config import API_KEY
from services.qdrant_service import QdrantService
from services.ollama_service import OllamaService

app = FastAPI()

@app.post("/chat")
def sendChat(request: ChatRequest, kwanzx_key: str = Header(...)):
    print("APP LOADED")
    if(kwanzx_key != API_KEY):
        raise HTTPException(
            status_code=400,
            detail="Invalid API Key"
        )
    qdrant_service = QdrantService()
    ollama_service = OllamaService(chat_room_id=request.chat_room_id)
    history = []
    for message in request.messages:
        if(message.images):
            history.append({
                "role": message.role,
                "content": message.content,
                "images": message.images
            })
        else:
            history.append({
                "role": message.role,
                "content": message.content
            })

    if(request.documents):
        qdrant_service.store_documents(request.documents, request.chat_room_id)
        
    return StreamingResponse(
        ollama_service.generate_chat(history=history, is_upload_document=request.is_upload_document),
        media_type="application/x-ndjson"
    )