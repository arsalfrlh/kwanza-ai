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

class ToolsEvent implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;
    protected $toolName;
    protected $chatRoomId;

    /**
     * Create a new event instance.
     */
    public function __construct($toolName, $chatRoomId)
    {
        $this->toolName = $toolName;
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
        return "toolsUpdate";
    }

    public function broadcastWith(){
        return [
            'tool_name' => $this->toolName
        ];
    }
}
