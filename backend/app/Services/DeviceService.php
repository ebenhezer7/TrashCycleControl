<?php

namespace App\Services;

use App\Models\Device;

class DeviceService
{
    /**
     * Mengambil daftar alat daur ulang beserta log sensor terbarunya.
     */
    public function getAllDevicesFormatted()
    {
        $devices = Device::with('latestSensorLog')->get();

        return $devices->map(function ($device) {
            $latestLog = $device->latestSensorLog;

            return [
                'id' => (string) $device->id,
                'name' => $device->name,
                'type' => $device->type,
                'status' => $device->status,
                'current_temperature' => $latestLog ? (float) $latestLog->temperature : 0.0,
                'current_humidity' => $latestLog ? (float) $latestLog->humidity : 0.0,
                'current_pressure' => $latestLog ? (float) $latestLog->pressure : 0.0,
                'alert_status' => $latestLog ? $latestLog->alert_status : 'Normal',
                'latest_log' => $latestLog,
            ];
        });
    }

    /**
     * Memproses penyelesaian masalah alert dan menormalkan status sensor alat.
     */
    public function resolveDeviceAction(int $deviceId, string $actionText): bool
    {
        $device = Device::findOrFail($deviceId);
        $device->update(['status' => 'operational']);

        $latestLog = $device->latestSensorLog;
        if ($latestLog) {
            $latestLog->update([
                'alert_status' => 'Normal',
                'humidity' => $device->type === 'Composter' ? 50.0 : $latestLog->humidity,
                'pressure' => $device->type === 'Pirolisis' ? 0.3 : $latestLog->pressure,
            ]);
        }

        return true;
    }
}
