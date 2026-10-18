<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\AnalyzeSmsRequest;
use App\Services\AI\GeminiService;
use App\Services\FraudDetection\FraudRulesEngine;
use App\Services\Security\PiiAnonymizerService;
use Illuminate\Http\JsonResponse;

class FraudAnalysisController extends Controller
{
    public function __construct(
        protected FraudRulesEngine $rulesEngine,
        protected GeminiService $geminiService,
        protected PiiAnonymizerService $piiService
    ) {}

    /**
     * Analyze an SMS message using a robust hybrid of deterministic rules & Google Gemini.
     *
     * @param AnalyzeSmsRequest $request
     * @return JsonResponse
     */
    public function analyze(AnalyzeSmsRequest $request): JsonResponse
    {
        $validated = $request->validated();
        $message = $validated['message'];
        $demoMode = (bool) ($validated['demo_mode'] ?? false);

        // 1. Layer A: Deterministic Rules Engine (Evaluates baseline threat triggers)
        $rulesResult = $this->rulesEngine->evaluate(
            message: $message,
            demoMode: $demoMode
        );

        // 2. Privacy Anonymization: Redact sensitive customer PII before sending outside
        // (Complies with Zambia Data Protection Act No. 3 of 2021)
        $piiResult = $this->piiService->redact($message);

        // 3. Layer B: Google Gemini AI Context Analysis (Receives strictly PII-redacted text)
        $aiResult = null;
        if ($this->geminiService->isAvailable()) {
            $aiResult = $this->geminiService->analyze($piiResult['redacted_text']);
        }

        // 4. Layer C: Hybrid Decision Synthesis & Validation
        $finalResult = $this->synthesizeHybridAssessment($rulesResult, $aiResult);

        // Attach zero-knowledge privacy metadata
        $finalResult['privacy_protection'] = [
            'pii_redacted' => $piiResult['pii_count'] > 0,
            'redacted_elements_count' => $piiResult['pii_count'],
            'detected_types' => $piiResult['detected_types'],
        ];

        return response()->json($finalResult, 200);
    }

    /**
     * Synthesize rules engine signals and Gemini AI context using documented safety logic.
     *
     * Documented Decision Rules:
     * 1. Safety Floor: Deterministic rules engine sets the mandatory minimum threat level.
     *    An AI assessment CANNOT downgrade a 'high' risk rating established by critical rule matches.
     * 2. Threat Escalation: If rules identify low/suspicious, but AI identifies subtle deception with
     *    confidence >= 0.70, the final risk score is elevated to suspicious or high.
     * 3. Explanatory Enrichment: AI context explanation enriches the plain-language summary.
     * 4. Actions Merging: Safety recommendations from both layers are deduplicated.
     * 5. Graceful Fallback: If AI is offline, timed out, or unconfigured, rules result is returned intact.
     */
    protected function synthesizeHybridAssessment(array $rulesResult, ?array $aiResult): array
    {
        if ($aiResult === null) {
            // Pure deterministic rules engine response (offline or AI unavailable)
            return $rulesResult;
        }

        $rulesBand = $rulesResult['risk_band'];
        $rulesScore = $rulesResult['risk_score'];
        $aiBand = $aiResult['ai_risk_assessment'];
        $aiConfidence = $aiResult['ai_confidence'];

        $finalScore = $rulesScore;
        $finalBand = $rulesBand;

        // Apply Rule 1: High-risk safety floor
        if ($rulesBand === FraudRulesEngine::BAND_HIGH) {
            $finalBand = FraudRulesEngine::BAND_HIGH;
            $finalScore = max(75, $rulesScore);
        } elseif ($aiBand === 'high' && $aiConfidence >= 0.70) {
            // Apply Rule 2: Escalation to High Risk via AI discovery
            $finalBand = FraudRulesEngine::BAND_HIGH;
            $finalScore = max(75, $rulesScore + 30);
        } elseif ($aiBand === 'suspicious' && $rulesBand === FraudRulesEngine::BAND_LOW) {
            // Escalation to Suspicious via AI discovery
            $finalBand = FraudRulesEngine::BAND_SUSPICIOUS;
            $finalScore = max(45, $rulesScore + 20);
        }

        $finalScore = min(99, $finalScore);

        // Merge and deduplicate reasons/tactics
        $reasons = $rulesResult['reasons'];
        if (!empty($aiResult['detected_tactics'])) {
            foreach ($aiResult['detected_tactics'] as $tactic) {
                $reasons[] = "AI Context Signal: " . $tactic;
            }
        }

        // Merge and deduplicate actions
        $actions = array_merge($rulesResult['recommended_actions'], $aiResult['safe_advice'] ?? []);

        // Enrich summary with AI explanation
        $summary = $rulesResult['summary'];
        if (!empty($aiResult['context_explanation'])) {
            $summary .= " " . $aiResult['context_explanation'];
        }

        return [
            'success' => true,
            'risk_band' => $finalBand,
            'risk_score' => $finalScore,
            'summary' => trim($summary),
            'reasons' => array_values(array_unique($reasons)),
            'recommended_actions' => array_values(array_unique($actions)),
            'analysis_method' => 'hybrid_rules_and_gemini_ai',
            'disclaimer' => $rulesResult['disclaimer'],
        ];
    }

    /**
     * API health check endpoint.
     *
     * @return JsonResponse
     */
    public function health(): JsonResponse
    {
        return response()->json([
            'status' => 'operational',
            'service' => 'Munda AI Fraud Shield API',
            'version' => '1.0.0',
            'rules_engine' => 'active',
            'gemini_ai_configured' => $this->geminiService->isAvailable(),
            'timestamp' => now()->toIso8601String(),
        ], 200);
    }
}
