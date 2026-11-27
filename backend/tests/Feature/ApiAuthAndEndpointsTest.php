<?php

namespace Tests\Feature;

use App\Models\Device;
use App\Models\SensorLog;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class ApiAuthAndEndpointsTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        // Seed test user
        User::create([
            'name' => 'Rudi Hermawan',
            'email' => 'rudi.hermawan@trashcycle.com',
            'password' => Hash::make('password123'),
        ]);

        // Seed test device
        $device = Device::create([
            'name' => 'Low-Smoke Incinerator',
            'type' => 'Incinerator',
            'status' => 'operational',
        ]);

        SensorLog::create([
            'device_id' => $device->id,
            'temperature' => 450.0,
            'humidity' => 15.0,
            'pressure' => 0.1,
            'alert_status' => 'Normal',
        ]);
    }

    /** @test */
    public function login_success_without_v1_prefix()
    {
        $response = $this->postJson('/api/auth/login', [
            'email' => 'rudi.hermawan@trashcycle.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure(['status', 'message', 'token', 'user']);
    }

    /** @test */
    public function login_success_with_v1_prefix()
    {
        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'rudi.hermawan@trashcycle.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure(['status', 'message', 'token', 'user']);
    }

    /** @test */
    public function login_fails_with_invalid_credentials()
    {
        $response = $this->postJson('/api/auth/login', [
            'email' => 'rudi.hermawan@trashcycle.com',
            'password' => 'wrong_password',
        ]);

        $response->assertStatus(401)
            ->assertJson(['status' => 'error']);
    }

    /** @test */
    public function fetch_devices_without_v1_prefix()
    {
        $response = $this->getJson('/api/devices');

        $response->assertStatus(200)
            ->assertJsonStructure(['status', 'message', 'data']);
    }

    /** @test */
    public function fetch_devices_with_v1_prefix()
    {
        $response = $this->getJson('/api/v1/devices');

        $response->assertStatus(200)
            ->assertJsonStructure(['status', 'message', 'data']);
    }

    /** @test */
    public function resolve_action_without_v1_prefix()
    {
        $device = Device::first();

        $response = $this->postJson('/api/actions', [
            'device_id' => $device->id,
            'action_text' => 'Perbaikan suhu incinerator',
        ]);

        $response->assertStatus(200)
            ->assertJson(['status' => 'success']);
    }

    /** @test */
    public function resolve_action_with_v1_prefix()
    {
        $device = Device::first();

        $response = $this->postJson('/api/v1/actions', [
            'device_id' => $device->id,
            'action_text' => 'Perbaikan suhu incinerator',
        ]);

        $response->assertStatus(200)
            ->assertJson(['status' => 'success']);
    }

    /** @test */
    public function update_profile_without_v1_prefix()
    {
        $user = User::first();

        $response = $this->actingAs($user, 'sanctum')->postJson('/api/user/profile', [
            'name' => 'Rudi Hermawan Updated',
            'email' => 'rudi.updated@trashcycle.com',
            'phone' => '081234567890',
        ]);

        $response->assertStatus(200)
            ->assertJson(['status' => 'success']);
    }

    /** @test */
    public function update_profile_with_v1_prefix()
    {
        $user = User::first();

        $response = $this->actingAs($user, 'sanctum')->postJson('/api/v1/user/profile', [
            'name' => 'Rudi Hermawan Updated',
            'email' => 'rudi.updated@trashcycle.com',
            'phone' => '081234567890',
        ]);

        $response->assertStatus(200)
            ->assertJson(['status' => 'success']);
    }
}
