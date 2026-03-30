<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('periods')) {
            return;
        }

        Schema::create('periods', function (Blueprint $table): void {
            $table->id();
            $table->unsignedInteger('period_number')->unique();
            $table->string('label', 50);
            $table->enum('type', ['lesson', 'break', 'lunch', 'free'])->default('lesson');
            $table->time('start_time');
            $table->time('end_time');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('periods');
    }
};
