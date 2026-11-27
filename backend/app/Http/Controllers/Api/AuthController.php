<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoginRequest;
use App\Services\AuthService;
use Illuminate\Http\JsonResponse;

class AuthController extends Controller
{
    protected AuthService $authService;

    public function __construct(AuthService $authService)
    {
        $this->authService = $authService;
    }

    /**
     * Authenticate user and issue Sanctum token.
     */
    public function login(LoginRequest $request): JsonResponse
    {
        $result = $this->authService->authenticate(
            $request->validated('email'),
            $request->validated('password')
        );

        if (!$result) {
            return response()->json([
                'status' => 'error',
                'message' => 'Email atau password salah.',
            ], 401);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Login berhasil.',
            'token' => $result['token'],
            'user' => $result['user'],
        ], 200);
    }
}
