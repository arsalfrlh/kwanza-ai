<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ChatImage extends Model
{
    protected $table = "chat_images";
    protected $fillable = ['chat_room_id','message_id','image_path'];
}
