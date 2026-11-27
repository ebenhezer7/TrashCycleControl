<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ResolveActionRequest extends FormRequest
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
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'device_id' => 'required|exists:devices,id',
            'action_text' => 'required|string',
        ];
    }

    /**
     * Custom validation error messages.
     */
    public function messages(): array
    {
        return [
            'device_id.required' => 'ID Perangkat wajib diisi.',
            'device_id.exists' => 'Perangkat daur ulang tidak ditemukan.',
            'action_text.required' => 'Deskripsi tindakan wajib diisi.',
        ];
    }
}
