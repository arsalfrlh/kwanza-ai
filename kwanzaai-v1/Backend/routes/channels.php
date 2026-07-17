<?php

use App\Models\ChatRoom;
use Illuminate\Support\Facades\Broadcast;

Broadcast::channel('chat-room-{id}', function ($user, $id) {
    return ChatRoom::where('user_id', $user->id)->where('id', $id)->exists();
});
