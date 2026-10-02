<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Device extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'type',
        'status',
    ];

    /**
     * Relasi One-to-Many ke SensorLog.
     */
    public function sensorLogs(): HasMany
    {
        return $this->hasMany(SensorLog::class);
    }

    /**
     * Relasi ke SensorLog Terbaru.
     */
    public function latestSensorLog(): HasOne
    {
        return $this->hasOne(SensorLog::class)->latestOfMany();
    }
}
