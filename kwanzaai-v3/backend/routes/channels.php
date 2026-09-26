<?php

use App\Models\Conversation;
use Illuminate\Support\Facades\Broadcast;

Broadcast::channel('conversation-room-{id}', function ($user, $id) {
    return Conversation::where('user_id', $user->id)->where('id', $id)->exists();
});
