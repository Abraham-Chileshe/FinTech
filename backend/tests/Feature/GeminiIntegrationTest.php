<?php

namespace Tests\Feature;

use App\Services\AI\GeminiService;
use App\Services\FraudDetection\FraudRulesEngine;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class GeminiIntegrationTest extends TestCase
{
    /**
     * Test GeminiService reports unavailable when key is missing or disabled.
     */
    public function test_gemini_service_unavailable_when_disabled(): void
    {
        Config::set('services.gemini.enabled', false);
        Config::set('services.gemini.api_key', null);

        $service = new GeminiService();
        $this->assertFalse($service->isAvailable());
        $this->assertNull($service->analyze('Any message'));
    }

    /**
     * Test API seamlessly falls back to rules engine when Gemini is offline.
     */
    public function test_api_falls_back_to_rules_when_gemini_disabled(): void
    {
        Config::set('services.gemini.enabled', false);

        $response = $this->postJson('/api/v1/analyze-sms', [
            'message' => 'ZANACO-AUTH: OTP 849201 for K1,200 payment. Read out code to agent.',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'risk_band' => FraudRulesEngine::BAND_HIGH,
                'analysis_method' => 'deterministic_rules_engine',
            ]);
    }

    /**
     * Test successful Gemini API mock integration and hybrid synthesis.
     */
    public function test_hybrid_synthesis_with_mocked_gemini_api(): void
    {
        Config::set('services.gemini.enabled', true);
        Config::set('services.gemini.api_key', 'test_dummy_key_12345');

        Http::fake([
            'generativelanguage.googleapis.com/*' => Http::response([
                'candidates' => [
                    [
                        'content' => [
                            'parts' => [
                                [
                                    'text' => json_encode([
                                        'ai_risk_assessment' => 'high',
                                        'ai_confidence' => 0.95,
                                        'context_explanation' => 'The message mimics a Mobile Money dispute to extract an unauthorized transfer under duress.',
                                        'detected_tactics' => [
                                            'Psychological intimidation using police threats',
                                            'Manufactured time pressure',
                                        ],
                                        'safe_advice' => [
                                            'Verify balance exclusively on USSD *115#',
                                            'Block sender number',
                                        ],
                                    ]),
                                ],
                            ],
                        ],
                    ],
                ],
            ], 200),
        ]);

        $response = $this->postJson('/api/v1/analyze-sms', [
            'message' => 'Sent K850 by mistake to your number! Please refund quickly or police.',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'risk_band' => FraudRulesEngine::BAND_HIGH,
                'analysis_method' => 'hybrid_rules_and_gemini_ai',
            ]);

        $reasons = implode(' ', $response->json('reasons'));
        $this->assertStringContainsString('AI Context Signal:', $reasons);
        $this->assertStringContainsString('Psychological intimidation', $reasons);

        $summary = $response->json('summary');
        $this->assertStringContainsString('mimics a Mobile Money dispute', $summary);
    }

    /**
     * Test Safety Floor: AI CANNOT downgrade a high-risk rule match.
     */
    public function test_ai_cannot_downgrade_high_risk_safety_floor(): void
    {
        Config::set('services.gemini.enabled', true);
        Config::set('services.gemini.api_key', 'test_dummy_key_12345');

        // AI incorrectly claims an OTP solicitation is "low" risk
        Http::fake([
            'generativelanguage.googleapis.com/*' => Http::response([
                'candidates' => [
                    [
                        'content' => [
                            'parts' => [
                                [
                                    'text' => json_encode([
                                        'ai_risk_assessment' => 'low',
                                        'ai_confidence' => 0.99,
                                        'context_explanation' => 'AI hallucination claiming message is harmless.',
                                        'detected_tactics' => [],
                                        'safe_advice' => ['Follow prompt'],
                                    ]),
                                ],
                            ],
                        ],
                    ],
                ],
            ], 200),
        ]);

        $response = $this->postJson('/api/v1/analyze-sms', [
            'message' => 'ZANACO-AUTH: OTP 849201 for K1,200 payment. Read out code to agent.',
        ]);

        // Must remain HIGH risk despite AI's hallucinated "low"
        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'risk_band' => FraudRulesEngine::BAND_HIGH,
            ]);

        $this->assertGreaterThanOrEqual(75, $response->json('risk_score'));
    }

    /**
     * Test Gemini timeout or failure automatically falls back to deterministic rules.
     */
    public function test_gemini_http_failure_falls_back_gracefully(): void
    {
        Config::set('services.gemini.enabled', true);
        Config::set('services.gemini.api_key', 'test_dummy_key_12345');

        Http::fake([
            'generativelanguage.googleapis.com/*' => Http::response('Internal Server Error', 500),
        ]);

        $response = $this->postJson('/api/v1/analyze-sms', [
            'message' => 'ABSA-ALERTS: Account temporarily suspended. Visit http://bit.ly/absa-kyc',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'risk_band' => FraudRulesEngine::BAND_HIGH,
                'analysis_method' => 'deterministic_rules_engine',
            ]);
    }
}
