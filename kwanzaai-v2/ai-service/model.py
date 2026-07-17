from pydantic import BaseModel
from typing import Optional

class Message(BaseModel):
    role: str
    content: str
    images: Optional[list[str]] = None

class DocumentFile(BaseModel):
    id: int
    extension: str
    file_name: str
    file_path: str

class ChatRequest(BaseModel):
    is_upload_document: bool
    messages: list[Message]
    documents: Optional[list[DocumentFile]] = None
    chat_room_id: int

# bisa dibuat seperti ini jika ingin simple
# class ChatRequest(BaseModel):
#     messages: list[dict]
#     documents: list[dict]
#     images: list[str]