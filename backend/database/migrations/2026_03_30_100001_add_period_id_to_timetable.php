<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Step 1: Add nullable period_id FK column (DDL — outside transaction)
        Schema::table('timetable', function (Blueprint $table): void {
            $table->unsignedBigInteger('period_id')->nullable()->after('end_time');
            $table->foreign('period_id')->references('id')->on('periods');
        });

        // Step 2: Back-fill periods from existing timetable data (DML — safe in transaction)
        DB::transaction(function (): void {
            $distinctPeriods = DB::table('timetable')
                ->select('period_number', 'start_time', 'end_time')
                ->distinct()
                ->get();

            foreach ($distinctPeriods as $p) {
                $periodId = DB::table('periods')->insertGetId([
                    'period_number' => $p->period_number,
                    'label'         => "Period {$p->period_number}",
                    'type'          => 'lesson',
                    'start_time'    => $p->start_time,
                    'end_time'      => $p->end_time,
                    'created_at'    => now(),
                    'updated_at'    => now(),
                ]);

                DB::table('timetable')
                    ->where('period_number', $p->period_number)
                    ->where('start_time', $p->start_time)
                    ->where('end_time', $p->end_time)
                    ->update(['period_id' => $periodId]);
            }

            $nullCount = DB::table('timetable')->whereNull('period_id')->count();
            if ($nullCount > 0) {
                throw new \RuntimeException(
                    "Back-fill failed: {$nullCount} timetable row(s) still have a null period_id."
                );
            }
        });

        // Step 3: Make period_id NOT NULL (DDL — outside transaction)
        Schema::table('timetable', function (Blueprint $table): void {
            $table->unsignedBigInteger('period_id')->nullable(false)->change();
        });
    }

    public function down(): void
    {
        Schema::table('timetable', function (Blueprint $table): void {
            $table->dropForeign(['period_id']);
            $table->dropColumn('period_id');
        });
    }
};
