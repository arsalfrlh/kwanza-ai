# Kwanza AI

> **A Local AI Chat Platform powered by Laravel, FastAPI, Flutter, Ollama, Qdrant, and WebSocket Streaming.**

Kwanza AI is an AI-powered chat platform that combines a modern Laravel backend, a dedicated FastAPI AI service, Flutter mobile application, and Ollama Local LLM to deliver a real-time ChatGPT-like experience.

The application supports AI streaming, Retrieval-Augmented Generation (RAG), Tool Calling, document understanding, image input, semantic search, and real-time communication using WebSocket.

---

## Screenshots

### Chat Screen

<p align="center">
  <img src="https://github.com/arsalfrlh/kwanza-ai/blob/main/Demo/response.png" width="250"/>
</p>

### AI Streaming Response

<p align="center">
  <img src="https://github.com/arsalfrlh/kwanza-ai/blob/main/Demo/response-stream.png" width="250"/>
</p>

### Chat Room Drawer

<p align="center">
  <img src="https://github.com/arsalfrlh/kwanza-ai/blob/main/Demo/drawer.png" width="250"/>
</p>

---

# Features

## Authentication

* Login
* Register
* Laravel Sanctum Authentication
* Protected API Routes

---

## Chat

* Multiple Chat Rooms
* Conversation History
* Persistent Messages
* Typing Indicator
* Real-time AI Response
* Chat History Management

---

## AI

* Local LLM using Ollama
* Streaming Response
* Tool Calling
* Context-aware Conversation
* Multi-turn Conversation
* System Prompt Support

---

## Document AI (RAG)

* Upload Documents
* Automatic Text Extraction
* Text Normalization
* Text Cleaning
* Document Chunking
* Vector Embedding
* Semantic Search
* Context Retrieval

Supported file types include:

* PDF
* DOCX
* TXT
* CSV
* PPTX
* XLSX
* HTML

---

## Image AI

* Upload Images
* Vision Model Support
* Image Understanding using Ollama Vision Models

---

## Real-Time Communication

* Laravel Reverb
* WebSocket Streaming
* Private Channels
* Automatic Reconnection
* Live AI Token Streaming
* Tool Status Notification

---

# System Architecture

```text
                       Flutter
                          │
              REST API + WebSocket
                          │
                          ▼
                  Laravel Backend
        ┌────────────────────────────────┐
        │ Authentication                 │
        │ Chat Room                      │
        │ Message                        │
        │ Upload Image                   │
        │ Upload Document                │
        │ Database                       │
        │ Broadcasting                   │
        └───────────────┬────────────────┘
                        │ HTTP Streaming
                        ▼
                 FastAPI AI Service
        ┌────────────────────────────────┐
        │ Ollama Local LLM               │
        │ Tool Calling                   │
        │ Prompt Management              │
        │ Document Processing            │
        │ Embedding                      │
        │ Qdrant                         │
        │ Semantic Search                │
        └────────────────────────────────┘
```

---

# AI Request Flow

```text
User

↓

Flutter

↓

Laravel API

↓

FastAPI AI Service

↓

Ollama

↓

Tool Calling?

 ├── Search Uploaded Document
 └── Search Web

↓

LLM Response

↓

Streaming Response (NDJSON)

↓

Laravel

↓

Broadcast Event

↓

Flutter

↓

Real-time UI
```

---

# Document Processing Pipeline

Every uploaded document goes through the following pipeline:

```text
Upload Document

↓

Extract Text

↓

Normalize Text

↓

Clean Text

↓

Fix Document Structure

↓

Chunking

↓

Generate Embedding

↓

Store into Qdrant

↓

Semantic Search

↓

Retrieved Context

↓

LLM Response
```

---

# Streaming Pipeline

Kwanza AI streams every generated token from the AI model to the Flutter application in real time.

```text
Ollama

↓

FastAPI StreamingResponse

↓

Laravel HTTP Streaming

↓

Laravel Broadcast

↓

WebSocket

↓

Flutter UI
```

This architecture provides a smooth ChatGPT-like streaming experience.

---

# Tool Calling

The AI can automatically decide when additional information is needed.

Current supported tools:

* Search Uploaded Document
* Search Public Web

The LLM automatically:

1. Detects whether a tool is required.
2. Calls the appropriate tool.
3. Receives the tool result.
4. Generates the final answer.

---

# Retrieval-Augmented Generation (RAG)

Uploaded documents are converted into vector embeddings and stored inside Qdrant.

When users ask questions related to their uploaded files:

1. User question is converted into embeddings.
2. Semantic search is performed.
3. Relevant chunks are retrieved.
4. Retrieved context is injected into the LLM.
5. AI generates context-aware responses.

---

# Tech Stack

## Backend

* Laravel 12
* PHP 8+
* MySQL
* Laravel Sanctum
* Laravel Reverb

## AI Service

* FastAPI
* Python
* Ollama
* Qdrant
* Pydantic

## Frontend

* Flutter
* Provider
* Dio
* SharedPreferences
* WebSocket Channel

## AI Models

Supports any Ollama model, including:

* Qwen
* Gemma
* Llama
* DeepSeek
* Any custom Ollama model

---

# Project Structure

```text
Flutter
│
├── UI
├── ViewModel
├── Services
└── WebSocket

Laravel
│
├── Authentication
├── Chat Rooms
├── Messages
├── Broadcasting
├── Upload Management
└── REST API

FastAPI
│
├── Ollama Service
├── Tool Service
├── Qdrant Service
├── Document Service
└── Prompt Management
```

---

# Installation

## Laravel Backend

```bash
git clone https://github.com/arsalfrlh/kwanza-ai.git

composer install

cp .env.example .env

php artisan key:generate

php artisan migrate

php artisan storage:link

php artisan reverb:start

php artisan serve
```

---

## FastAPI AI Service

```bash
python -m venv venv

pip install -r requirements.txt

python main.py
```

---

## Ollama

Install Ollama:

```bash
https://ollama.com
```

Pull your preferred model:

```bash
ollama pull qwen3
```

Run Ollama:

```bash
ollama serve
```

---

## Flutter

```bash
flutter pub get

flutter run
```

---

# API

## Authentication

```
POST /api/register
POST /api/login
GET  /api/user
```

## Chat

```
GET    /api/message
POST   /api/message
GET    /api/message/{id}
PUT    /api/message/{title}
```

## AI Service

```
POST /chat
```

---

# Security

* Laravel Sanctum Authentication
* Protected API Routes
* Private WebSocket Channels
* Room Authorization
* API Key Validation for AI Service

---

# Future Roadmap

* AI Memory Summarization
* Multi-Agent Workflow
* MCP (Model Context Protocol)
* Web Search Integration
* Voice Assistant (STT & TTS)
* AI Workflow Builder
* Citation & Source Tracking
* Markdown Rendering
* Code Syntax Highlighting
* Model Management
* Plugin System

---

# Author

**Arsal Fahrulloh**

Full Stack Developer | Backend Developer | AI Engineer Enthusiast

Built using Laravel, FastAPI, Flutter, Ollama, and Qdrant.
