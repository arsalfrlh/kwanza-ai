<?php

namespace App\Http\Controllers;

use App\Http\Requests\SendMessageRequest;
use App\Services\ConversationService;
use Illuminate\Http\Request;

class ConversationApiController extends Controller
{
    protected $conversationService;
    public function __construct(ConversationService $conversationService)
    {
        $this->conversationService = $conversationService;
    }

    public function index(Request $request){
        $data = $this->conversationService->getAllConversation($request);
        return response()->json($data, $data['status_code']);
    }

    public function update(Request $request, $title){
        $data = $this->conversationService->createNewConversation($request, $title);
        return response()->json($data, $data['status_code']);
    }

    public function show(Request $request, $id){
        $data = $this->conversationService->getAllMessage($request, $id);
        return response()->json($data, $data['status_code']);
    }

    public function store(SendMessageRequest $sendMessageRequest){
        $data = $this->conversationService->sendMessage($sendMessageRequest);
        return response()->json($data, $data['status_code']);
    }
}
