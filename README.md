# Kwanza AI

Kwanza AI is a real-time AI Chat Application built using Laravel, Flutter, Laravel Reverb, WebSocket, Queue Workers, and Ollama Local AI.

The application supports:

* Real-time AI streaming responses
* Multiple chat rooms
* Conversation memory (context history)
* Authentication with Laravel Sanctum
* Private WebSocket channels
* Local AI models via Ollama
* Cross-platform Flutter client

---

## Screenshots

### Chat Screen

<p align="center">
  <img src="https://github.com/arsalfrlh/social-media-app-laravel-flutter/blob/main/Demo/1.jpg" width="250"/>
  <img src="https://github.com/arsalfrlh/social-media-app-laravel-flutter/blob/main/Demo/2.jpg" width="250"/>
</p>

### AI Streaming Response

<p align="center">
  <img src="https://github.com/arsalfrlh/social-media-app-laravel-flutter/blob/main/Demo/1.jpg" width="250"/>
  <img src="https://github.com/arsalfrlh/social-media-app-laravel-flutter/blob/main/Demo/2.jpg" width="250"/>
</p>

### Chat Room Drawer

<p align="center">
  <img src="https://github.com/arsalfrlh/social-media-app-laravel-flutter/blob/main/Demo/1.jpg" width="250"/>
  <img src="https://github.com/arsalfrlh/social-media-app-laravel-flutter/blob/main/Demo/2.jpg" width="250"/>
</p>

---

## Demo

### Video Demo

https://youtube.com/watch?v=YOUR_VIDEO_URL

---

# Features

## Authentication

* Login
* Register
* Logout
* Laravel Sanctum Token Authentication

## Chat Room

* Create new chat room
* View chat history
* Multi-room conversation support

## AI Chat

* Real-time AI response streaming
* Typing indicator
* Persistent conversation history
* Context-aware responses

## WebSocket

* Laravel Reverb
* Private Channels
* Real-time message updates
* Automatic reconnection

## Local AI

Powered by Ollama:

* qwen2.5-coder:3b
* llama3
* gemma3
* deepseek-r1

(Any Ollama model can be used)

---

# Architecture

User
↓
Flutter App
↓
Laravel API
↓
Laravel Service Layer
↓
Ollama Local AI
↓
Streaming Response
↓
Laravel Reverb
↓
Flutter UI

---

# Tech Stack

## Backend

* Laravel 12
* PHP 8+
* Laravel Sanctum
* Laravel Reverb
* Queue Worker
* MySQL

## Frontend

* Flutter
* Provider
* Dio
* SharedPreferences
* WebSocket Channel

## AI

* Ollama
* Qwen 2.5 Coder

---

# Project Structure

Backend

app/
├── Events/
├── Http/
├── Models/
├── Services/
└── Providers/

Frontend

lib/
├── models/
├── services/
├── viewmodels/
├── views/
└── widgets/

---

# Installation

## Backend

Clone repository

git clone https://github.com/arsalfrlh/kwanza-ai.git

Install dependencies

composer install

Copy environment

cp .env.example .env

Generate application key

php artisan key:generate

Run migrations

php artisan migrate

Start queue worker

php artisan queue:work

Start Reverb

php artisan reverb:start

Start Laravel server

php artisan serve

---

## Ollama

Install Ollama

https://ollama.com

Pull model

ollama pull qwen2.5-coder:3b

Run Ollama

ollama serve

---

## Flutter

Install packages

flutter pub get

Run application

flutter run

---

# API Endpoints

## Authentication

POST /api/register

POST /api/login

POST /api/logout

GET /api/user

---

## Chat Rooms

GET /api/message

POST /api/message

GET /api/message/{id}

PUT /api/message/{id}

---

# Security

* Sanctum Authentication
* Private WebSocket Channels
* User-based Room Authorization
* Protected Broadcast Routes

---

# Real-Time AI Streaming

The application uses:

Laravel Reverb
+
Queue Worker
+
Ollama Streaming API

to stream AI responses token-by-token directly into the Flutter UI.

This provides a ChatGPT-like experience with minimal latency.

---

# Conversation Memory

Kwanza AI maintains recent conversation history and sends it to Ollama using the `/api/chat` endpoint.

Benefits:

* Context-aware responses
* Multi-turn conversations
* Better user experience

---

# Future Improvements

* Markdown Rendering
* Syntax Highlighting
* Copy Code Button
* AI Model Switcher
* Voice Assistant
* RAG (Retrieval-Augmented Generation)
* Vector Embeddings
* Recommendation System

---

# Author

Arsal Fahrulloh

Fullstack Web & Mobile Developer

Built with:

* Laravel
* Flutter
* Ollama

---

# Support

If you find this project useful, please consider giving it a star on GitHub.
