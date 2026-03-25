<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Support\HandlesUploadStorage;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class HolidayCalendarController extends Controller
{
    use HandlesUploadStorage;

    public function index(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'year' => ['nullable', 'regex:/^\d{4}$/'],
        ]);

        $year = isset($validated['year']) ? (int) $validated['year'] : now()->year;

        if (! Schema::hasTable('holidays')) {
            return response()->json([]);
        }

        $yearStart = $year.'-01-01';
        $yearEnd   = $year.'-12-31';

        // Non-recurring holidays overlapping the requested year
        $nonRecurring = DB::table('holidays')
            ->where('is_recurring', false)
            ->where('start_date', '<=', $yearEnd)
            ->where(function ($q) use ($yearStart): void {
                $q->where('end_date', '>=', $yearStart)
                  ->orWhere(function ($q2) use ($yearStart): void {
                      $q2->whereNull('end_date')
                         ->where('start_date', '>=', $yearStart);
                  });
            })
            ->get()
            ->map(fn ($h) => (array) $h);

        // Recurring holidays projected to the requested year
        $recurring = DB::table('holidays')
            ->where('is_recurring', true)
            ->get()
            ->map(function ($h) use ($year): array {
                $start = Carbon::parse($h->start_date)->setYear($year);
                $end   = $h->end_date ? Carbon::parse($h->end_date)->setYear($year) : null;

                return array_merge((array) $h, [
                    'id'         => 'recurring_'.$h->id.'_'.$year,
                    'start_date' => $start->toDateString(),
                    'end_date'   => $end?->toDateString(),
                ]);
            });

        $merged = $nonRecurring->concat($recurring)
            ->sortBy('start_date')
            ->values();

        return response()->json($merged);
    }

    public function store(Request $request): JsonResponse
    {
        if (! $this->isAdmin($request)) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $validated = $request->validate([
            'name'         => ['required', 'string', 'max:255'],
            'start_date'   => ['required', 'date'],
            'end_date'     => ['nullable', 'date', 'after_or_equal:start_date'],
            'type'         => ['required', 'in:national,religious,school,optional'],
            'description'  => ['nullable', 'string'],
            'image'        => ['nullable', 'image', 'max:10240'],
            'is_recurring' => ['nullable', 'boolean'],
        ]);

        $imageUrl = null;

        if ($request->hasFile('image')) {
            try {
                $path = $this->storeUploadedFile($request->file('image'), 'holidays');
                $imageUrl = $this->buildUploadUrl($path);
            } catch (\Throwable $e) {
                \Illuminate\Support\Facades\Log::error('Holiday image upload failed', [
                    'user_id'  => $request->user()->id,
                    'disk'     => $this->uploadDisk(),
                    'filename' => $request->file('image')?->getClientOriginalName(),
                    'mime'     => $request->file('image')?->getMimeType(),
                    'message'  => $e->getMessage(),
                ]);

                return response()->json(['message' => 'Image upload failed. Check storage permissions.'], 422);
            }
        }

        $id = DB::table('holidays')->insertGetId([
            'name'         => $validated['name'],
            'start_date'   => $validated['start_date'],
            'end_date'     => $validated['end_date'] ?? null,
            'type'         => $validated['type'],
            'description'  => $validated['description'] ?? null,
            'image_url'    => $imageUrl,
            'is_recurring' => $validated['is_recurring'] ?? false,
            'created_by'   => $request->user()->id,
            'created_at'   => now(),
            'updated_at'   => now(),
        ]);

        $holiday = DB::table('holidays')->where('id', $id)->first();

        return response()->json($holiday, 201);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        if (! $this->isAdmin($request)) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $row = DB::table('holidays')->where('id', $id)->first();
        if (! $row) {
            return response()->json(['message' => 'Not Found'], 404);
        }

        $validated = $request->validate([
            'name'         => ['required', 'string', 'max:255'],
            'start_date'   => ['required', 'date'],
            'end_date'     => ['nullable', 'date', 'after_or_equal:start_date'],
            'type'         => ['required', 'in:national,religious,school,optional'],
            'description'  => ['nullable', 'string'],
            'image'        => ['nullable', 'image', 'max:10240'],
            'is_recurring' => ['nullable', 'boolean'],
        ]);

        $imageUrl = $row->image_url;

        if ($request->hasFile('image')) {
            try {
                $this->deleteStoredFile($row->image_url);
                $path = $this->storeUploadedFile($request->file('image'), 'holidays');
                $imageUrl = $this->buildUploadUrl($path);
            } catch (\Throwable $e) {
                \Illuminate\Support\Facades\Log::error('Holiday image upload failed', [
                    'holiday_id' => $id,
                    'user_id'    => $request->user()->id,
                    'disk'       => $this->uploadDisk(),
                    'filename'   => $request->file('image')?->getClientOriginalName(),
                    'mime'       => $request->file('image')?->getMimeType(),
                    'message'    => $e->getMessage(),
                ]);

                return response()->json(['message' => 'Image upload failed. Check storage permissions.'], 422);
            }
        }

        DB::table('holidays')->where('id', $id)->update([
            'name'         => $validated['name'],
            'start_date'   => $validated['start_date'],
            'end_date'     => $validated['end_date'] ?? null,
            'type'         => $validated['type'],
            'description'  => $validated['description'] ?? null,
            'image_url'    => $imageUrl,
            'is_recurring' => $validated['is_recurring'] ?? false,
            'updated_at'   => now(),
        ]);

        $updated = DB::table('holidays')->where('id', $id)->first();

        return response()->json($updated);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        if (! $this->isAdmin($request)) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $row = DB::table('holidays')->where('id', $id)->first();
        if (! $row) {
            return response()->json(['message' => 'Not Found'], 404);
        }

        if ($row->image_url) {
            $this->deleteStoredFile($row->image_url);
        }

        DB::table('holidays')->where('id', $id)->delete();

        return response()->json(['message' => 'Deleted']);
    }

    private function isAdmin(Request $request): bool
    {
        return DB::table('user_roles')->where('user_id', $request->user()->id)->value('role') === 'admin';
    }
}
