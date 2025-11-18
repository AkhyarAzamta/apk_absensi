<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AttendanceController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\DivisionSettingController;

// ===================
// PUBLIC AUTH ROUTES
// ===================
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// ===================
// PROTECTED ROUTES
// ===================
Route::middleware('auth:sanctum')->group(function () {

    // Logout
    Route::post('/logout', [AuthController::class, 'logout']);

    // ===================
    // ATTENDANCE
    // ===================
    Route::prefix('attendance')->group(function () {
        Route::post('/checkin', [AttendanceController::class, 'checkIn']);
        Route::post('/checkout', [AttendanceController::class, 'checkOut']);
        Route::get('/history', [AttendanceController::class, 'history']);
    });

    // ===================
    // USERS
    // ===================
    Route::apiResource('users', UserController::class);

//     Route::post('/attendance/checkin', function () {
//     return response()->json([
//         'AUTH' => request()->header('Authorization')
//     ]);
// });

    // ===================
    // DIVISION SETTINGS
    // ===================
    Route::prefix('division-settings')->group(function () {
        Route::get('/', [DivisionSettingController::class, 'index']);
        Route::post('/', [DivisionSettingController::class, 'store']);
        Route::get('/by-division/{division_id}', [DivisionSettingController::class, 'getByDivision']);
        Route::get('/{id}', [DivisionSettingController::class, 'show']);
        Route::put('/{id}', [DivisionSettingController::class, 'update']);
        Route::delete('/{id}', [DivisionSettingController::class, 'destroy']);
    });

});
