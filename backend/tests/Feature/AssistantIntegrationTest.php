<?php

namespace Tests\Feature;

use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class AssistantIntegrationTest extends TestCase
{
    /**
     * Test assistant explains the Money Alert (fake MoMo reversal scam) accurately.
     */
    public function test_assistant_explains_money_alert(): void
    {
        Config::set('services.gemini.enabled', false);

        $response = $this->postJson('/api/v1/assistant/chat', [
            'query' => 'Tell me more about the Money alert',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'is_security_topic' => true,
            ]);

        $answer = $response->json('answer');
        $this->assertStringContainsString('Money Alert', $answer);
        $this->assertStringContainsString('reversal', $answer);
        $this->assertStringContainsString('*115#', $answer);
    }

    /**
     * Test assistant rejects off-topic queries per strict operational guardrails.
     */
    public function test_assistant_rejects_off_topic_query(): void
    {
        $response = $this->postJson('/api/v1/assistant/chat', [
            'query' => 'What is the recipe for baking a chocolate cake?',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'is_security_topic' => false,
            ]);

        $answer = $response->json('answer');
        $this->assertStringContainsString("strictly specialized in mobile financial fraud prevention", $answer);
    }

    /**
     * Test assistant calls Gemini API when available.
     */
    public function test_assistant_calls_gemini_api_when_enabled(): void
    {
        Config::set('services.gemini.enabled', true);
        Config::set('services.gemini.api_key', 'test_key_for_assistant');

        Http::fake([
            'generativelanguage.googleapis.com/*' => Http::response([
                'candidates' => [
                    [
                        'content' => [
                            'parts' => [
                                [
                                    'text' => json_encode([
                                        'is_security_topic' => true,
                                        'answer' => 'The Money Alert indicates a fake Airtel or MTN reversal message where scammers fabricate an accidental transfer and threaten police arrest.',
                                        'suggested_followups' => [
                                            'How do I verify on USSD *115#?',
                                            'How to block the scammer?',
                                        ],
                                    ]),
                                ],
                            ],
                        ],
                    ],
                ],
            ], 200),
        ]);

        $response = $this->postJson('/api/v1/assistant/chat', [
            'query' => 'Tell me more about the Money alert',
            'context_alerts' => [
                'Money alert: Fake Airtel reversal of K850 with aggressive police threat',
            ],
        ]);

        $response->assertStatus(200);
        $this->assertEquals('gemini_ai', $response->json('source'));
        $this->assertStringContainsString('The Money Alert indicates a fake Airtel', $response->json('answer'));
        $this->assertCount(2, $response->json('suggested_followups'));

        Http::assertSent(function ($request) {
            $body = $request->body();
            return str_contains($body, 'Tell me more about the Money alert') &&
                   str_contains($body, 'STRICT OPERATIONAL GUARDRAILS');
        });
    }

    /**
     * Test assistant validates input constraints.
     */
    public function test_assistant_validates_query_constraints(): void
    {
        $response = $this->postJson('/api/v1/assistant/chat', [
            'query' => 'a', // Too short (min: 2)
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['query']);
    }
}
