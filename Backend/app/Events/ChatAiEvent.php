<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class ChatAiEvent implements ShouldBroadcast, ShouldQueue
{
    use Dispatchable, InteractsWithSockets, SerializesModels;
    protected $chatRoomId;
    protected $chunk;
    protected $isDone;

    /**
     * Create a new event instance.
     */
    public function __construct($chatRoomId, $chunk, $isDone = false)
    {
        $this->chatRoomId = $chatRoomId;
        $this->chunk = $chunk;
        $this->isDone = $isDone;
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
        return "chatAiUpdate";
    }

    public function broadcastWith(){
        return [
            'chunk' => $this->chunk,
            'is_done' => $this->isDone
        ];
    }
}
