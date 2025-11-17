<?php
namespace App\Jobs;

use App\Models\Attendance;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Http;

class VerifyFaceJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $attendanceId;
    protected $type;

    public function __construct($attendanceId, $type)
    {
        $this->attendanceId = $attendanceId;
        $this->type = $type;
    }

    public function handle()
    {
        $attendance = Attendance::find($this->attendanceId);
        if (!$attendance) return;

        $photoPath = storage_path('app/public/' . ($this->type == 'checkin' ? $attendance->check_in_photo : $attendance->check_out_photo));

        $response = Http::attach(
            'photo', file_get_contents($photoPath), basename($photoPath)
        )->post('http://localhost:5000/verify-face', [
            'user_id' => $attendance->user_id
        ]);

        if ($response->ok() && $response->json()['match'] ?? false) {
            $attendance->face_verified = true;
        } else {
            $attendance->face_verified = false;
        }

        $attendance->save();
    }
}

