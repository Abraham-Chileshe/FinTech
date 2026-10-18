<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class AnalyzeSmsRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Prepare the data for validation by sanitizing hidden unicode control characters
     * and null bytes used in evasion techniques (zero-width spaces, RTL overrides).
     */
    protected function prepareForValidation(): void
    {
        if ($this->has('message') && is_string($this->message)) {
            $sanitized = $this->message;

            // Remove null bytes
            $sanitized = str_replace(chr(0), '', $sanitized);

            // Strip Unicode invisible characters (ZWSP, ZWNJ, ZWJ, BOM)
            $sanitized = preg_replace('/[\x{200B}-\x{200D}\x{FEFF}]/u', '', $sanitized) ?? $sanitized;

            // Strip Unicode BiDi overrides (Trojan Source evasion / RTL spoofing)
            $sanitized = preg_replace('/[\x{202A}-\x{202E}\x{2066}-\x{2069}]/u', '', $sanitized) ?? $sanitized;

            $this->merge([
                'message' => trim($sanitized),
            ]);
        }
    }

    public function rules(): array
    {
        return [
            'message' => ['required', 'string', 'min:3', 'max:1000'],
            'demo_mode' => ['sometimes', 'boolean'],
            'locale' => ['sometimes', 'string', 'max:10'],
        ];
    }

    public function messages(): array
    {
        return [
            'message.required' => 'Please provide an SMS message text to analyze.',
            'message.min' => 'Message must contain at least 3 characters.',
            'message.max' => 'Message text cannot exceed 1000 characters.',
        ];
    }
}

