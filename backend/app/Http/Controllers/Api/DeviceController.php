<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Device;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DeviceController extends Controller
{
    /**
     * Menampilkan daftar alat daur ulang beserta log sensor terbarunya.
     */
    public function index(): JsonResponse
    {
        $devices = Device::with('latestSensorLog')->get();

        $formattedDevices = $devices->map(function ($device) {
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

        return response()->json([
            'status' => 'success',
            'message' => 'Daftar perangkat berhasil diambil',
            'data' => $formattedDevices,
        ], 200);
    }

    /**
     * Menerima log tindakan perbaikan dari petugas dan menormalkan status alert.
     */
    public function resolveAction(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'device_id' => 'required|exists:devices,id',
            'action_text' => 'required|string',
        ]);

        $device = Device::findOrFail($validated['device_id']);
        $device->update(['status' => 'operational']);

        $latestLog = $device->latestSensorLog;
        if ($latestLog) {
            $latestLog->update([
                'alert_status' => 'Normal',
                'humidity' => $device->type === 'Composter' ? 50.0 : $latestLog->humidity,
                'pressure' => $device->type === 'Pirolisis' ? 0.3 : $latestLog->pressure,
            ]);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Tindakan perbaikan berhasil dicatat dan status telah dipulihkan.',
        ], 200);
    }
}
