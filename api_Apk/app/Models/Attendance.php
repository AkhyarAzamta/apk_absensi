<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Attendance extends Model
{
    protected $fillable = [
        'user_id','division_id','date',
        'check_in_time','check_out_time',
        'check_in_photo','check_out_photo',
        'check_in_lat','check_in_lng','check_out_lat','check_out_lng',
        'late_minutes','late_penalty','status',
        'face_verified','location_verified','manual_reason'
    ];

    public function user() { return $this->belongsTo(User::class); }
    public function division() { return $this->belongsTo(Division::class); }
}
