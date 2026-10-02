<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SensorLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'device_id',
        'temperature',
        'humidity',
        'pressure',
        'alert_status',
    ];

    /**
     * Relasi Inverse ke Device.
     */
    public function device(): BelongsTo
    {
        return $this->belongsTo(Device::class);
    }
}
