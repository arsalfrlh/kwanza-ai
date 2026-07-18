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

## Demo

### Video

<p align="center">
  <a href="https://github.com/arsalfrlh/kwanza-ai/blob/main/Demo/video.mp4">
    <img src="https://github.com/arsalfrlh/kwanza-ai/blob/main/Demo/thumbnail.png" width="600"/>
  </a>
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

# Software Architecture

Kwanza AI is designed using multiple software architecture patterns to keep the application modular, scalable, and maintainable.

## MVVM (Flutter)

The Flutter application follows the **Model-View-ViewModel (MVVM)** pattern.

```text
View
    │
    ▼
ViewModel
    │
    ▼
Services
    │
    ▼
REST API / WebSocket
```

Responsibilities:

* **View** → Displays UI and listens to state changes.
* **ViewModel** → Manages presentation logic and application state.
* **Services** → Handles communication with the backend via REST API and WebSocket.

---

## Layered Architecture (Laravel)

The Laravel backend separates responsibilities into multiple layers.

```text
HTTP Request
      │
      ▼
Controller
      │
      ▼
Service Layer
      │
      ▼
Eloquent Model
      │
      ▼
Database
```

Responsibilities:

* **Controller** → Receives requests and returns responses.
* **Service Layer** → Contains business logic.
* **Model** → Handles data persistence.

This separation makes the backend easier to maintain and test.

---

## Event-Driven Architecture

Real-time communication is implemented using an event-driven architecture.

```text
User Message
      │
      ▼
Laravel Event
      │
      ▼
Broadcast
      │
      ▼
Flutter WebSocket
      │
      ▼
UI Update
```

The application publishes multiple events, including:

* Chat Updates
* AI Streaming Responses
* Tool Calling Status

This enables real-time communication without polling.

---

## Publish / Subscribe Pattern

WebSocket communication follows the Publish/Subscribe (Pub/Sub) pattern.

```text
Flutter
      │
Subscribe Channel
      │
      ▼
Laravel Reverb
      │
Broadcast Events
      │
      ▼
Subscribed Clients
```

Each chat room has its own private WebSocket channel, ensuring users only receive events related to their own conversations.

---

## Service-Oriented AI Architecture

Instead of embedding AI logic directly inside Laravel, Kwanza AI uses a dedicated AI service built with FastAPI.

```text
Flutter
      │
      ▼
Laravel Backend
      │
HTTP
      │
      ▼
FastAPI AI Service
      │
      ▼
Ollama
```

The AI service is responsible for:

* Prompt Management
* Tool Calling
* Document Processing
* Embedding Generation
* Semantic Search
* RAG Pipeline
* AI Streaming

This separation allows the backend and AI engine to evolve independently.

---

## Observer Pattern

Flutter uses the Observer pattern through `ChangeNotifier` and `StreamController`.

```text
WebSocket

↓

StreamController

↓

ViewModel

↓

notifyListeners()

↓

Widgets
```

Whenever new events arrive, the UI is updated automatically without manual refresh.

---

## Singleton Pattern

Several services, such as `WebsocketService`, are implemented as Singletons to ensure only one active connection is maintained during the application lifecycle.

---

## Dependency Injection

Laravel uses constructor dependency injection to inject services into controllers.

```text
Controller

↓

MessageService
```

This improves modularity, testability, and separation of concerns.

---

## Overall Architecture

The project combines multiple architectural patterns.

| Pattern                       | Purpose                     |
| ----------------------------- | --------------------------- |
| MVVM                          | Flutter presentation layer  |
| Layered Architecture          | Backend organization        |
| Service Layer                 | Business logic separation   |
| Event-Driven Architecture     | Real-time communication     |
| Publish / Subscribe           | WebSocket messaging         |
| Observer Pattern              | Automatic UI updates        |
| Singleton Pattern             | Shared application services |
| Dependency Injection          | Loose coupling              |
| Service-Oriented Architecture | Dedicated AI service        |

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
