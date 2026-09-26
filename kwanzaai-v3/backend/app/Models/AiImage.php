<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Table;
use Illuminate\Database\Eloquent\Model;
#[Table("ai_images")]
#[Fillable(['conversation_id','message_id','image_path'])]

class AiImage extends Model
{
    //
}
