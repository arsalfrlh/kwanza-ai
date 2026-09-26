from ollama import Client
from qdrant_client import QdrantClient

OLLAMA_CHAT_MODEL="qwen3.5:4b"
OLLAMA_EMBEDDING_MODEL="mxbai-embed-large"
API_KEY="kwanzxx-arsalfrlh"

client = Client(
    host="http://localhost:11434"
)

qdrant = QdrantClient(
    port=6333,
    host="localhost"
)