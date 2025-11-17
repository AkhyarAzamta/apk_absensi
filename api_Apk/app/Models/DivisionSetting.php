<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DivisionSetting extends Model
{
    use HasFactory;

    protected $fillable = [
        'division_id',
        'work_start',
        'work_end',
        'grace_minutes',
        'penalty_per_minute',
        'radius_meters',
        'office_lat',
        'office_lng',
    ];

    // Relasi ke tabel divisions
    public function division()
    {
        return $this->belongsTo(Division::class);
    }
}
