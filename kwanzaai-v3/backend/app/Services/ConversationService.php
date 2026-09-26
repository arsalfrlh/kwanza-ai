<?php
namespace App\Services;

use App\Events\ConversationUpdate;
use App\Events\StreamingUpdate;
use App\Events\ToolCalling;
use App\Models\AiDocument;
use App\Models\AiImage;
use App\Models\AiMessage;
use App\Models\AiToolExecution;
use App\Models\Conversation;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Storage;

class ConversationService
{
    protected $aiApiKey;
    protected $aiBaseUrl;

    public function __construct()
    {
        $this->aiApiKey = config('ai.ai_api_key');
        $this->aiBaseUrl = config('ai.ai_base_url');
    }

    public function getAllConversation(Request $request){
        $user = $request->user();
        $data = Conversation::where('user_id', $user->id)->get();
        return [
            'message' => "Menampilkan semua conversation",
            'success' => true,
            'status_code' => 200,
            'data' => $data
        ];
    }

    public function createNewConversation(Request $request, $title){
        $user = $request->user();
        $data = Conversation::create([
            'user_id' => $user->id,
            'title' => $title
        ]);

        return [
            'message' => "Conversation berhasil dibuat",
            'success' => true,
            'status_code' => 201,
            'data' => $data
        ];
    }

    public function getAllMessage(Request $request, $conversationId){
        $user = $request->user();
        $conversation = Conversation::where('user_id', $user->id)->findOrFail($conversationId);
        $data = AiMessage::with('documents','images')->where('conversation_id', $conversation->id)->whereIn('role',['user','assistant'])->where('type','text')->get();
        return [
            'message' => "Menampilkan semua chat",
            'success' => true,
            'status_code' => 200,
            'data' => $data
        ];
    }

    public function sendMessage(Request $request){
        $user = $request->user();
        if(!Conversation::where('user_id', $user->id)->where('id', $request->conversation_id)->exists()){
            return [
                'message' => "Conversation tidak ditemukan",
                'success' => false,
                'status_code' => 404
            ];
        }

        $buffer = '';
        $fullText = "";
        $fullThink = "";
        $documents = [];
        $history = AiMessage::with('documents','images')->where('conversation_id', $request->conversation_id)->orderBy('id','desc')->limit(20)->get()->reverse()->map(function(AiMessage $query){
            return $this->builMessageAi($query);
        })->values()->toArray();
        // dd($history);

        $message = AiMessage::create([
            'conversation_id' => $request->conversation_id,
            'role' => 'user',
            'message' => $request->message,
            'type' => 'text'
        ]);
        
        if($request->hasFile('uploaded_files')){
            foreach($request->file('uploaded_files') as $index => $file){
                $extension = $file->getClientOriginalExtension();
                if(in_array($extension, ['png','jpeg','jpg'])){
                    $nmimage = "image_" . time() . ($index + 1) . '.' . $extension;
                    $imagePath = $file->storeAs('images/conversation_' . $message->conversation_id, $nmimage, 'public');

                    AiImage::create([
                        'conversation_id' => $message->conversation_id,
                        'message_id' => $message->id,
                        'image_path' => $imagePath
                    ]);
                }else if(in_array($extension, ['pdf','docx','json','txt'])){
                    $nmdocument = "document_" . time() . ($index + 1) . '.' . $extension;
                    $documentPath = $file->storeAs('documents/conversation_' . $message->conversation_id, $nmdocument, 'public');
                    $document = AiDocument::create([
                        'conversation_id' => $message->conversation_id,
                        'message_id' => $message->id,
                        'original_file_name' => $file->getClientOriginalName(),
                        'file_name' => $nmdocument,
                        'file_type' => $extension,
                        'file_path' => $documentPath
                    ]);

                    $documents[] = [
                        'document_id' => $document->id,
                        'conversation_id' => $document->conversation_id,
                        'message_id' => $document->message_id,
                        'original_file_name' => $document->original_file_name,
                        'file_name' => $document->file_name,
                        'file_type' => $document->file_type,
                        'file_path' => storage_path('app/public/' . $documentPath)
                    ];
                }
            }
        }

        $message->load('documents','images');
        broadcast(new ConversationUpdate($message, $message->conversation_id, 'create'));
        $history[] = $this->builMessageAi($message);

        try{
            $response = Http::timeout(600)->withOptions([
                'stream' => true
            ])->withHeaders([
                'kwanzx-key' => $this->aiApiKey
            ])->post($this->aiBaseUrl . '/chat', [
                'conversation_id' => $message->conversation_id,
                'documents' => $documents,
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
                    $role = $data['message']['role'] ?? "assistant";
                    $content = $data['message']['content'] ?? '';
                    $think = $data['message']['thinking'] ?? '';
                    $isDone = $data['message']['done'] ?? false;
                    $toolName = $data['message']['tool_name'] ?? null;
                    $toolDisplayName = $data['message']['tool_display_name'] ?? null;
                    $arguments = $data['message']['arguments'] ?? null;
                    $toolCalls = $data['message']['tool_calls'] ?? null;
                    if(!is_null($toolCalls) && !empty($toolCalls)){
                        AiMessage::create([
                            'conversation_id' => $request->conversation_id,
                            'role' => 'assistant',
                            'message' => null,
                            'type' => 'tool_call',
                            // 'tool_calls' => json_encode($toolCalls)
                            'tool_calls' => $toolCalls //karena di model sudah casts array maka tidak perlu encode
                        ]);
                    }
                    if($role == "assistant"){
                        $fullText .= $content;
                        $fullThink .= $think;
                        broadcast(new StreamingUpdate($content, $isDone, $message->conversation_id));
                    }else if($role == "tool"){
                        if(!is_null($toolName) && !empty($content)){
                            $messageTool = AiMessage::create([
                                'conversation_id' => $request->conversation_id,
                                'role' => 'tool',
                                'message' => $content,
                                'type' => 'tool_result',
                                'tool_name' => $toolName
                            ]);

                            AiToolExecution::create([
                                'conversation_id' => $request->conversation_id,
                                'message_id' => $messageTool->id,
                                'tool_name' => $toolName,
                                'arguments' => $arguments,
                                'result' => json_decode($content, true)
                            ]);
                        }
                        broadcast(new ToolCalling($toolDisplayName, $message->conversation_id));
                    }
                }
            }

            $assistantMessage = AiMessage::create([
                'conversation_id' => $request->conversation_id,
                'role' => 'assistant',
                'message' => $fullText,
                'type' => 'text'
            ]);
            broadcast(new ConversationUpdate($assistantMessage, $assistantMessage->conversation_id, 'create'));
            return [
                'message' => "Pesan berhasil dikirim",
                'success' => true,
                'status_code' => 201,
                'data' => $assistantMessage
            ];
        }catch(Exception $e){
            return [
                'message' => $e->getMessage(),
                'success' => false,
                'status_code' => 500
            ];
        }
    }

    private function builMessageAi(AiMessage $aiMessage){
        $message = [
            'role' => $aiMessage->role,
            'content' => $aiMessage->message ?? ""
        ];
        if($aiMessage->role == "assistant" && !is_null($aiMessage->tool_calls)){
            $message['tool_calls'] = $aiMessage->tool_calls;
        }
        if($aiMessage->role == "tool" && !is_null($aiMessage->tool_name)){
            $message['tool_name'] = $aiMessage->tool_name;
        }

        if($aiMessage->documents->isNotEmpty()){
            $message['content'] .= "\n CONVERSATION CONTEXT\n";
            foreach($aiMessage->documents as $document){
                $message['content'] .= "[UPLOADED FILE] {$document->original_file_name}\n";
            }
        }

        if($aiMessage->images->isNotEmpty()){
            $images = [];
            foreach($aiMessage->images as $image){
                $imagesContent = Storage::disk('public')->get($image->image_path);
                $images[] = base64_encode($imagesContent);
            }
            $message['images'] = $images;
        }
        return $message;
    }
}