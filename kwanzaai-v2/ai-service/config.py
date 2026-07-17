from qdrant_client import QdrantClient

OLLAMA_MODEL="qwen3.5:4b"
OLLAMA_EMBED="mxbai-embed-large"
API_KEY="kwanzxx-arsalfrlh"
STORAGE_DOCUMENTS="C:/xampp/htdocs/kwanzaai/backend/storage/app/public"

qdrant = QdrantClient(
    host="localhost",
    port=6333
)