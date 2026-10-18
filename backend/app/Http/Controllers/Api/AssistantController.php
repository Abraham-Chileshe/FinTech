<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\AskAssistantRequest;
use App\Services\AI\AssistantService;
use Illuminate\Http\JsonResponse;

class AssistantController extends Controller
{
    public function __construct(
        protected AssistantService $assistantService
    ) {}

    /**
     * Ask the Munda AI Security Assistant about financial fraud or detected alerts.
     *
     * @param AskAssistantRequest $request
     * @return JsonResponse
     */
    public function chat(AskAssistantRequest $request): JsonResponse
    {
        $validated = $request->validated();
        $query = $validated['query'];
        $contextAlerts = $validated['context_alerts'] ?? [];

        $response = $this->assistantService->ask(
            query: $query,
            contextAlerts: $contextAlerts
        );

        return response()->json([
            'success' => true,
            'query' => $query,
            'answer' => $response['answer'],
            'is_security_topic' => $response['is_security_topic'],
            'suggested_followups' => $response['suggested_followups'],
            'source' => $response['source'],
        ], 200);
    }
}
