import { expect, test } from '@playwright/test';
import { expectPath, loginAsParent, loginAsStaff } from './helpers/auth';

test.describe('Authentication smoke', () => {
  test('admin can log in and land on admin dashboard', async ({ page }) => {
    await loginAsStaff(page, 'admin@school.com', 'admin123');
    await expectPath(page, '/admin');
    await expect(page.getByText('Total Students').first()).toBeVisible();
  });

  test('teacher can log in and land on teacher dashboard', async ({ page }) => {
    await loginAsStaff(page, 'dileep-science', '123456');
    await expectPath(page, '/teacher');
    await expect(page.getByText('Mark Attendance').first()).toBeVisible();
  });

  test('student or parent can log in and land on parent dashboard', async ({ page }) => {
    await loginAsParent(page, 'vikas-1-a', '123456');
    await expectPath(page, '/parent');
    await expect(page.getByText('Welcome, Parent!').first()).toBeVisible();
  });
});
