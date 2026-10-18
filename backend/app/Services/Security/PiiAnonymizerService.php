<?php

namespace App\Services\Security;

class PiiAnonymizerService
{
    /**
     * Anonymize Personally Identifiable Information (PII) from SMS text before passing to external AI APIs.
     * Complies with Zambian Data Protection Act No. 3 of 2021 and international privacy safeguards.
     *
     * @param string $text
     * @return array{redacted_text: string, detected_types: array<string>, pii_count: int}
     */
    public function redact(string $text): array
    {
        $detectedTypes = [];
        $redacted = $text;
        $totalCount = 0;

        // 1. Zambian National Registration Card (NRC) Numbers (Format: 123456/12/1 or 123456/78/1)
        $nrcPattern = '/\b\d{6}\/\d{2}\/[1-2]\b/';
        $redacted = preg_replace_callback($nrcPattern, function ($matches) use (&$detectedTypes, &$totalCount) {
            $detectedTypes['nrc'] = 'Zambian National Registration Card (NRC)';
            $totalCount++;
            return '[NRC_REDACTED]';
        }, $redacted);

        // 2. Zambian Mobile Numbers (+260 9x/7x or 09x/07x with optional country code & spacing)
        // Telecom prefixes: Airtel (097, 077), MTN (096, 076), Zamtel (095, 075)
        $phonePattern = '/(?:\+260|260|0)\s*(?:9[567]|7[567])\s*\d{3}\s*\d{4}\b/';
        $redacted = preg_replace_callback($phonePattern, function ($matches) use (&$detectedTypes, &$totalCount) {
            $detectedTypes['phone'] = 'Zambian Mobile Phone Number';
            $totalCount++;
            return '[PHONE_REDACTED]';
        }, $redacted);

        // 3. Payment Card Numbers (13 to 19 digit credit/debit card numbers with optional spaces/hyphens)
        $cardPattern = '/\b(?:\d{4}[ -]?){3}\d{4}\b/';
        $redacted = preg_replace_callback($cardPattern, function ($matches) use (&$detectedTypes, &$totalCount) {
            $detectedTypes['card'] = 'Payment Card Number';
            $totalCount++;
            return '[CARD_REDACTED]';
        }, $redacted);

        // 4. One-Time Passwords (OTP) and PIN tokens in explicit context
        // E.g. "OTP: 482910", "code is 591823", "PIN is 1234"
        $otpPattern = '/\b(?:otp|one[- ]time[- ]password|verification code|pin|passcode|secret code)(?:\s+is|\s*:|\s*-)?\s*(\d{4,8})\b/i';
        $redacted = preg_replace_callback($otpPattern, function ($matches) use (&$detectedTypes, &$totalCount) {
            $detectedTypes['auth_code'] = 'Authentication Code / PIN';
            $totalCount++;
            // Preserve the label so fraud rules can still recognize that an OTP/PIN was solicited/mentioned
            return substr($matches[0], 0, -strlen($matches[1])) . '[CODE_REDACTED]';
        }, $redacted);

        return [
            'redacted_text' => $redacted,
            'detected_types' => array_values($detectedTypes),
            'pii_count' => $totalCount,
        ];
    }

    /**
     * Helper to obtain just the redacted text.
     */
    public function redactText(string $text): string
    {
        return $this->redact($text)['redacted_text'];
    }
}
