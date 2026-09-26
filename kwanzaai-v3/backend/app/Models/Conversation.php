<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Table;
use Illuminate\Database\Eloquent\Model;
#[Table("conversations")]
#[Fillable(['user_id','title'])]

class Conversation extends Model
{
    function documents(){
        return $this->hasMany(AiDocument::class,'conversation_id');
    }

    function images(){
        return $this->hasMany(AiImage::class,'conversation_id');
    }
}
