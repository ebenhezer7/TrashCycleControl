<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DeviceController;
use App\Http\Controllers\Api\ProfileController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes (Dual-Compatibility: /api/... & /api/v1/...)
|--------------------------------------------------------------------------
*/

$registerRoutes = function () {
    // Auth Routes
    Route::post('/auth/login', [AuthController::class, 'login']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);

    // Device Telemetry & Action Log Routes
    Route::get('/devices', [DeviceController::class, 'index']);
    Route::post('/actions', [DeviceController::class, 'resolveAction']);

    // User Profile Routes
    Route::post('/user/profile', [ProfileController::class, 'update']);
};

// Route tanpa prefix v1: /api/auth/login, /api/devices, /api/actions, /api/user/profile
$registerRoutes();

// Route dengan prefix v1: /api/v1/auth/login, /api/v1/devices, /api/v1/actions, /api/v1/user/profile
Route::prefix('v1')->group($registerRoutes);

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return response()->json([
        'status' => 'success',
        'data' => $request->user(),
    ]);
});
