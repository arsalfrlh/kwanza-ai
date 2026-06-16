<?php
namespace App\Services;

use App\Events\ChatAiEvent;
use App\Events\ChatUpdate;
use App\Models\ChatRoom;
use App\Models\Message;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class MessageService
{
    public function index(Request $request){
        $user = $request->user();
        $data = ChatRoom::where('user_id', $user->id)->get();
        return [
            'message' => "Menampilkan semua data chat anda",
            'success' => true,
            'status_code' => 200,
            'data' => $data
        ];
    }

    public function show(Request $request, $chatRoomId){
        $user = $request->user();
        if(!ChatRoom::where('user_id', $user->id)->where('id', $chatRoomId)->exists()){
            return [
                'message' => "Anda tidak dapat membuka chat ini",
                'success' => false,
                'status_code' => 400
            ];
        }

        $data = Message::with('user')->where('chat_room_id', $chatRoomId)->get();
        return [
            'message' => "Menampilkan data chat anda",
            'success' => true,
            'status_code' => 200,
            'data' => $data
        ];
    }

    public function store(Request $request){
        $user = $request->user();
        $data = ChatRoom::create([
            'chat_name' => $request->chat_name,
            'user_id' => $user->id
        ]);

        return[
            'message' => "Berhasil membuat room",
            'success' => true,
            'status_code' => 201,
            'data' => $data
        ];
    }

    public function update(Request $request, $chatRoomId){
        set_time_limit(0);
        $user = $request->user();
        if(!ChatRoom::where('user_id', $user->id)->where('id', $chatRoomId)->exists()){
            return [
                'message' => "Anda tidak dapat mengirim chat ini",
                'success' => false,
                'status_code' => 400
            ];
        }

        $message = Message::create([
            'chat_room_id' => $chatRoomId,
            'user_id' => $user->id,
            'role' => 'user',
            'message' => $request->message
        ]);
        broadcast(new ChatUpdate($message));

        $history = Message::where('chat_room_id', $chatRoomId)->orderBy('id', 'desc')->limit(10)->get()->reverse()->map(function ($message) {
            return [
                'role' => $message->role,
                'content' => $message->message,
            ];
        })->values()->toArray();

        $response = Http::withOptions([
            'stream' => true
        ])->timeout(300)->post('http://localhost:11434/api/chat',[
            'model' => 'qwen2.5-coder:3b',
            'messages' => [
                [
                    'role' => 'system',
                    // 'content' => 'Kamu adalah Kwanza AI, sebuah asisten AI yang dibuat dan dikembangkan oleh Arsal Fahrulloh'
                    'content' => 'You are Kwanza AI, an AI assistant created and developed by Arsal Fahrulloh'
                ],
                ...$history
            ],
            'stream' => true
        ]);

        $body = $response->toPsrResponse()->getBody();
        $buffer = '';
        $fullText = "";
        while (!$body->eof()) {
            $buffer .= $body->read(1024);
            while (($pos = strpos($buffer, "\n")) !== false) {
                $line = substr($buffer, 0, $pos);
                $buffer = substr($buffer, $pos + 1);
                $line = trim($line);
                if (empty($line)) {
                    continue;
                }
                $data = json_decode($line, true);
                if (!$data) {
                    continue;
                }
                $chunk = $data['message']['content'] ?? '';
                $done = $data['done'] ?? false;
                $fullText .= $chunk;
                broadcast(new ChatAiEvent($chatRoomId, $chunk, $done));
                
                // logger('debug',[
                //     'chunk' => $chunk,
                //     'done' => $done
                // ]);
            }
        }

        $data = Message::create([
            'chat_room_id' => $chatRoomId,
            'role' => 'assistant',
            'message' => $fullText
        ]);
        $data->load('user');
        broadcast(new ChatUpdate($data));
        return [
            'message' => "Pesan berhasil dikirim",
            'success' => true,
            'status_code' => 201,
            'data' => $data
        ];
    }
}