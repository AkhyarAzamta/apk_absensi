<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AttendanceController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\DivisionSettingController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
});



Route::middleware('auth:sanctum')->group(function () {
    Route::post('attendance/checkin', [AttendanceController::class, 'checkIn']);
    Route::post('attendance/checkout', [AttendanceController::class, 'checkOut']);
    Route::get('attendance/history', [AttendanceController::class, 'history']);
});

Route::middleware('auth:sanctum')->group(function () {

    Route::get('/users', [UserController::class, 'index']);
    Route::get('/users/{id}', [UserController::class, 'show']);
    Route::post('/users', [UserController::class, 'store']);
    Route::put('/users/{id}', [UserController::class, 'update']);
    Route::delete('/users/{id}', [UserController::class, 'destroy']);
});

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/division-settings', [DivisionSettingController::class, 'index']);
    Route::get('/division-settings/{id}', [DivisionSettingController::class, 'show']);
    Route::get('/division-settings/by-division/{division_id}', [DivisionSettingController::class, 'getByDivision']);
    Route::post('/division-settings', [DivisionSettingController::class, 'store']);
    Route::put('/division-settings/{id}', [DivisionSettingController::class, 'update']);
    Route::delete('/division-settings/{id}', [DivisionSettingController::class, 'destroy']);
});