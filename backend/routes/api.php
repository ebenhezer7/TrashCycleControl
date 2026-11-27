<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DeviceController;
use App\Http\Controllers\Api\ProfileController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return response()->json([
        'status' => 'success',
        'data' => $request->user(),
    ]);
});

Route::prefix('v1')->group(function () {
    // Auth Routes
    Route::post('/auth/login', [AuthController::class, 'login']);

    // Device Telemetry & Action Log Routes
    Route::get('/devices', [DeviceController::class, 'index']);
    Route::post('/actions', [DeviceController::class, 'resolveAction']);

    // Protected User Profile Routes
    Route::post('/user/profile', [ProfileController::class, 'update']);
});
