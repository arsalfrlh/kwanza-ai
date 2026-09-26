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

class ToolCalling implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;
    protected $toolName;
    protected $conversationId;

    /**
     * Create a new event instance.
     */
    public function __construct($toolName, $conversationId)
    {
        $this->toolName = $toolName;
        $this->conversationId = $conversationId;
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return array<int, Channel>
     */
    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('conversation-room-' . $this->conversationId),
        ];
    }

    public function broadcastAs(){
        return "toolUpdate";
    }

    public function broadcastWith(){
        return [
            'tool_name' => $this->toolName
        ];
    }
}
