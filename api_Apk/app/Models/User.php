<?php
namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable {
    use HasApiTokens, Notifiable;

    protected $fillable = [
        'name', 'email', 'password', 'role_id', 'division_id', 'photo', 'is_active'
    ];

    protected $hidden = ['password'];

    public function role() {
        return $this->belongsTo(Role::class);
    }

    public function division() {
        return $this->belongsTo(Division::class);
    }
}
