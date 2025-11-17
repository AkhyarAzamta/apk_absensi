<?php
namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use App\Models\DivisionSetting;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Carbon\Carbon;

class AttendanceController extends Controller
{
    // Check-in
    public function checkIn(Request $r)
    {
        $r->validate([
            'photo' => 'required|image|max:5120',
            'lat' => 'required|numeric',
            'lng' => 'required|numeric',
        ]);

        $user = $r->user();
        $date = now()->toDateString();

        // prevent double check-in (optional)
        $existing = Attendance::where('user_id', $user->id)->where('date', $date)->first();
        if ($existing && $existing->check_in_time) {
            return response()->json(['message' => 'Anda sudah absen masuk hari ini'], 422);
        }

        $path = $r->file('photo')->store('attendances', 'public');

        $att = Attendance::firstOrNew(['user_id' => $user->id, 'date' => $date]);
        $att->division_id = $user->division_id;
        $att->check_in_time = now()->toTimeString();
        $att->check_in_photo = $path;
        $att->check_in_lat = $r->lat;
        $att->check_in_lng = $r->lng;
        $att->status = 'present';
        $att->save();

        // location verify
        $att->location_verified = $this->verifyLocation($att->check_in_lat, $att->check_in_lng, $user);
        $att->save();

        // dispatch face verify job (async)
        // VerifyFaceJob::dispatch($att->id, 'checkin');

        // compute late & penalty
        $this->computeLateAndPenalty($att);

        return response()->json(['message' => 'Check-in berhasil', 'attendance' => $att]);
    }

    // Check-out
    public function checkOut(Request $r)
    {
        $r->validate([
            'photo' => 'required|image|max:5120',
            'lat' => 'required|numeric',
            'lng' => 'required|numeric',
        ]);

        $user = $r->user();
        $date = now()->toDateString();

        $att = Attendance::where('user_id', $user->id)->where('date', $date)->first();
        if (!$att || !$att->check_in_time) {
            return response()->json(['message' => 'Belum melakukan check-in hari ini'], 422);
        }

        if ($att->check_out_time) {
            return response()->json(['message' => 'Anda sudah melakukan check-out hari ini'], 422);
        }

        $path = $r->file('photo')->store('attendances', 'public');
        $att->check_out_time = now()->toTimeString();
        $att->check_out_photo = $path;
        $att->check_out_lat = $r->lat;
        $att->check_out_lng = $r->lng;

        // update location_verified if either checkin/checkout within radius
        $locVerified = $att->location_verified || $this->verifyLocation($att->check_out_lat, $att->check_out_lng, $user);
        $att->location_verified = $locVerified;

        $att->save();

        // VerifyFaceJob::dispatch($att->id, 'checkout');

        // compute overtime if needed (placeholder)
        // $this->computeOvertime($att);

        return response()->json(['message' => 'Check-out berhasil', 'attendance' => $att]);
    }

    // History for current user
    public function history(Request $r)
    {
        $user = $r->user();
        $from = $r->query('from', now()->subMonth()->toDateString());
        $to   = $r->query('to', now()->toDateString());

        $records = Attendance::where('user_id', $user->id)
            ->whereBetween('date', [$from, $to])
            ->orderBy('date', 'desc')
            ->get();

        return response()->json(['data' => $records]);
    }

    // ---------- helpers ----------

    protected function verifyLocation($lat, $lng, $user): bool
    {
        if (!$lat || !$lng) return false;
        $setting = DivisionSetting::where('division_id', $user->division_id)->first();
        if (!$setting || !$setting->office_lat || !$setting->office_lng) {
            // jika tidak ada setting lokasi, boleh set ke true atau false sesuai kebijakan
            return false;
        }

        $distance = $this->haversineMeters($lat, $lng, $setting->office_lat, $setting->office_lng);
        return ($distance <= (float)$setting->radius_meters);
    }

    // Haversine formula -> returns meters
    protected function haversineMeters($lat1, $lng1, $lat2, $lng2)
    {
        $earthRadius = 6371000; // meters
        $latFrom = deg2rad($lat1);
        $latTo = deg2rad($lat2);
        $lonFrom = deg2rad($lng1);
        $lonTo = deg2rad($lng2);

        $latDelta = $latTo - $latFrom;
        $lonDelta = $lonTo - $lonFrom;

        $a = sin($latDelta / 2) * sin($latDelta / 2) +
             cos($latFrom) * cos($latTo) *
             sin($lonDelta / 2) * sin($lonDelta / 2);

        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

        return $earthRadius * $c;
    }

    protected function computeLateAndPenalty(Attendance $att)
    {
        // pastikan ada check_in_time
        if (!$att->check_in_time) return;

        $setting = DivisionSetting::where('division_id', $att->division_id)->first();
        if (!$setting || !$setting->work_start) return;

        $workStart = Carbon::createFromFormat('H:i:s', $setting->work_start->format('H:i:s'));
        $checkIn = Carbon::createFromTimeString($att->check_in_time);

        $diff = $checkIn->diffInMinutes($workStart, false); // negative if earlier
        $late = 0;
        if ($diff > $setting->grace_minutes) {
            $late = $diff - $setting->grace_minutes;
        }

        $penalty = $late * (float)$setting->penalty_per_minute;

        $att->late_minutes = (int)$late;
        $att->late_penalty = $penalty;
        $att->save();
    }
}
