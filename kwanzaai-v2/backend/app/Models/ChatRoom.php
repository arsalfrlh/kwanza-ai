<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ChatRoom extends Model
{
    protected $table = "chat_rooms";
    protected $fillable = ['user_id','title'];

    function message(){
        return $this->hasMany(Message::class,'chat_room_id');
    }

    function chatImage(){
        return $this->hasMany(ChatImage::class,'chat_room_id');
    }

    function document(){
        return $this->hasMany(Document::class,'chat_room_id');
    }
}
