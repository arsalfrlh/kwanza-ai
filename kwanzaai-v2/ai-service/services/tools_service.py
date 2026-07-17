from services.qdrant_service import QdrantService
import json

class ToolService:
    def __init__(self, chat_room_id):
        self.chat_room_id = chat_room_id
        self.qdrant_service = QdrantService()

    def tools(self, is_upload_document: bool = False):
        tools = [
            {
                "type": "function",
                "function": {
                    "name": "search_web",
                    "description": (
                        "Search public internet information from websites and search engines. "
                        "Use this tool when the user asks about real-time, external, or public information "
                        "such as weather, news, cryptocurrency prices, stock market data, sports updates, "
                        "current events, exchange rates, public company information, or general web knowledge "
                        "requiring up-to-date data. Do not use this tool for internal ecommerce database "
                        "or uploaded document searches."
                    ),
                    "parameters": {
                        "type": "object",
                        "properties": {
                            "query": {
                                "type": "string",
                                "description": "Search query for retrieving information from the web"
                            }
                        },
                        "required": ["query"]
                    }
                }
            }
        ]
        if is_upload_document:
            tools.append(
                {
                    "type": "function",
                    "function": {
                        "name": "search_uploaded_document",
                        "description": (
                            "Search user uploaded documents inside the current chat room using semantic search. "
                            "Use this tool when the user asks questions related to files they uploaded earlier "
                            "in this conversation."
                        ),
                        "parameters": {
                            "type": "object",
                            "properties": {
                                "query": {
                                    "type": "string",
                                    "description": "Question or keyword used to search uploaded documents"
                                }
                            },
                            "required": ["query"]
                        }
                    }
                }
            )
        return tools
    
    def executeTool(self, name: str, arguments: dict):
        if name == "search_web":
            return json.dumps(self.toolWebSearch(arguments["query"]), ensure_ascii=False)
        if name == "search_uploaded_document":
            return self.searchUploadedDocument(arguments["query"],chat_room_id=self.chat_room_id)
        return {
            "error": "Unknown tool"
        }

    def searchUploadedDocument(self, query: str, chat_room_id: int):
        return self.qdrant_service.search_documents(query, chat_room_id)

    def toolWebSearch(self, query: str):
        return {
            "query": query,
            "source": "https://www.logammulia.com/id/harga-emas-hari-ini",
            "result": {
                "title": "Harga Emas Hari Ini, di tahun 2026",
                "content": """
    Berat	Harga Dasar	Harga (+Pajak PPh 0.25%)
    Emas Batangan
    0.5 gr	1,385,000	1,388,463
    1 gr	2,670,000	2,676,675
    2 gr	5,280,000	5,293,200
    3 gr	7,895,000	7,914,738
    5 gr	13,125,000	13,157,813
    10 gr	26,195,000	26,260,488
    25 gr	65,362,000	65,525,405
    50 gr	130,645,000	130,971,613
    100 gr	261,212,000	261,865,030
    250 gr	652,765,000	654,396,913
    500 gr	1,305,320,000	1,308,583,300
    1000 gr	2,610,600,000	2,617,126,500
    Emas Batangan Gift Series
    0.5 gr	1,455,000	1,458,638
    1 gr	2,820,000	2,827,050
    Emas Batangan Selamat Idul Fitri
    5 gr	14,098,000	14,133,245
    Emas Batangan Imlek
    8 gr	22,214,800	22,270,337
    88 gr	241,657,600	242,261,744
    Emas Batangan Batik Seri III
    10 gr	27,200,000	27,268,000
    20 gr	53,600,000	53,734,000


    Perak Murni
    Berat	Harga Dasar	Harga Sudah Termasuk PPN 11%
    250 gr	10,887,500	12,085,125
    500 gr	20,975,000	23,282,250
    Perak Heritage
    Berat	Harga Dasar	Harga Sudah Termasuk PPN 11%
    31.1 gr	1,852,428	2,056,195
    186.6 gr	9,993,166	11,092,414
    """
            }
        }