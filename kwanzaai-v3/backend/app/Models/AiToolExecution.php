<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Table;
use Illuminate\Database\Eloquent\Model;
use Override;

#[Table("ai_tool_executions")]
#[Fillable(['conversation_id','message_id','tool_name','arguments','result'])]

class AiToolExecution extends Model
{
    #[Override]
    protected function casts()
    {
        return [
            'arguments' => 'array',
            'result' => 'array'
        ];
    }
}
