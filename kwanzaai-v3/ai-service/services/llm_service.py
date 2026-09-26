from config import client, OLLAMA_CHAT_MODEL
from services.tool_service import ToolService
from schema import ChatRequest
import json

class LlmService:
    def __init__(self, conversation_id: int):
        self.tool_service = ToolService(conversation_id)
        self.conversation_id = conversation_id

    def generate_chat(self, request: ChatRequest):
        messages = [
            {
                "role": "system",
                "content": """
                    You are Kwanza AI Assistant, developed by Arsal Fahrulloh. You can answer general questions normally.
                    Your primary purpose is to help users and answer general questions accurately and clearly.

                    You can answer general questions normally.
                    Use tools only when you need:
                    1. search_uploaded_document
                    Use this tool when the user asks about files they uploaded in the current conversation.
                    Use this tool when:
                    - Questions about uploaded files PDF, DOCX, TXT, JSON, or other supported documents
                    - Finding information inside uploaded documents
                    - Summarizing or comparing information contained in uploaded documents

                    2. search_web
                    Retrieve current or external internet information.
                    Use this tool when:
                    - the information may have changed recently
                    - the user asks for current information
                    - external sources are needed

                    3. calculator
                    Use this tool whenever the user asks for:
                    - arithmetic calculations
                    - percentages
                    - discounts
                    - taxes
                    - tips
                    - averages
                    - statistics
                    - powers
                    - roots
                    - logarithms
                    - trigonometry
                    - factorial
                    - combinations
                    - permutations
                    - simple interest
                    - compound interest
                    - loan payments
                    - percentage changes
                    - CAGR
                    - or any other numerical calculation
                    IMPORTANT:
                    - Do not perform complex calculations mentally when calculator can be used.
                    - Always use calculator for numerical calculations.
                    - Do not invent calculator results.
                    - Use the calculator result in your final answer.
                    - For ambiguous mathematical expressions, interpret them using standard mathematical precedence.

                    CONVERSATION CONTEXT
                    The user may provide upload document context together with their message.
                    Context can contain information such as:
                    [UPLOADED FILE] Document File Name
                """
            }
        ]
        for message in request.messages:
            content = {
                "role": message.role,
                "content": message.content
            }
            if message.images:
                content['images'] = message.images
            if message.tool_calls:
                content['tool_calls'] = message.tool_calls
            if message.tool_name:
                content['tool_name'] = message.tool_name
            messages.append(content)

        while True:
            full_content = ""
            full_thinking = ""
            tool_calls = []

            response = client.chat(
                model=OLLAMA_CHAT_MODEL,
                messages=messages,
                tools=self.tool_service.tools(),
                stream=True
            )

            for chunk in response:
                if chunk.message.content:
                    full_content += chunk.message.content
                if chunk.message.thinking:
                    full_thinking += chunk.message.thinking
                if chunk.message.tool_calls:
                    tool_calls.extend(chunk.message.tool_calls)
                    # tool_calls.extend([
                    #     tool.model_dump()
                    #     for tool in chunk.message.tool_calls
                    # ])
                yield json.dumps(chunk.model_dump()) + "\n"

                if chunk.done:
                    messages.append({
                        "role": "assistant",
                        "thinking": full_thinking,
                        "content": full_content,
                        "tool_calls": tool_calls
                    })
                    if tool_calls:
                        for tool in tool_calls:
                            tool_name = tool.function.name
                            arguments = tool.function.arguments or {}
                            # tool_name = tool['function']['name']
                            # arguments = tool['function']['arguments'] or {}
                            tool_display_name = None
                            if tool_name == "search_web":
                                tool_display_name = "Searching Web"
                            elif tool_name == "search_uploaded_document":
                                tool_display_name = "Search Document"
                            elif tool_name == "calculator":
                                tool_display_name = "Calculation"

                            start_tool = {
                                "message": {
                                    "role": "tool",
                                    "tool_name": None,
                                    "arguments": None,
                                    "tool_display_name": tool_display_name,
                                    "content": "",
                                    "thinking": None,
                                    "tool_calls": None,
                                    "done": False
                                }
                            }
                            yield json.dumps(start_tool) + "\n"
                            tool_result = self.tool_service.executeTool(tool_name, arguments)
                            messages.append({
                                "role": "tool",
                                "tool_name": tool_name,
                                "content": tool_result
                            })
                            result = tool_result
                            if tool_name == "search_uploaded_document":
                                result = json.dumps({
                                    "document_context": tool_result
                                })
                            end_tool = {
                                "message": {
                                    "role": "tool",
                                    "tool_name": tool_name,
                                    "arguments": tool.function.arguments or None,
                                    # "arguments": arguments or None,
                                    "tool_display_name": None,
                                    "content": result,
                                    "thinking": None,
                                    "tool_calls": None,
                                    "done": False
                                }
                            }
                            yield json.dumps(end_tool) + "\n"
                    else:
                        done_streaming = {
                            "message": {
                                "role": "assistant",
                                "content": "",
                                "thinking": None,
                                "tool_calls": None,
                                "done": True
                            }
                        }
                        yield json.dumps(done_streaming) + "\n"
                        # yield json.dumps(messages) + "\n"
                        return