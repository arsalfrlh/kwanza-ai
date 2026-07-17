<?php
namespace App\Services;

use App\Events\AIResponse;
use App\Events\ChatUpdate;
use App\Events\ToolsEvent;
use App\Models\ChatImage;
use App\Models\ChatRoom;
use App\Models\Document;
use App\Models\Message;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Storage;

class MessageService
{
    public function getAllChatRoom(Request $request){
        $user = $request->user();
        $data = ChatRoom::where('user_id', $user->id)->get();
        return [
            'message' => "Menampilkan data room anda",
            'success' => true,
            'status_code' => 200,
            'data' => $data
        ];
    }

    public function createNewRoom(Request $request, $title){
        $user = $request->user();
        $data = ChatRoom::create([
            'user_id' => $user->id,
            'title' => $title
        ]);

        return [
            'message' => "Chat Room berhasil dibuat",
            'success' => true,
            'status_code' => 201,
            'data' => $data
        ];
    }

    public function getAllMessage(Request $request, $id){
        $user = $request->user();
        if(!ChatRoom::where('user_id', $user->id)->where('id', $id)->exists()){
            return [
                'message' => "Anda tidak bisa akses room ini",
                'success' => false,
                'status_code' => 400
            ];
        }

        $data = Message::with('chatImage','document')->where('chat_room_id', $id)->get();
        return [
            'message' => "Menampilkan semua pesan anda",
            'success' => true,
            'status_code' => 200,
            'data' => $data
        ];
    }
    
    public function sendMessage(Request $request){
        set_time_limit(0);
        $user = $request->user();
        if(!ChatRoom::where('user_id', $user->id)->where('id', $request->chat_room_id)->exists()){
            return [
                'message' => "Anda tidak bisa akses room ini",
                'success' => false,
                'stataus_code' => 400
            ];
        }

        $history = Message::where('chat_room_id', $request->chat_room_id)->orderBy('id', 'desc')->limit(10)->get()->reverse()->map(function($query){
            return [
                'role' => $query->role,
                'content' => $query->message
            ];
        })->values();
        
        $message = Message::create([
            'chat_room_id' => $request->chat_room_id,
            'role' => 'user',
            'message' => $request->message
        ]);

        $arrayMessage = [
            'role' => $message->role,
            'content' => $message->message
        ];

        $toolRunning = false;
        $toolFinished = false;
        $toolBroadcasted = false;
        $buffer = '';
        $fullText = "";
        $fullThink = "";
        $documents = [];
        $images = [];
        if($request->hasFile('documents')){
            foreach($request->file('documents') as $index => $document){
                $extension = $document->getClientOriginalExtension();
                $fileName = "doc_" . time() . ($index + 1) . '.' . $extension;
                $filePath = $document->storeAs('docs/chat_' . $request->chat_room_id,$fileName,'public');

                $doc = Document::create([
                    'chat_room_id' => $request->chat_room_id,
                    'message_id' => $message->id,
                    'file_name' => $fileName,
                    'file_path' => $filePath,
                    'file_type' => $extension
                ]);

                $documents[] = [
                    'id' => $doc->id,
                    'extension' => $extension,
                    'file_name' => $fileName,
                    // 'file_path' => $filePath
                    'file_path' => storage_path('app/public/' . $filePath)
                ];
            }
        }

        if($request->hasFile('images')){
            foreach($request->file('images') as $index => $image){
                $imageName = "image_" . time() . ($index + 1) . $image->getClientOriginalExtension();
                $imagePath = $image->storeAs('images/chat_' . $request->chat_room_id,$imageName,'public');
                $fileContent = Storage::disk('public')->get($imagePath);
                $base64Image = base64_encode($fileContent);
                $images[] = $base64Image;

                ChatImage::create([
                    'chat_room_id' => $request->chat_room_id,
                    'message_id' => $message->id,
                    'image_path' => $imagePath
                ]);
            }

            $arrayMessage['images'] = $images;
        }

        $history[] = $arrayMessage;
        $isUploadDocument = Document::where('chat_room_id', $request->chat_room_id)->exists();
        $message->load('chatImage','document');
        broadcast(new ChatUpdate($message, 'create', $request->chat_room_id));

        try{
            $response = Http::withOptions([
                'stream' => true
            ])->withHeaders([
                'kwanzx-key' => "kwanzxx-arsalfrlh"
            ])->timeout(300)->post("http://127.0.0.1:8001/chat",[
                'chat_room_id' => $request->chat_room_id,
                'is_upload_document' => $isUploadDocument,
                'documents' => $documents,
                'images' => $images,
                'messages' => $history
            ]);

            $body = $response->toPsrResponse()->getBody();
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
                    $think = $data['message']['thinking'] ?? '';
                    if (!empty($data['message']['tool_calls'] ?? [])) {
                        $toolRunning = true;
                        foreach ($data['message']['tool_calls'] as $tool) {
                            $toolName = match ($tool['function']['name']) {
                                "search_uploaded_document" => "Membaca Dokumen",
                                "search_web" => "Searching Web",
                                default => $tool['function']['name']
                            };

                            if (!$toolBroadcasted) {
                                broadcast(new ToolsEvent($toolName,$request->chat_room_id));
                                $toolBroadcasted = true;
                            }
                        }
                    }

                    $done = $data['done'] ?? false;
                    if ($toolRunning && !$toolFinished && !$done && empty($data['message']['tool_calls'])) {
                        $toolFinished = true;
                        broadcast(new ToolsEvent(null,$request->chat_room_id));
                    }
                    $fullText .= $chunk;
                    $fullThink .= $think;
                    if ($toolRunning && !$toolFinished && $done) {
                        $done = false;
                    }
                    broadcast(new AIResponse($chunk, $done, $request->chat_room_id));
                }
            }

            $messageAssistant = Message::create([
                'chat_room_id' => $request->chat_room_id,
                'role' => 'assistant',
                'message' => $fullText
            ]);
            broadcast(new ChatUpdate($messageAssistant, 'create', $request->chat_room_id));

            return [
                'message' => "Pesan berhasil dikirim",
                'success' => true,
                'status_code' => 201,
                'data' => $messageAssistant
            ];
        }catch(Exception $e){
            return [
                'message' => $e->getMessage(),
                'success' => false,
                'status_code' => 500,
            ];
        }
    }
}