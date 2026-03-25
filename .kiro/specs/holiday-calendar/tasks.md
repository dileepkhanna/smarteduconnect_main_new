# Implementation Plan: Holiday Calendar

## Overview

Implement the Holiday Calendar feature end-to-end: database migration, Laravel controller with RBAC and recurring projection, API route registration, TypeScript types and API service, and five React components wired together in a shared HolidayCalendar page accessible to all three roles.

## Tasks

- [x] 1. Create database migration for the holidays table
  - Create `backend/database/migrations/2026_03_14_100000_create_holidays_table.php`
  - Use `Schema::create` guarded by `if (!Schema::hasTable('holidays'))` matching the gallery migration pattern
  - Define all columns from the design: `id`, `name` (string 255), `type` (enum), `start_date` (date), `end_date` (date nullable), `description` (text nullable), `image_url` (string 2048 nullable), `is_recurring` (boolean default false), `created_by` (unsignedBigInteger nullable), `timestamps()`
  - Add composite index on `['start_date', 'end_date']` and single index on `is_recurring`
  - Implement `down()` with `Schema::dropIfExists('holidays')`
  - _Requirements: 3.4, 7.1, 9.1_

- [x] 2. Implement the Holiday Eloquent model
  - Create `backend/app/Models/Holiday.php`
  - Set `$fillable` to all writable columns: `name`, `type`, `start_date`, `end_date`, `description`, `image_url`, `is_recurring`, `created_by`
  - Set `$casts`: `start_date` → `date`, `end_date` → `date:nullable`, `is_recurring` → `boolean`
  - No relationships needed
  - _Requirements: 9.1_

- [x] 3. Implement HolidayCalendarController — index action
  - Create `backend/app/Http/Controllers/Api/HolidayCalendarController.php` using `HandlesUploadStorage` trait
  - Implement `index(Request $request): JsonResponse`
  - Validate optional `year` query param: must be a 4-digit integer; return 422 if invalid (Property 9)
  - Default `year` to `now()->year` when absent
  - Fetch non-recurring holidays whose date range overlaps the requested year: `start_date <= {year}-12-31` AND (`end_date >= {year}-01-01` OR (`end_date IS NULL` AND `start_date >= {year}-01-01`)) (Property 5)
  - Fetch all recurring holidays and project each to the requested year using `Carbon::parse()->setYear($year)`, assigning virtual id `recurring_{id}_{year}` (Property 6)
  - Merge both sets, sort by `start_date` ascending, return as JSON array (Property 10)
  - Return HTTP 200 for any authenticated user (Property 11)
  - _Requirements: 7.2, 7.3, 8.1, 9.1, 9.2, 9.3, 9.4, 6.6_

- [x] 4. Implement HolidayCalendarController — store action
  - Add `store(Request $request): JsonResponse` to `HolidayCalendarController`
  - Guard with `isAdmin()` private method (same pattern as `GalleryController`); return 403 if not admin (Property 4)
  - Validate: `name` required string max 255, `start_date` required date, `end_date` nullable date after-or-equal `start_date`, `type` required in `['national','religious','school','optional']`, `description` nullable string, `image` nullable image max 10240, `is_recurring` nullable boolean
  - Return 422 with Laravel validation errors for missing `name`, missing `start_date`, or `end_date < start_date` (Properties 2, 3)
  - If `image` file present, call `storeUploadedFile` and `buildUploadUrl` inside try/catch matching `GalleryController::uploadImage` error handling pattern
  - Insert row via `DB::table('holidays')->insertGetId(...)` with `created_by`, `created_at`, `updated_at`
  - Return HTTP 201 with `['id' => $id, 'image_url' => $url]`
  - _Requirements: 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 3.10, 6.3_

- [x] 5. Implement HolidayCalendarController — update and destroy actions
  - Add `update(Request $request, int $id): JsonResponse`
    - Guard with `isAdmin()`; return 403 if not admin (Property 4)
    - Fetch existing row; return 404 if not found
    - Validate same fields as store (image optional); apply `end_date` after-or-equal rule (Property 2)
    - If new image uploaded, delete old image via `deleteStoredFile`, store new one
    - Update row via `DB::table('holidays')->where('id', $id)->update(...)`
    - Return HTTP 200 `['message' => 'Updated']`
  - Add `destroy(Request $request, int $id): JsonResponse`
    - Guard with `isAdmin()`; return 403 if not admin (Property 4)
    - Fetch existing row; return 404 if not found
    - Delete image file via `deleteStoredFile($row->image_url)`
    - Delete row; return HTTP 200 `['message' => 'Deleted']`
  - Add private `isAdmin(Request $request): bool` using `DB::table('user_roles')` lookup
  - _Requirements: 4.4, 4.5, 5.2, 6.4, 6.5_

- [x] 6. Register holiday API routes in api.php
  - Add `use App\Http\Controllers\Api\HolidayCalendarController;` import to `backend/routes/api.php`
  - Inside the existing `Route::middleware('api.token')->group(...)` block, add:
    - `Route::get('/holidays', [HolidayCalendarController::class, 'index']);`
    - `Route::post('/holidays', [HolidayCalendarController::class, 'store']);`
    - `Route::put('/holidays/{id}', [HolidayCalendarController::class, 'update']);`
    - `Route::delete('/holidays/{id}', [HolidayCalendarController::class, 'destroy']);`
  - _Requirements: 6.3, 6.4, 6.5, 6.6_

- [ ] 7. Write backend property-based tests (PHPUnit)
  - Create `backend/tests/Feature/HolidayCalendarPropertyTest.php`
  - Extend `Tests\TestCase`, use `WithFaker`, implement `createUserWithRole()` and `ensureHolidaysSchema()` helpers matching `ApiHardeningTest` patterns
  - Each test runs a loop of ≥ 100 random iterations using a `generateHoliday()` helper
  - Include a comment block at the top of each test referencing the design property number and text

  - [ ]* 7.1 Property test P1 — valid creation round-trip
    - **Property 1: Valid holiday creation round-trip**
    - Generate random valid payloads (random name, valid start_date, random type); POST as admin; GET list; assert returned holiday fields match submitted values
    - **Validates: Requirements 3.4, 9.1**

  - [ ]* 7.2 Property test P2 — end-before-start always rejected
    - **Property 2: End-date-before-start-date is always rejected**
    - Generate random date pairs where end < start; assert both store and update return 422
    - **Validates: Requirements 3.7, 4.5**

  - [ ]* 7.3 Property test P3 — missing required fields always rejected
    - **Property 3: Missing required fields are always rejected**
    - Generate payloads with `name` omitted or `start_date` omitted; assert 422 with field-specific error
    - **Validates: Requirements 3.5, 3.6**

  - [ ]* 7.4 Property test P4 — non-admin write operations always forbidden
    - **Property 4: Non-admin write operations are always forbidden**
    - Randomly pick role from `['teacher', 'parent']`; call store, update, destroy; assert 403 each time
    - **Validates: Requirements 6.3, 6.4, 6.5**

  - [ ]* 7.5 Property test P5 — year filter returns only overlapping holidays
    - **Property 5: Year filter returns only overlapping holidays**
    - Insert holidays with random date ranges; request `?year=Y`; assert every returned holiday overlaps year Y
    - **Validates: Requirements 9.3**

  - [ ]* 7.6 Property test P6 — recurring projection preserves metadata
    - **Property 6: Recurring holiday projection preserves metadata**
    - Insert recurring holiday in year Y₀; request list for Y₁ ≠ Y₀; assert projected entry has same name, type, description and start_date year = Y₁
    - **Validates: Requirements 7.2, 7.3**

  - [ ]* 7.7 Property test P9 — invalid year parameter rejected
    - **Property 9: Invalid year parameter is rejected**
    - Generate non-integer or out-of-range year strings (letters, floats, 3-digit numbers); assert 422
    - **Validates: Requirements 9.4**

  - [ ]* 7.8 Property test P10 — list sorted by start_date ascending
    - **Property 10: List is sorted by start date ascending**
    - Insert random set of holidays; fetch list; assert `start_date` values are non-decreasing
    - **Validates: Requirements 8.1**

  - [ ]* 7.9 Property test P11 — any authenticated user can read the list
    - **Property 11: Any authenticated user can read the holiday list**
    - Randomly pick role from `['admin', 'teacher', 'parent']`; call GET /api/holidays; assert 200
    - **Validates: Requirements 6.6**

- [x] 8. Checkpoint — backend complete
  - Ensure all backend tests pass, ask the user if questions arise.

- [x] 9. Create frontend TypeScript types and holiday API service
  - Create `src/components/holiday-calendar/types.ts`
    - Export `Holiday` interface matching the API response shape from design section 9.1: `id` (number | string), `name`, `type` (union of four values), `start_date`, `end_date` (string | null), `description` (string | null), `image_url` (string | null), `is_recurring` (boolean), `created_at`
    - Export `HOLIDAY_TYPE_COLORS` constant map from the design
    - Export `HolidayType` type alias
  - Create `src/components/holiday-calendar/holidayApi.ts`
    - Export `fetchHolidays(year: number): Promise<Holiday[]>` using `apiClient.get`
    - Export `createHoliday(payload: FormData): Promise<{ id: number; image_url: string | null }>` using `apiClient.postForm`
    - Export `updateHoliday(id: number | string, payload: FormData): Promise<void>` — POST to `/holidays/{id}?_method=PUT` with FormData (Laravel method spoofing) or use `apiClient.put` for JSON-only updates
    - Export `deleteHoliday(id: number | string): Promise<void>` using `apiClient.delete`
  - _Requirements: 9.1, 9.2_

- [x] 10. Implement the Legend component
  - Create `src/components/holiday-calendar/Legend.tsx`
  - Render four color swatches with labels: National, Religious, School, Optional using `HOLIDAY_TYPE_COLORS`
  - Pure presentational component, no props needed
  - _Requirements: 1.8, 2.1, 2.4_

- [x] 11. Implement the CalendarView component
  - Create `src/components/holiday-calendar/CalendarView.tsx`
  - Props: `holidays: Holiday[]`, `year: number`, `month: number` (0-indexed), `onPrevMonth: () => void`, `onNextMonth: () => void`, `onYearChange: (year: number) => void`, `isAdmin: boolean`, `onEdit: (h: Holiday) => void`, `onDelete: (h: Holiday) => void`
  - Render a 7-column CSS grid for the month; compute first-day offset using `new Date(year, month, 1).getDay()`
  - For each day cell, find holidays whose date range includes that day; render a colored dot/bar using `HOLIDAY_TYPE_COLORS[holiday.type]`
  - Multi-day holidays highlight all days within the range (Requirements 1.3, 1.4)
  - Render previous/next month buttons and a year `<select>` spanning ±5 years from current (Requirements 1.5, 1.6, 1.7)
  - Show admin action menu ("...") with Edit/Delete on holiday items only when `isAdmin` is true (Requirements 4.1, 6.1, 6.2)
  - _Requirements: 1.3, 1.4, 1.5, 1.6, 1.7, 4.1, 6.1_

- [x] 12. Implement the ListView component
  - Create `src/components/holiday-calendar/ListView.tsx`
  - Props: `holidays: Holiday[]`, `searchQuery: string`, `isAdmin: boolean`, `onEdit: (h: Holiday) => void`, `onDelete: (h: Holiday) => void`
  - Filter holidays client-side: `holiday.name.toLowerCase().includes(searchQuery.toLowerCase())` (Property 8)
  - Sort filtered list by `start_date` ascending (already sorted from API, but apply locally for safety)
  - Render each holiday row: name, type badge colored with `HOLIDAY_TYPE_COLORS`, date range string, duration computed as `differenceInCalendarDays(endDate, startDate) + 1` (or 1 if no end_date) (Property 7)
  - Show empty state message when filtered list is empty (Requirement 1.11)
  - Show admin action menu ("...") with Edit/Delete on each row only when `isAdmin` is true (Requirements 4.2, 6.2)
  - _Requirements: 1.9, 1.10, 1.11, 2.3, 4.2, 6.2, 8.2, 8.3_

- [x] 13. Implement the AddEditHolidayModal component
  - Create `src/components/holiday-calendar/AddEditHolidayModal.tsx`
  - Props: `open: boolean`, `holiday: Holiday | null` (null = create mode), `onClose: () => void`, `onSaved: (holiday: Holiday) => void`
  - Fields: name (Input), start_date (Input type=date), end_date (Input type=date, optional), type (Select with four options), description (Textarea, optional), image (Input type=file, optional), is_recurring (Switch/Checkbox toggle)
  - Pre-populate all fields when `holiday` is not null (edit mode) (Requirement 4.3)
  - On submit, build `FormData` and call `createHoliday` or `updateHoliday` from `holidayApi.ts`
  - Show toast on success; show field-level validation errors from 422 responses
  - Disable submit button while submitting
  - _Requirements: 3.2, 3.3, 3.8, 3.9, 3.10, 3.11, 4.3, 4.4, 4.6_

- [ ] 14. Write frontend property-based tests (fast-check / vitest)
  - Create `src/test/holidayCalendar.property.test.ts`
  - Import `fc` from `fast-check`; each `fc.assert` runs ≥ 100 samples
  - Include a comment block at the top referencing the design property number and text

  - [ ]* 14.1 Property test P7 — duration is always ≥ 1
    - **Property 7: Duration is always ≥ 1**
    - Use `fc.date()` arbitraries; test `computeDuration(startDate, endDate)` helper exported from `ListView` or `types.ts`; assert result ≥ 1 for all valid date pairs including null end_date
    - **Validates: Requirements 8.3, 9.2**

  - [ ]* 14.2 Property test P8 — search filter is case-insensitive and subset-correct
    - **Property 8: Search filter is case-insensitive and subset-correct**
    - Use `fc.string()` for holiday names and search strings; apply the same filter logic used in `ListView`; assert result contains exactly those holidays whose name contains the search string case-insensitively
    - **Validates: Requirements 1.10, 8.2**

- [x] 15. Implement the HolidayCalendar shared page and wire everything together
  - Create `src/pages/admin/HolidayCalendar.tsx` as the canonical page component (admin route)
  - Create `src/pages/teacher/TeacherHolidayCalendar.tsx` and `src/pages/parent/ParentHolidayCalendar.tsx` as thin wrappers that render the same inner content with their respective `DashboardLayout` and sidebar configs
  - The shared inner logic (or a shared `HolidayCalendarContent` component in `src/components/holiday-calendar/`) owns:
    - `holidays: Holiday[]` state, fetched via `fetchHolidays(currentYear)` on mount and on year change
    - `currentYear: number`, `currentMonth: number` state (default to `new Date()`)
    - `searchQuery: string` state
    - `modalState: { open: boolean; holiday: Holiday | null }` state
    - `isAdmin` derived from `useAuth().userRole === 'admin'`
  - Render `Legend`, `CalendarView`, `ListView` (with search input above it), and `AddEditHolidayModal`
  - Show "+ Add Holiday" button only when `isAdmin` is true (Requirement 3.1, 6.1)
  - On `onSaved` callback from modal: close modal, re-fetch holidays for current year (Requirement 3.11)
  - On `onDelete`: show `window.confirm` prompt; call `deleteHoliday`; re-fetch on confirm (Requirements 5.1, 5.2, 5.3, 5.4)
  - _Requirements: 1.1, 1.2, 3.1, 3.11, 4.6, 5.1, 5.3, 5.4, 6.1, 6.2_

- [x] 16. Register routes and navigation entries
  - In `src/App.tsx`: add imports for `HolidayCalendar`, `TeacherHolidayCalendar`, `ParentHolidayCalendar` and register routes:
    - `<Route path="/admin/holiday-calendar" element={<HolidayCalendar />} />`
    - `<Route path="/teacher/holiday-calendar" element={<TeacherHolidayCalendar />} />`
    - `<Route path="/parent/holiday-calendar" element={<ParentHolidayCalendar />} />`
  - In `src/config/adminSidebar.tsx`: add `{ icon: <CalendarDays />, label: 'Holiday Calendar', path: '/admin/holiday-calendar' }`
  - In `src/config/teacherSidebar.tsx`: add corresponding entry pointing to `/teacher/holiday-calendar`
  - In `src/config/parentSidebar.tsx`: add corresponding entry pointing to `/parent/holiday-calendar`
  - _Requirements: 1.1, 1.2_

- [x] 17. Final checkpoint — Ensure all tests pass
  - Ensure all backend PHPUnit tests and frontend vitest tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Property tests validate universal correctness properties; unit tests validate specific examples and edge cases
- The `computeDuration` helper should be exported from `types.ts` or a `utils` file so both `ListView` and the property test can import it
- For image updates via `PUT`, use `POST /holidays/{id}?_method=PUT` with `FormData` (Laravel method spoofing) since `fetch` cannot send `PUT` with `FormData` directly; alternatively, split image upload into a separate endpoint if preferred
- Virtual IDs for projected recurring holidays (`recurring_{id}_{year}`) are treated as read-only by the frontend; edit/delete actions on them resolve to the original numeric record ID by parsing the string
