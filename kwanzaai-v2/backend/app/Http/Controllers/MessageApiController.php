<?php

namespace App\Http\Controllers;

use App\Http\Requests\CreateRoomRequest;
use App\Http\Requests\SendMessageRequest;
use App\Services\MessageService;
use Illuminate\Http\Request;

class MessageApiController extends Controller
{
    protected $messageService;
    public function __construct(MessageService $messageService)
    {
        $this->messageService = $messageService;
    }

    public function index(Request $request){
        $data = $this->messageService->getAllChatRoom($request);
        return response()->json($data, $data['status_code']);
    }

    public function show(Request $request, $id){
        $data = $this->messageService->getAllMessage($request, $id);
        return response()->json($data, $data['status_code']);
    }

    public function store(SendMessageRequest $sendMessageRequest){
        $data = $this->messageService->sendMessage($sendMessageRequest);
        return response()->json($data, $data['status_code']);
    }

    public function update(Request $request, $title){
        $data = $this->messageService->createNewRoom($request, $title);
        return response()->json($data, $data['status_code']);
    }
}
