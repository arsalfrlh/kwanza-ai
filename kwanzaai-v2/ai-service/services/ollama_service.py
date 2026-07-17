from ollama import chat, embeddings
from config import OLLAMA_MODEL
from config import OLLAMA_EMBED
from services.tools_service import ToolService
import json

class OllamaService:
    def __init__(self, chat_room_id: int):
        self.chat_room_id = chat_room_id
        self.tool_service = ToolService(chat_room_id=chat_room_id)

    def generate_chat(self, history: list[dict], is_upload_document: bool = False):
        messages = []
        assistant_content = ""
        assistant_thinking = ""
        toolCalls = []
        toolMessages = []
        moreTool = ""
        if(is_upload_document):
            moreTool = "- search uploaded document"
        messages.append(
            {
                "role": "system",
                "content": f"""
                    You are Kwanza AI, developed by Arsal Fahrulloh.

                    You can answer general questions normally.
                    Use tools only when you need:
                    - search web
                    {moreTool}

                    Do not use tools for general knowledge, casual conversation, or conceptual explanations.

                    Always use tool results when user asks for personal or searching website information.
                    Do not make up database information.
                """
            }
        )
        messages.extend(history)

        response = chat(
            model=OLLAMA_MODEL,
            stream=True,
            messages=messages,
            tools=self.tool_service.tools(is_upload_document=is_upload_document)
        )

        for chunk in response:
            if chunk.message.content:
                assistant_content += chunk.message.content
            if chunk.message.thinking:
                assistant_thinking += chunk.message.thinking
            if chunk.message.tool_calls:
                toolCalls.extend(chunk.message.tool_calls)
            yield json.dumps(chunk.model_dump()) + "\n"

        if(not toolCalls):
            # messages.append({
            #     "role": "assistant",
            #     "content": assistant_content,
            #     "thinking": assistant_thinking,
            #     "tool_calls": [
            #         tool.model_dump()
            #         for tool in toolCalls
            #     ]
            # })
            # yield json.dumps(messages) + "\n"
            return
        
        messages.append({
            "role": "assistant",
            "content": assistant_content,
            "thinking": assistant_thinking,
            "tool_calls": [
                tool.model_dump()
                for tool in toolCalls
            ]
        })

        for tool in toolCalls:
            tool_name = tool.function.name
            argument = tool.function.arguments or {}
            result = self.tool_service.executeTool(tool_name, arguments=argument)
            toolMessages.append({
                "role": "tool",
                "tool_name": tool_name,
                # "content": json.dumps(result)
                "content": result
            })
        messages.extend(toolMessages)

        final_response = chat(
            model=OLLAMA_MODEL,
            stream=True,
            messages=messages
        )

        # final_assistant_content = ""
        # final_assistant_thinking = ""
        for chunk in final_response:
            # if chunk.message.content:
            #     final_assistant_content += chunk.message.content
            # if chunk.message.thinking:
            #     final_assistant_thinking += chunk.message.thinking
            yield json.dumps(chunk.model_dump()) + "\n"

        # messages.append({
        #     "role": "assistant",
        #     "content": final_assistant_content,
        #     "thinking": final_assistant_thinking
        # })
        # yield json.dumps(messages) + "\n"

    def embedding(self, text: str):
        response = embeddings(
            model=OLLAMA_EMBED,
            prompt=text
        )
        return response.embedding