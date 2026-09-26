from config import QdrantClient, qdrant
from qdrant_client.models import PointStruct, Filter, MatchValue, FieldCondition
from services.embedding_service import EmbeddingService
from services.document_service import DocumentService
from schema import Document
import uuid

class QdrantService:
    def __init__(self):
        self.embedding_service = EmbeddingService()
        self.document_service = DocumentService()

    def store_qdrant(self, documents: list[Document]):
        for document in documents:
            raw_text = self.document_service.extract_text(document.file_path, document.file_type)
            text = self.document_service.normalize_text(raw_text)
            text = self.document_service.clean_text(text)
            text = self.document_service.fix_structure(text)
            text = self.document_service.final_clean(text)
            chunks = self.document_service.chunk_text(text)
            self.chunk_store(chunks, document)

    def chunk_store(self, chunks: list[str], document: Document):
        points = []
        for index, chunk in enumerate(chunks):
            vector = self.embedding_service.embedding(chunk)
            points.append(PointStruct(
                id=str(uuid.uuid4()),
                vector=vector,
                payload={
                    "document_id": document.document_id,
                    "conversation_id": document.conversation_id,
                    "message_id": document.message_id,
                    "chunk_index": index + 1,
                    "original_file_name": document.original_file_name,
                    "file_name": document.file_name,
                    "file_type": document.file_type,
                    "file_path": document.file_path,
                    "text": chunk
                }
            ))
        qdrant.upsert(
            collection_name="conversation_documents",
            points=points
        )

    def search_document(self, query: str, conversation_id: int):
        embed = self.embedding_service.embedding(query)
        result =  qdrant.query_points(
            collection_name="conversation_documents",
            query=embed,
            with_payload=True,
            limit=5,
            query_filter=Filter(
                must=[
                    FieldCondition(
                        key="conversation_id",
                        match=MatchValue(
                            value=conversation_id
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