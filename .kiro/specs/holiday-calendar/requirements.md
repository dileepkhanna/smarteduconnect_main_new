# Requirements Document

## Introduction

The Holiday Calendar feature provides a centralized view of school holidays for all users of the school management app. Admins can create, edit, and delete holidays with type classification, date ranges, optional images, and a recurring flag. Teachers and Parents/Students can view the holiday calendar in both a monthly calendar view and a searchable list view. Holidays are color-coded by type (National, Religious, School, Optional) and visible to all authenticated users.

## Glossary

- **Holiday_Calendar**: The feature module that displays and manages school holidays.
- **Holiday**: A named school non-working day or period with a type, start date, optional end date, and optional metadata.
- **Holiday_Type**: One of four classifications: National, Religious, School, or Optional.
- **Recurring_Holiday**: A holiday that automatically repeats on the same calendar date each year.
- **Admin**: A user with the `admin` role who has full create/edit/delete access to holidays.
- **Teacher**: A user with the `teacher` role who has read-only access to the holiday calendar.
- **Parent_Student**: A user with the `parent` role who has read-only access to the holiday calendar.
- **Calendar_View**: A monthly grid display of holidays highlighted by type color.
- **List_View**: A searchable, scrollable list of holidays showing name, type badge, date range, and duration.
- **Holiday_API**: The RESTful JSON API under `/api` that serves holiday data.
- **Duration**: The number of calendar days spanned by a holiday, inclusive of start and end dates.

## Requirements

### Requirement 1: View Holiday Calendar

**User Story:** As a Teacher or Parent/Student, I want to view the school holiday calendar, so that I can plan around non-working days.

#### Acceptance Criteria

1. THE Holiday_Calendar SHALL display holidays in both a Calendar_View and a List_View simultaneously.
2. WHEN a user navigates to the Holiday_Calendar page, THE Holiday_Calendar SHALL load and display all holidays for the current academic year.
3. THE Calendar_View SHALL render a monthly grid with each holiday's start date highlighted using the color associated with its Holiday_Type.
4. WHEN a holiday spans multiple days, THE Calendar_View SHALL highlight all days within the date range using the holiday's type color.
5. THE Calendar_View SHALL provide previous and next month navigation controls.
6. WHEN a user clicks a month navigation control, THE Calendar_View SHALL update to display the selected month without a full page reload.
7. THE Calendar_View SHALL display a year selector allowing navigation between years.
8. THE Holiday_Calendar SHALL display a legend mapping each Holiday_Type to its corresponding color.
9. THE List_View SHALL display each holiday with its name, Holiday_Type badge, date range, and Duration.
10. WHEN a user enters text in the List_View search field, THE List_View SHALL filter displayed holidays to those whose name contains the search text, case-insensitively.
11. WHEN no holidays match the search text, THE List_View SHALL display an empty state message.

### Requirement 2: Holiday Type Color Coding

**User Story:** As any user, I want holidays to be visually distinguished by type, so that I can quickly identify the nature of each holiday.

#### Acceptance Criteria

1. THE Holiday_Calendar SHALL assign a distinct color to each Holiday_Type: National, Religious, School, and Optional.
2. THE Calendar_View SHALL render holiday highlights using the color of the holiday's Holiday_Type.
3. THE List_View SHALL render each holiday's type as a color-coded badge matching the Holiday_Type color.
4. THE Holiday_Calendar SHALL display a legend panel listing all four Holiday_Types with their associated colors.

### Requirement 3: Admin — Create Holiday

**User Story:** As an Admin, I want to create new holidays, so that the calendar reflects the school's official holiday schedule.

#### Acceptance Criteria

1. WHEN an Admin is authenticated, THE Holiday_Calendar SHALL display an "+ Add Holiday" button.
2. WHEN an Admin clicks "+ Add Holiday", THE Holiday_Calendar SHALL open a modal form with fields for Holiday Name, Start Date, End Date, Holiday_Type, Description, Holiday Image, and Recurring Holiday toggle.
3. THE Holiday_API SHALL require Holiday Name and Start Date; End Date, Description, Holiday Image, and Recurring Holiday SHALL be optional.
4. WHEN an Admin submits the form with a valid Holiday Name and Start Date, THE Holiday_API SHALL create the holiday record and return HTTP 201.
5. WHEN an Admin submits the form with Holiday Name missing, THE Holiday_API SHALL return HTTP 422 with a validation error identifying the missing field.
6. WHEN an Admin submits the form with Start Date missing, THE Holiday_API SHALL return HTTP 422 with a validation error identifying the missing field.
7. WHEN an Admin submits the form with an End Date that is before the Start Date, THE Holiday_API SHALL return HTTP 422 with a validation error.
8. WHEN an Admin submits the form with Holiday_Type set to one of the four valid values, THE Holiday_API SHALL store the Holiday_Type value.
9. WHEN an Admin uploads a Holiday Image, THE Holiday_API SHALL store the image and return its URL in the holiday record.
10. WHEN an Admin enables the Recurring Holiday toggle, THE Holiday_API SHALL store the holiday with `is_recurring` set to true.
11. WHEN a holiday is successfully created, THE Holiday_Calendar SHALL close the modal and add the new holiday to both the Calendar_View and List_View without a full page reload.

### Requirement 4: Admin — Edit Holiday

**User Story:** As an Admin, I want to edit existing holidays, so that I can correct or update holiday details.

#### Acceptance Criteria

1. WHEN an Admin views the Calendar_View, THE Holiday_Calendar SHALL display an action menu ("...") on each holiday item.
2. WHEN an Admin views the List_View, THE Holiday_Calendar SHALL display an action menu ("...") on each holiday row.
3. WHEN an Admin selects "Edit" from a holiday's action menu, THE Holiday_Calendar SHALL open the edit modal pre-populated with the holiday's current values.
4. WHEN an Admin submits the edit form with valid data, THE Holiday_API SHALL update the holiday record and return HTTP 200.
5. WHEN an Admin submits the edit form with an End Date before the Start Date, THE Holiday_API SHALL return HTTP 422 with a validation error.
6. WHEN a holiday is successfully updated, THE Holiday_Calendar SHALL reflect the updated values in both the Calendar_View and List_View without a full page reload.

### Requirement 5: Admin — Delete Holiday

**User Story:** As an Admin, I want to delete holidays, so that I can remove incorrect or cancelled holidays from the calendar.

#### Acceptance Criteria

1. WHEN an Admin selects "Delete" from a holiday's action menu, THE Holiday_Calendar SHALL display a confirmation prompt before deletion.
2. WHEN an Admin confirms deletion, THE Holiday_API SHALL delete the holiday record and return HTTP 200.
3. WHEN a holiday is successfully deleted, THE Holiday_Calendar SHALL remove the holiday from both the Calendar_View and List_View without a full page reload.
4. WHEN an Admin cancels the deletion prompt, THE Holiday_Calendar SHALL dismiss the prompt and leave the holiday unchanged.

### Requirement 6: Role-Based Access Control

**User Story:** As a system operator, I want holiday management actions to be restricted to Admins, so that Teachers and Parents/Students cannot modify the holiday schedule.

#### Acceptance Criteria

1. WHEN a Teacher or Parent_Student is authenticated, THE Holiday_Calendar SHALL NOT display the "+ Add Holiday" button.
2. WHEN a Teacher or Parent_Student is authenticated, THE Holiday_Calendar SHALL NOT display edit or delete action menus on holiday items.
3. WHEN a non-Admin user calls the Holiday_API create endpoint, THE Holiday_API SHALL return HTTP 403.
4. WHEN a non-Admin user calls the Holiday_API update endpoint, THE Holiday_API SHALL return HTTP 403.
5. WHEN a non-Admin user calls the Holiday_API delete endpoint, THE Holiday_API SHALL return HTTP 403.
6. WHEN any authenticated user calls the Holiday_API list endpoint, THE Holiday_API SHALL return HTTP 200 with the holiday list.

### Requirement 7: Recurring Holidays

**User Story:** As an Admin, I want to mark holidays as recurring, so that annual holidays automatically appear in future years without manual re-entry.

#### Acceptance Criteria

1. THE Holiday_API SHALL store a boolean `is_recurring` field on each holiday record.
2. WHEN the Holiday_Calendar loads holidays for a given year, THE Holiday_API SHALL include recurring holidays from any prior year projected to the requested year's equivalent date.
3. WHEN a recurring holiday is projected to a future year, THE Holiday_Calendar SHALL display it with the same name, type, and description as the original.
4. WHEN an Admin edits a recurring holiday, THE Holiday_Calendar SHALL prompt the Admin to choose whether to edit only the current instance or all future occurrences.

### Requirement 8: Holiday List Filtering and Sorting

**User Story:** As any user, I want to filter and browse holidays in the List_View, so that I can quickly find specific holidays.

#### Acceptance Criteria

1. THE List_View SHALL display holidays sorted by Start Date in ascending order by default.
2. WHEN a user searches by name, THE List_View SHALL return only holidays whose name contains the search string, case-insensitively.
3. THE List_View SHALL display the Duration of each holiday as the number of calendar days (inclusive of start and end dates; a single-day holiday has Duration of 1).

### Requirement 9: Holiday API Data Contract

**User Story:** As a frontend developer, I want a consistent API response shape for holidays, so that the UI can reliably render holiday data.

#### Acceptance Criteria

1. THE Holiday_API list endpoint SHALL return an array of holiday objects each containing: `id`, `name`, `type`, `start_date`, `end_date` (nullable), `description` (nullable), `image_url` (nullable), `is_recurring`, `created_at`.
2. WHEN the Holiday_API returns a holiday with a null `end_date`, THE Holiday_Calendar SHALL treat the holiday as a single-day event on `start_date`.
3. THE Holiday_API SHALL accept `year` as an optional query parameter on the list endpoint; WHEN provided, THE Holiday_API SHALL return only holidays whose date range overlaps the specified calendar year.
4. IF the `year` query parameter is not a valid four-digit integer, THEN THE Holiday_API SHALL return HTTP 422 with a validation error.
