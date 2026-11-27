<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\UpdateProfileRequest;
use App\Services\ProfileService;
use Illuminate\Http\JsonResponse;

class ProfileController extends Controller
{
    protected ProfileService $profileService;

    public function __construct(ProfileService $profileService)
    {
        $this->profileService = $profileService;
    }

    /**
     * Memperbarui data profil pengguna terautentikasi.
     */
    public function update(UpdateProfileRequest $request): JsonResponse
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'status' => 'error',
                'message' => 'Unauthenticated',
            ], 401);
        }

        $updatedUser = $this->profileService->updateProfile($user, $request->validated());

        return response()->json([
            'status' => 'success',
            'message' => 'Profil berhasil diperbarui.',
            'data' => [
                'id' => (string) $updatedUser->id,
                'name' => $updatedUser->name,
                'email' => $updatedUser->email,
                'phone' => $updatedUser->phone ?? '',
            ],
        ], 200);
    }
}
