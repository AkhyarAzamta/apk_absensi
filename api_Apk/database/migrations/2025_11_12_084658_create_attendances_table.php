<?php
// database/migrations/2025_11_12_000011_create_attendances_table.php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('attendances', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users');
            $table->foreignId('division_id')->nullable()->constrained('divisions');
            $table->date('date');
            $table->time('check_in_time')->nullable();
            $table->time('check_out_time')->nullable();
            $table->string('check_in_photo')->nullable();
            $table->string('check_out_photo')->nullable();
            $table->decimal('check_in_lat', 10, 7)->nullable();
            $table->decimal('check_in_lng', 10, 7)->nullable();
            $table->decimal('check_out_lat', 10, 7)->nullable();
            $table->decimal('check_out_lng', 10, 7)->nullable();
            $table->integer('late_minutes')->default(0);
            $table->decimal('late_penalty', 10, 2)->default(0);
            $table->enum('status', ['present','absent','manual','failed'])->default('present');
            $table->boolean('face_verified')->default(false);
            $table->boolean('location_verified')->default(false);
            $table->string('manual_reason')->nullable();
            $table->timestamps();

            $table->unique(['user_id','date']);
        });
    }

    public function down(): void {
        Schema::dropIfExists('attendances');
    }
};
