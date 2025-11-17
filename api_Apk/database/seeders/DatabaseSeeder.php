<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\{Role, Division, User};
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder {
    public function run(): void {
        // Roles
        $superAdmin = Role::create(['name' => 'SUPER_ADMIN']);
        $employee = Role::create(['name' => 'EMPLOYEE']);

        // Divisions
        $finance = Division::create(['name' => 'FINANCE']);
        $apo = Division::create(['name' => 'APO']);
        $front = Division::create(['name' => 'FRONT DESK']);
        $onsite = Division::create(['name' => 'ONSITE']);

        // Admins
        User::create([
            'name' => 'Admin Finance',
            'email' => 'finance@admin.com',
            'password' => Hash::make('password'),
            'role_id' => $superAdmin->id,
            'division_id' => $finance->id
        ]);

        User::create([
            'name' => 'Admin APO',
            'email' => 'apo@admin.com',
            'password' => Hash::make('password'),
            'role_id' => $superAdmin->id,
            'division_id' => $apo->id
        ]);

        User::create([
            'name' => 'Admin Front Desk',
            'email' => 'front@admin.com',
            'password' => Hash::make('password'),
            'role_id' => $superAdmin->id,
            'division_id' => $front->id
        ]);

        User::create([
            'name' => 'Admin Onsite',
            'email' => 'onsite@admin.com',
            'password' => Hash::make('password'),
            'role_id' => $superAdmin->id,
            'division_id' => $onsite->id
        ]);

        // Karyawan biasa
        User::create([
            'name' => 'Karyawan Biasa',
            'email' => 'user@karyawan.com',
            'password' => Hash::make('password'),
            'role_id' => $employee->id,
            'division_id' => $finance->id
        ]);
    }
}
