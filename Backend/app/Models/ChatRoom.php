<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ChatRoom extends Model
{
    protected $table = "chat_room";
    protected $fillable = ['chat_name','user_id'];
}
