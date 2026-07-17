from config import qdrant, OLLAMA_EMBED, STORAGE_DOCUMENTS
from qdrant_client.models import Filter, FieldCondition, MatchValue, PointStruct
from model import DocumentFile
from services.document_service import DocumentService
from ollama import embeddings
import uuid

class QdrantService:
    def search_documents(self, query: str, chat_room_id: int):
        embedding = self.embedding(text=query)
        result = qdrant.query_points(
            collection_name="documents",
            query=embedding,
            with_payload=True,
            limit=5,
            query_filter=Filter(
                must=[
                    FieldCondition(
                        key="chat_room_id",
                        match=MatchValue(
                            value=chat_room_id
                        )
                    )
                ]
            )
        )
        document_context = "\n\n".join(
            point.payload["text"]
            for point in result.points
        )
        return document_context
    
    def store_documents(self, documents: list[DocumentFile], chat_room_id: int):
        document_service = DocumentService()
        for document in documents:
            rawText = document_service.extract_text(document.file_path, document.extension)
            # rawText = document_service.extract_text(f"{STORAGE_DOCUMENTS}/{document.file_path}", document.extension)
            text = document_service.normalize_text(rawText)
            text = document_service.clean_text(text)
            text = document_service.fix_structure(text)
            text = document_service.final_clean(text)
            chunks = document_service.chunk_text(text)
            self.chunk_store(chat_room_id, chunks, document)

    def chunk_store(self, chat_room_id: int, chunks: list[str], document: DocumentFile):
        points = []
        for index, chunk in enumerate(chunks):
            embedding = self.embedding(chunk)
            points.append(PointStruct(
                id=str(uuid.uuid4()),
                vector=embedding,
                payload={
                    "chat_room_id": chat_room_id,
                    "file_name": document.file_name,
                    "file_path": document.file_path,
                    "file_type": document.extension,
                    "chunk_index": index + 1,
                    "text": chunk
                }
            ))
        qdrant.upsert(
            collection_name="documents",
            points=points
        )

    def embedding(self, text: str):
        response = embeddings(
            model=OLLAMA_EMBED,
            prompt=text
        )
        return response.embedding