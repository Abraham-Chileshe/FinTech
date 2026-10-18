<?php

use App\Http\Controllers\Api\AssistantController;
use App\Http\Controllers\Api\FraudAnalysisController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes for Munda AI Fraud Shield
|--------------------------------------------------------------------------
*/

Route::get('/health', [FraudAnalysisController::class, 'health']);

// Rate-limited security endpoints
Route::middleware('throttle:60,1')->group(function () {
    Route::post('/v1/analyze-sms', [FraudAnalysisController::class, 'analyze']);
    Route::post('/v1/analyze', [FraudAnalysisController::class, 'analyze']);
    Route::post('/analyze', [FraudAnalysisController::class, 'analyze']);

    // Munda AI Security Assistant chat
    Route::post('/v1/assistant/chat', [AssistantController::class, 'chat']);
    Route::post('/assistant/chat', [AssistantController::class, 'chat']);
});
