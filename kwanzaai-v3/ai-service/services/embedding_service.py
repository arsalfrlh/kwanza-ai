from config import client, OLLAMA_EMBEDDING_MODEL

class EmbeddingService:
    def __init__(self):
        return

    def embedding(self, text: str):
        embed = client.embeddings(
            model=OLLAMA_EMBEDDING_MODEL,
            prompt=text
        )
        return embed.embedding