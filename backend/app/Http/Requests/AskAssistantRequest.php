<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class AskAssistantRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $rawQuery = $this->input('query') ?? $this->input('message');

        if (is_string($rawQuery)) {
            $sanitized = $rawQuery;

            // Remove null bytes
            $sanitized = str_replace(chr(0), '', $sanitized);

            // Strip Unicode invisible characters (ZWSP, ZWNJ, ZWJ, BOM)
            $sanitized = preg_replace('/[\x{200B}-\x{200D}\x{FEFF}]/u', '', $sanitized) ?? $sanitized;

            // Strip Unicode BiDi overrides (Trojan Source evasion / RTL spoofing)
            $sanitized = preg_replace('/[\x{202A}-\x{202E}\x{2066}-\x{2069}]/u', '', $sanitized) ?? $sanitized;

            $this->merge([
                'query' => trim($sanitized),
            ]);
        }
    }

    public function rules(): array
    {
        return [
            'query' => ['required', 'string', 'min:2', 'max:500'],
            'context_alerts' => ['sometimes', 'array'],
            'context_alerts.*' => ['string', 'max:500'],
        ];
    }

    public function messages(): array
    {
        return [
            'query.required' => 'Please ask a question or specify which fraud alert you want explained.',
            'query.min' => 'Inquiry must contain at least 2 characters.',
            'query.max' => 'Inquiry cannot exceed 500 characters.',
        ];
    }
}
