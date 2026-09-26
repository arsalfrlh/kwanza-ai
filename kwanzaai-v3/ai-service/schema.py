from pydantic import BaseModel

class Document(BaseModel):
    document_id: int
    conversation_id: int
    message_id: int
    original_file_name: str
    file_name: str
    file_type: str
    file_path: str

class Message(BaseModel):
    role: str
    content: str
    images: list[str] | None = None
    tool_calls: list[dict] | None = None
    tool_name: str | None = None

class ChatRequest(BaseModel):
    conversation_id: int
    documents: list[Document]
    messages: list[Message]