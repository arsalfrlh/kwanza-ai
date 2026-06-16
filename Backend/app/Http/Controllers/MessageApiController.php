<?php

namespace App\Http\Controllers;

use App\Http\Requests\CreatNewRoomRequest;
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
        $data = $this->messageService->index($request);
        return response()->json($data, $data['status_code']);
    }

    public function show(Request $request, $id){
        $data = $this->messageService->show($request, $id);
        return response()->json($data, $data['status_code']);
    }

    public function store(CreatNewRoomRequest $creatNewRoomRequest){
        $data = $this->messageService->store($creatNewRoomRequest);
        return response()->json($data, $data['status_code']);
    }

    public function update(SendMessageRequest $sendMessageRequest, $id){
        $data = $this->messageService->update($sendMessageRequest, $id);
        return response()->json($data, $data['status_code']);
    }
}
