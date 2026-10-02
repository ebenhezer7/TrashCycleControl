<?php

namespace Database\Seeders;

use App\Models\Device;
use App\Models\SensorLog;
use Illuminate\Database\Seeder;

class DeviceSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // 1. Low-Smoke Incinerator (Normal)
        $incinerator = Device::create([
            'name' => 'Low-Smoke Incinerator',
            'type' => 'Incinerator',
            'status' => 'operational',
        ]);

        SensorLog::create([
            'device_id' => $incinerator->id,
            'temperature' => 450.0,
            'humidity' => 15.0,
            'pressure' => 0.1,
            'alert_status' => 'Normal',
        ]);

        // 2. Smart Composter (Anomali Kelembapan: 30%)
        $composter = Device::create([
            'name' => 'Smart Composter',
            'type' => 'Composter',
            'status' => 'warning',
        ]);

        SensorLog::create([
            'device_id' => $composter->id,
            'temperature' => 55.0,
            'humidity' => 30.0, // Anomali kelembapan < 40%
            'pressure' => 0.05,
            'alert_status' => 'Kelembapan Rendah',
        ]);

        // 3. Sistem Pirolisis Plastik (Anomali Tekanan: 0.6 bar)
        $pirolisis = Device::create([
            'name' => 'Sistem Pirolisis Plastik',
            'type' => 'Pirolisis',
            'status' => 'alert',
        ]);

        SensorLog::create([
            'device_id' => $pirolisis->id,
            'temperature' => 420.0,
            'humidity' => 10.0,
            'pressure' => 0.6, // Anomali tekanan > 0.5 bar
            'alert_status' => 'Tekanan Tinggi',
        ]);
    }
}
