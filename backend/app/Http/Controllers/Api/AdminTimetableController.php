<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\NotificationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class AdminTimetableController extends Controller
{
    public function indexPeriods(Request $request): JsonResponse
    {
        if (! $this->isAdmin($request)) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        if (! Schema::hasTable('periods')) {
            return response()->json([]);
        }

        $periods = DB::table('periods')->orderBy('period_number')->get();

        return response()->json($periods);
    }

    public function managementData(Request $request): JsonResponse
    {
        if (! $this->isAdmin($request)) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $classes = DB::table('classes')
            ->select('id', 'name', 'section')
            ->orderBy('name')
            ->orderBy('section')
            ->get();

        $subjects = DB::table('subjects')
            ->select('id', 'name', 'code')
            ->orderBy('name')
            ->get();

        $teachers = DB::table('teachers')
            ->leftJoin('profiles', 'profiles.user_id', '=', 'teachers.user_id')
            ->select('teachers.id', 'teachers.user_id', 'profiles.full_name')
            ->orderBy('profiles.full_name')
            ->get()
            ->map(fn ($t) => [
                'id' => $t->id,
                'user_id' => $t->user_id,
                'full_name' => $t->full_name ?: 'Unknown',
            ]);

        $periods = Schema::hasTable('periods') ? DB::table('periods')->orderBy('period_number')->get() : collect();

        return response()->json([
            'classes' => $classes,
            'subjects' => $subjects,
            'teachers' => $teachers,
            'periods' => $periods,
        ]);
    }

    public function classTimetable(Request $request, int $classId): JsonResponse
    {
        if (! $this->isAdmin($request)) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        if (! Schema::hasTable('timetable')) {
            return response()->json([]);
        }

        $rows = DB::table('timetable')
            ->leftJoin('subjects', 'subjects.id', '=', 'timetable.subject_id')
            ->leftJoin('teachers', 'teachers.id', '=', 'timetable.teacher_id')
            ->leftJoin('profiles', 'profiles.user_id', '=', 'teachers.user_id')
            ->leftJoin('periods', 'periods.id', '=', 'timetable.period_id')
            ->where('timetable.class_id', $classId)
            ->orderByRaw("FIELD(timetable.day_of_week,'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')")
            ->orderBy('periods.period_number')
            ->select(
                'timetable.id',
                'timetable.class_id',
                'timetable.subject_id',
                'timetable.teacher_id',
                'timetable.day_of_week',
                'timetable.period_number',
                'timetable.period_id',
                DB::raw('COALESCE(periods.start_time, timetable.start_time) as start_time'),
                DB::raw('COALESCE(periods.end_time, timetable.end_time) as end_time'),
                'timetable.is_published',
                'subjects.name as subject_name',
                'profiles.full_name as teacher_name',
                'periods.label as period_label',
                'periods.type as period_type'
            )
            ->get()
            ->map(fn ($row) => [
                'id' => $row->id,
                'class_id' => $row->class_id,
                'subject_id' => $row->subject_id,
                'teacher_id' => $row->teacher_id,
                'day_of_week' => $row->day_of_week,
                'period_number' => (int) $row->period_number,
                'period_id' => $row->period_id,
                'period_label' => $row->period_label,
                'period_type' => $row->period_type,
                'start_time' => $row->start_time,
                'end_time' => $row->end_time,
                'is_published' => (bool) $row->is_published,
                'subjects' => $row->subject_name ? ['name' => $row->subject_name] : null,
                'teacherName' => $row->teacher_name,
            ]);

        return response()->json($rows);
    }

    public function teacherSchedule(Request $request, int $teacherId): JsonResponse
    {
        if (! $this->isAdmin($request)) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        if (! Schema::hasTable('timetable')) {
            return response()->json([]);
        }

        $rows = DB::table('timetable')
            ->leftJoin('subjects', 'subjects.id', '=', 'timetable.subject_id')
            ->leftJoin('classes', 'classes.id', '=', 'timetable.class_id')
            ->where('timetable.teacher_id', $teacherId)
            ->where('timetable.is_published', true)
            ->orderBy('timetable.day_of_week')
            ->orderBy('timetable.period_number')
            ->select(
                'timetable.id',
                'timetable.class_id',
                'timetable.subject_id',
                'timetable.teacher_id',
                'timetable.day_of_week',
                'timetable.period_number',
                'timetable.start_time',
                'timetable.end_time',
                'timetable.is_published',
                'subjects.name as subject_name',
                'classes.name as class_name',
                'classes.section as class_section'
            )
            ->get()
            ->map(fn ($row) => [
                'id' => $row->id,
                'class_id' => $row->class_id,
                'subject_id' => $row->subject_id,
                'teacher_id' => $row->teacher_id,
                'day_of_week' => $row->day_of_week,
                'period_number' => (int) $row->period_number,
                'start_time' => $row->start_time,
                'end_time' => $row->end_time,
                'is_published' => (bool) $row->is_published,
                'subjects' => $row->subject_name ? ['name' => $row->subject_name] : null,
                'classes' => $row->class_name ? ['name' => $row->class_name, 'section' => $row->class_section] : null,
            ]);

        return response()->json($rows);
    }

    public function storePeriod(Request $request): JsonResponse
    {
        if (! $this->isAdmin($request)) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $validated = $request->validate([
            'period_number' => ['required', 'integer'],
            'label'         => ['required', 'string', 'max:50'],
            'start_time'    => ['required', 'date_format:H:i'],
            'end_time'      => ['required', 'date_format:H:i'],
            'type'          => ['nullable', 'in:lesson,break,lunch,free'],
        ]);

        if ($validated['start_time'] >= $validated['end_time']) {
            return response()->json(['message' => 'start_time must be before end_time'], 422);
        }

        try {
            $id = DB::table('periods')->insertGetId([
                'period_number' => $validated['period_number'],
                'label'         => $validated['label'],
                'start_time'    => $validated['start_time'],
                'end_time'      => $validated['end_time'],
                'type'          => $validated['type'] ?? 'lesson',
                'created_at'    => now(),
                'updated_at'    => now(),
            ]);
        } catch (QueryException $e) {
            if ((int) $e->getCode() === 23000) {
                return response()->json(['message' => 'A period with this period number already exists'], 422);
            }

            throw $e;
        }

        return response()->json(['id' => $id], 201);
    }

    public function updatePeriod(Request $request, int $id): JsonResponse
    {
        if (! $this->isAdmin($request)) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        if (! Schema::hasTable('periods')) {
            return response()->json(['message' => 'periods table not found'], 422);
        }

        $validated = $request->validate([
            'label'      => ['required', 'string', 'max:50'],
            'type'       => ['required', 'in:lesson,break,lunch,free'],
            'start_time' => ['required', 'date_format:H:i'],
            'end_time'   => ['required', 'date_format:H:i'],
        ]);

        if ($validated['start_time'] >= $validated['end_time']) {
            return response()->json(['message' => 'start_time must be before end_time'], 422);
        }

        try {
            DB::table('periods')->where('id', $id)->update([
                'label'      => $validated['label'],
                'type'       => $validated['type'],
                'start_time' => $validated['start_time'],
                'end_time'   => $validated['end_time'],
                'updated_at' => now(),
            ]);
        } catch (QueryException $e) {
            if ((int) $e->getCode() === 23000) {
                return response()->json(['message' => 'A period with this period number already exists'], 422);
            }

            throw $e;
        }

        return response()->json(['message' => 'Updated']);
    }

    public function destroyPeriod(Request $request, int $id): JsonResponse
    {
        if (! $this->isAdmin($request)) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        if (! Schema::hasTable('periods')) {
            return response()->json(['message' => 'periods table not found'], 422);
        }

        $count = DB::table('timetable')->where('period_id', $id)->count();

        if ($count > 0) {
            return response()->json(['message' => "Cannot delete period: {$count} timetable row(s) reference it"], 422);
        }

        DB::table('periods')->where('id', $id)->delete();

        return response()->json(['message' => 'Deleted']);
    }

    public function store(Request $request): JsonResponse
    {
        if (! $this->isAdmin($request)) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        if (! Schema::hasTable('timetable')) {
            return response()->json(['message' => 'timetable table not found'], 422);
        }

        $validated = $request->validate([
            'class_id'      => ['required', 'integer'],
            'day_of_week'   => ['required', 'string', 'max:20'],
            'period_id'     => ['required', 'integer'],
            'period_number' => ['nullable', 'integer'],
            'subject_id'    => ['nullable', 'integer'],
            'teacher_id'    => ['nullable', 'integer'],
            'start_time'    => ['nullable', 'date_format:H:i'],
            'end_time'      => ['nullable', 'date_format:H:i'],
            'is_published'  => ['nullable', 'boolean'],
        ]);

        $period = DB::table('periods')->where('id', $validated['period_id'])->first();

        if (! $period) {
            return response()->json(['message' => 'The selected period_id is invalid'], 422);
        }

        $periodNumber = $period->period_number;
        $startTime    = $period->start_time;
        $endTime      = $period->end_time;

        try {
            $id = DB::table('timetable')->insertGetId([
                'class_id'      => $validated['class_id'],
                'day_of_week'   => $validated['day_of_week'],
                'period_id'     => $validated['period_id'],
                'period_number' => $periodNumber,
                'subject_id'    => $validated['subject_id'] ?? null,
                'teacher_id'    => $validated['teacher_id'] ?? null,
                'start_time'    => $startTime,
                'end_time'      => $endTime,
                'is_published'  => $validated['is_published'] ?? false,
                'created_at'    => now(),
                'updated_at'    => now(),
            ]);
        } catch (QueryException $e) {
            if ((int) $e->getCode() === 23000) {
                return response()->json(['message' => 'This class already has a period assigned for the selected day and period number'], 422);
            }

            throw $e;
        }

        return response()->json(['id' => $id], 201);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        if (! $this->isAdmin($request)) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        if (! Schema::hasTable('timetable')) {
            return response()->json(['message' => 'timetable table not found'], 422);
        }

        $validated = $request->validate([
            'period_id'  => ['nullable', 'integer'],
            'subject_id' => ['nullable', 'integer'],
            'teacher_id' => ['nullable', 'integer'],
            'start_time' => ['nullable', 'date_format:H:i'],
            'end_time'   => ['nullable', 'date_format:H:i'],
        ]);

        $payload = [
            'subject_id' => $validated['subject_id'] ?? null,
            'teacher_id' => $validated['teacher_id'] ?? null,
            'updated_at' => now(),
        ];

        if (! empty($validated['period_id'])) {
            $period = DB::table('periods')->where('id', $validated['period_id'])->first();

            if (! $period) {
                return response()->json(['message' => 'The selected period_id is invalid'], 422);
            }

            $row = DB::table('timetable')->where('id', $id)->first();

            $conflict = DB::table('timetable')
                ->where('class_id', $row->class_id)
                ->where('day_of_week', $row->day_of_week)
                ->where('period_id', $validated['period_id'])
                ->where('id', '!=', $id)
                ->exists();

            if ($conflict) {
                return response()->json(['message' => 'This class already has a period assigned for the selected day and period'], 422);
            }

            $payload['period_id']     = $validated['period_id'];
            $payload['period_number'] = $period->period_number;
            $payload['start_time']    = $period->start_time;
            $payload['end_time']      = $period->end_time;
        } else {
            if (isset($validated['start_time'])) {
                $payload['start_time'] = $validated['start_time'];
            }
            if (isset($validated['end_time'])) {
                $payload['end_time'] = $validated['end_time'];
            }
        }

        DB::table('timetable')->where('id', $id)->update($payload);

        return response()->json(['message' => 'Updated']);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        if (! $this->isAdmin($request)) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        if (! Schema::hasTable('timetable')) {
            return response()->json(['message' => 'timetable table not found'], 422);
        }

        DB::table('timetable')->where('id', $id)->delete();
        return response()->json(['message' => 'Deleted']);
    }

    public function togglePublish(Request $request, int $id): JsonResponse
    {
        if (! $this->isAdmin($request)) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        if (! Schema::hasTable('timetable')) {
            return response()->json(['message' => 'timetable table not found'], 422);
        }

        $validated = $request->validate([
            'is_published' => ['required', 'boolean'],
        ]);

        DB::table('timetable')->where('id', $id)->update([
            'is_published' => $validated['is_published'],
            'updated_at' => now(),
        ]);

        return response()->json(['message' => 'Updated']);
    }

    public function publishClass(Request $request): JsonResponse
    {
        if (! $this->isAdmin($request)) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        if (! Schema::hasTable('timetable')) {
            return response()->json(['message' => 'timetable table not found'], 422);
        }

        $validated = $request->validate([
            'class_id' => ['required', 'integer'],
        ]);

        DB::table('timetable')->where('class_id', $validated['class_id'])->update([
            'is_published' => true,
            'updated_at' => now(),
        ]);

        $class = DB::table('classes')->where('id', $validated['class_id'])->first();
        $classLabel = $class ? ($class->name.'-'.$class->section) : 'selected class';
        $recipientIds = $this->classRecipientUserIds([(int) $validated['class_id']]);

        app(NotificationService::class)->notifyUsers(
            $recipientIds,
            'Timetable published',
            'Timetable has been published for '.$classLabel.'.',
            [
                'type' => 'announcement',
                'link' => '/teacher/timetable',
                'entity_type' => 'timetable',
                'entity_id' => (string) $validated['class_id'],
                'priority' => 'normal',
                'channel' => 'both',
            ]
        );

        return response()->json(['message' => 'Published']);
    }

    private function classRecipientUserIds(array $classIds): array
    {
        $classIds = collect($classIds)
            ->filter(fn ($v) => is_numeric($v) && (int) $v > 0)
            ->map(fn ($v) => (int) $v)
            ->unique()
            ->values()
            ->all();

        if (empty($classIds)) {
            return [];
        }

        $teacherUserIds = DB::table('classes')
            ->leftJoin('teachers', 'teachers.id', '=', 'classes.class_teacher_id')
            ->whereIn('classes.id', $classIds)
            ->whereNotNull('teachers.user_id')
            ->pluck('teachers.user_id')
            ->map(fn ($v) => (int) $v)
            ->all();

        $parentUserIds = DB::table('students')
            ->join('student_parents', 'student_parents.student_id', '=', 'students.id')
            ->join('parents', 'parents.id', '=', 'student_parents.parent_id')
            ->whereIn('students.class_id', $classIds)
            ->pluck('parents.user_id')
            ->map(fn ($v) => (int) $v)
            ->all();

        return array_values(array_unique(array_merge($teacherUserIds, $parentUserIds)));
    }

    private function isAdmin(Request $request): bool
    {
        return DB::table('user_roles')->where('user_id', $request->user()->id)->value('role') === 'admin';
    }
}
