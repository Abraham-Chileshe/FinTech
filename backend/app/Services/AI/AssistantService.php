<?php

namespace App\Services\AI;

use App\Services\Security\PiiAnonymizerService;

class AssistantService
{
    public function __construct(
        protected GeminiService $geminiService,
        protected PiiAnonymizerService $piiService
    ) {}

    /**
     * Ask the Munda AI Security Specialist Assistant a question.
     * Strictly restricted to financial fraud and security alerts.
     *
     * @param string $query
     * @param array $contextAlerts
     * @return array{answer: string, is_security_topic: bool, suggested_followups: array<string>, source: string}
     */
    public function ask(string $query, array $contextAlerts = []): array
    {
        $trimmed = trim($query);

        // Sanitize input
        $redactedQuery = $this->piiService->redactText($trimmed);

        // Check if query is explicitly off-topic before calling AI
        if ($this->isExplicitlyOffTopic($redactedQuery)) {
            return [
                'answer' => "I am Munda Fraud Shield's AI Security Specialist. I am strictly specialized in mobile financial fraud prevention, scam analysis, and explaining security alerts in Zambia. How can I assist you with your transaction or message safety?",
                'is_security_topic' => false,
                'suggested_followups' => [
                    'Tell me more about the Money alert',
                    'How does the fake reversal scam work?',
                    'Why should I never share my OTP?',
                ],
                'source' => 'guardrail_filter',
            ];
        }

        // Try Google Gemini AI if configured and available
        if ($this->geminiService->isAvailable()) {
            $aiResponse = $this->geminiService->askAssistant($redactedQuery, $contextAlerts);
            if ($aiResponse !== null && !empty($aiResponse['answer'])) {
                return [
                    'answer' => $aiResponse['answer'],
                    'is_security_topic' => $aiResponse['is_security_topic'] ?? true,
                    'suggested_followups' => $aiResponse['suggested_followups'] ?? [
                        'Tell me more about the Money alert',
                        'How do I report a scam to ZICTA?',
                    ],
                    'source' => 'gemini_ai',
                ];
            }
        }

        // Robust Local Fallback (Domain Knowledge Engine)
        return $this->generateLocalResponse($redactedQuery, $contextAlerts);
    }

    /**
     * Detect off-topic queries to prevent AI misuse.
     */
    protected function isExplicitlyOffTopic(string $query): bool
    {
        $lower = mb_strtolower($query);

        $offTopicKeywords = [
            'weather', 'recipe', 'cook', 'bake', 'poem', 'song', 'joke', 'football',
            'premier league', 'chelsea', 'arsenal', 'manchester', 'movie', 'president',
            'who is the president', 'coding', 'python code', 'javascript code', 'write an essay',
            'homework', 'solve this math', 'capital of', 'translate to french',
        ];

        foreach ($offTopicKeywords as $keyword) {
            if (str_contains($lower, $keyword)) {
                // Ensure it's not a fraud question that happens to mention an off-topic word
                if (!str_contains($lower, 'fraud') && !str_contains($lower, 'scam') && !str_contains($lower, 'alert')) {
                    return true;
                }
            }
        }

        return false;
    }

    /**
     * Generate localized knowledge response for financial fraud queries in Zambia.
     */
    protected function generateLocalResponse(string $query, array $contextAlerts = []): array
    {
        $lower = mb_strtolower($query);

        // 1. "Money alert" / "Airtel Money alert" / Reversal scam
        if (str_contains($lower, 'money alert') || str_contains($lower, 'airtel alert') || str_contains($lower, 'reversal') || str_contains($lower, 'refund')) {
            return [
                'answer' => "The Money Alert highlights a common Mobile Money reversal scam in Zambia. A fraudster sends a fake SMS claiming they sent money (e.g. K850) by mistake, then aggressively contacts you threatening police arrest if you do not 'refund' them immediately. In reality, no money entered your account. Always verify your real balance via USSD (*115# for Airtel or *303# for MTN). Never send funds back directly.",
                'is_security_topic' => true,
                'suggested_followups' => [
                    'What should I do if a caller threatens me with police?',
                    'How do official telecom reversals work?',
                ],
                'source' => 'local_knowledge_engine',
            ];
        }

        // 2. OTP / PIN theft alert
        if (str_contains($lower, 'otp') || str_contains($lower, 'pin') || str_contains($lower, 'password') || str_contains($lower, 'verification code')) {
            return [
                'answer' => "The OTP/PIN Theft Alert warns against fraudulent messages requesting confidential security codes. Scammers pose as bank representatives or telecom agents claiming to resolve an account block or upgrade your SIM. Legitimate financial institutions like ZANACO, ABSA, Airtel, or MTN will NEVER ask for your PIN or OTP under any circumstance.",
                'is_security_topic' => true,
                'suggested_followups' => [
                    'What if I already shared my PIN by mistake?',
                    'How does SIM-swap fraud work?',
                ],
                'source' => 'local_knowledge_engine',
            ];
        }

        // 3. Bank suspension / Phishing links (ZANACO, ABSA, FNB)
        if (str_contains($lower, 'zanaco') || str_contains($lower, 'absa') || str_contains($lower, 'suspension') || str_contains($lower, 'link') || str_contains($lower, 'block')) {
            return [
                'answer' => "The Urgent Suspension Alert flags phishing attempts that threaten immediate account termination unless you tap an attached link. Clicking these links leads to spoofed banking portals designed to steal your credentials and empty your account. Bank helplines should always be contacted directly through their published numbers, never through SMS links.",
                'is_security_topic' => true,
                'suggested_followups' => [
                    'How do I spot a fake banking link?',
                    'Can I scan a suspicious SMS right now?',
                ],
                'source' => 'local_knowledge_engine',
            ];
        }

        // 4. Lottery / Prize / Customs / Grants
        if (str_contains($lower, 'prize') || str_contains($lower, 'lottery') || str_contains($lower, 'won') || str_contains($lower, 'customs') || str_contains($lower, 'grant')) {
            return [
                'answer' => "The Fake Prize & Lottery Alert warns against advance-fee scams. Scammers claim you won a large sum of money or government empowerment grant, but ask for a 'processing fee' or 'delivery fee' before release. Legitimate lotteries never require an upfront payment to claim a genuine prize.",
                'is_security_topic' => true,
                'suggested_followups' => [
                    'How do scammers get my phone number?',
                    'How do I report this number to ZICTA?',
                ],
                'source' => 'local_knowledge_engine',
            ];
        }

        // Default Security Guidance
        return [
            'answer' => "Munda AI Fraud Shield is designed to protect Zambian mobile money consumers from social engineering and SMS fraud. You can paste any suspicious SMS into the Scanner tab to inspect urgency traps, unverified links, and deceptive caller numbers.",
            'is_security_topic' => true,
            'suggested_followups' => [
                'Tell me more about the Money alert',
                'What are common Mobile Money scams in Zambia?',
                'How to report fraud to 7070?',
            ],
            'source' => 'local_knowledge_engine',
        ];
    }
}
