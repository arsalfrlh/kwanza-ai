<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Table;
use Illuminate\Database\Eloquent\Model;
#[Table("ai_documents")]
#[Fillable(['conversation_id','message_id','original_file_name','file_name','file_type','file_path'])]

class AiDocument extends Model
{
    //
}
