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

class ConversationUpdate implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;
    protected $message;
    protected $conversationId;
    protected $action;

    /**
     * Create a new event instance.
     */
    public function __construct($message, $conversationId, $action)
    {
        $this->message = $message;
        $this->conversationId = $conversationId;
        $this->action = $action;
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
        return "conversationUpdate";
    }

    public function broadcastWith(){
        return [
            'message' => $this->message,
            'action' => $this->action
        ];
    }
}
