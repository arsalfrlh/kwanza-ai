<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class ChatUpdate implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;
    protected $message;
    protected $action;
    protected $chatRoomId;

    /**
     * Create a new event instance.
     */
    public function __construct($message, $action, $chatRoomId)
    {
        $this->message = $message;
        $this->action = $action;
        $this->chatRoomId = $chatRoomId;
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return array<int, Channel>
     */
    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('chat-room-' . $this->chatRoomId),
        ];
    }

    public function broadcastAs(){
        return "chatUpdate";
    }

    public function broadcastWith(){
        return [
            'message' => $this->message,
            'action' => $this->action
        ];
    }
}
