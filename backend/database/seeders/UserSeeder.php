<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        User::updateOrCreate(
            ['email' => 'rudi.hermawan@trashcycle.com'],
            [
                'name' => 'Rudi Hermawan',
                'password' => Hash::make('password123'),
            ]
        );

        User::updateOrCreate(
            ['email' => 'budi.santoso@trashcycle.com'],
            [
                'name' => 'Budi Santoso',
                'password' => Hash::make('password123'),
            ]
        );

        User::updateOrCreate(
            ['email' => 'siti.aminah@trashcycle.com'],
            [
                'name' => 'Siti Aminah',
                'password' => Hash::make('password123'),
            ]
        );
    }
}
