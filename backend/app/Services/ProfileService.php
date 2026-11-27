<?php

namespace App\Services;

use App\Models\User;

class ProfileService
{
    /**
     * Memperbarui data profil pengguna.
     */
    public function updateProfile(User $user, array $data): User
    {
        $user->update([
            'name' => $data['name'],
            'email' => $data['email'],
            'phone' => $data['phone'] ?? $user->phone,
        ]);

        return $user;
    }
}
