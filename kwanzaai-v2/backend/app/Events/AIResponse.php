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

class AIResponse implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;
    protected $chunk;
    protected $done;
    protected $chatRoomId;

    /**
     * Create a new event instance.
     */
    public function __construct($chunk, $done, $chatRoomId)
    {
        $this->chunk = $chunk;
        $this->done = $done;
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
        return "aiResponse";
    }

    public function broadcastWith(){
        return [
            'chunk' => $this->chunk,
            'done' => $this->done
        ];
    }
}
