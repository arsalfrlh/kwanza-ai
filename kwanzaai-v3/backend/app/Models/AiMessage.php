<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Table;
use Illuminate\Database\Eloquent\Model;
use Override;

#[Table("ai_messages")]
#[Fillable(['conversation_id','role','message','type','tool_name','tool_calls'])]

class AiMessage extends Model
{
    function documents(){
        return $this->hasMany(AiDocument::class,'message_id');
    }

    function images(){
        return $this->hasMany(AiImage::class,'message_id');
    }

    #[Override]
    protected function casts()
    {
        return [
            'tool_calls' => 'array'
        ];
    }
}
