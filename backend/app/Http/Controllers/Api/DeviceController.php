<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\ResolveActionRequest;
use App\Services\DeviceService;
use Illuminate\Http\JsonResponse;

class DeviceController extends Controller
{
    protected DeviceService $deviceService;

    public function __construct(DeviceService $deviceService)
    {
        $this->deviceService = $deviceService;
    }

    /**
     * Menampilkan daftar alat daur ulang beserta log sensor terbarunya.
     */
    public function index(): JsonResponse
    {
        $formattedDevices = $this->deviceService->getAllDevicesFormatted();

        return response()->json([
            'status' => 'success',
            'message' => 'Daftar perangkat berhasil diambil',
            'data' => $formattedDevices,
        ], 200);
    }

    /**
     * Menerima log tindakan perbaikan dari petugas dan menormalkan status alert.
     */
    public function resolveAction(ResolveActionRequest $request): JsonResponse
    {
        $this->deviceService->resolveDeviceAction(
            (int) $request->validated('device_id'),
            $request->validated('action_text')
        );

        return response()->json([
            'status' => 'success',
            'message' => 'Tindakan perbaikan berhasil dicatat dan status telah dipulihkan.',
        ], 200);
    }
}
