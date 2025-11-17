<?php
// database/migrations/2025_11_12_000010_create_division_settings_table.php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('division_settings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('division_id')->constrained('divisions');
            $table->time('work_start')->nullable();
            $table->time('work_end')->nullable();
            $table->integer('grace_minutes')->default(0); // toleransi terlambat
            $table->decimal('penalty_per_minute', 10, 2)->default(0);
            $table->decimal('radius_meters', 8, 2)->default(100.0); // radius kantor dalam meter
            $table->decimal('office_lat', 10, 7)->nullable();
            $table->decimal('office_lng', 10, 7)->nullable();
            $table->timestamps();
        });
    }

    public function down(): void {
        Schema::dropIfExists('division_settings');
    }
};
