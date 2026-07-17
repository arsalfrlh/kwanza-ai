<?php

namespace App\Http\Requests;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class SendMessageRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'message' => 'required',
            'chat_room_id' => 'required',
            'documents' => 'nullable',
            'images' => 'nullable',
            'documents.*' => 'file|mimes:pdf,docx,txt,json,',
            'images.*' => 'image|mimes:jpg,jpeg,png'
        ];
    }
}
