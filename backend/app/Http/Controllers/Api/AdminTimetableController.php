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

        return response()->json([
            'classes' => $classes,
            'subjects' => $subjects,
            'teachers' => $teachers,
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
            ->where('timetable.class_id', $classId)
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
                'profiles.full_name as teacher_name'
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

    public function store(Request $request): JsonResponse
    {
        if (! $this->isAdmin($request)) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        if (! Schema::hasTable('timetable')) {
            return response()->json(['message' => 'timetable table not found'], 422);
        }

        $validated = $request->validate([
            'class_id' => ['required', 'integer'],
            'day_of_week' => ['required', 'string', 'max:20'],
            'period_number' => ['required', 'integer'],
            'subject_id' => ['nullable', 'integer'],
            'teacher_id' => ['nullable', 'integer'],
            'start_time' => ['required', 'date_format:H:i'],
            'end_time' => ['required', 'date_format:H:i'],
            'is_published' => ['nullable', 'boolean'],
        ]);

        try {
            $id = DB::table('timetable')->insertGetId([
                'class_id' => $validated['class_id'],
                'day_of_week' => $validated['day_of_week'],
                'period_number' => $validated['period_number'],
                'subject_id' => $validated['subject_id'] ?? null,
                'teacher_id' => $validated['teacher_id'] ?? null,
                'start_time' => $validated['start_time'],
                'end_time' => $validated['end_time'],
                'is_published' => $validated['is_published'] ?? false,
                'created_at' => now(),
                'updated_at' => now(),
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
            'subject_id' => ['nullable', 'integer'],
            'teacher_id' => ['nullable', 'integer'],
            'start_time' => ['required', 'date_format:H:i'],
            'end_time' => ['required', 'date_format:H:i'],
        ]);

        DB::table('timetable')->where('id', $id)->update([
            'subject_id' => $validated['subject_id'] ?? null,
            'teacher_id' => $validated['teacher_id'] ?? null,
            'start_time' => $validated['start_time'],
            'end_time' => $validated['end_time'],
            'updated_at' => now(),
        ]);

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
