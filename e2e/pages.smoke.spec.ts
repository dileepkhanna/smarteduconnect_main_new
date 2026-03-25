import { expect, test } from '@playwright/test';
import { expectPath, loginAsParent, loginAsStaff } from './helpers/auth';

test.describe('Critical page smoke', () => {
  test('admin fees page loads and receipt settings dialog opens', async ({ page }) => {
    await loginAsStaff(page, 'admin@school.com', 'admin123');
    await page.goto('/admin/fees');
    await expectPath(page, '/admin/fees');
    await expect(page.getByText('Fees Management')).toBeVisible();
    await expect(page.getByText('Track and manage student fees')).toBeVisible();
    await page.getByRole('button', { name: /Receipt Settings|Receipt/i }).click();
    await expect(page.getByText('Receipt Template Settings')).toBeVisible();
    await expect(page.getByText('Show Logo on Receipt')).toBeVisible();
  });

  test('teacher attendance page loads with save controls', async ({ page }) => {
    await loginAsStaff(page, 'dileep-science', '123456');
    await page.goto('/teacher/attendance');
    await expectPath(page, '/teacher/attendance');
    await expect(page.getByText('Mark Attendance')).toBeVisible();
    await expect(page.getByPlaceholder('Search student...')).toBeVisible();
    await expect(page.getByRole('button', { name: 'Save' })).toBeVisible();
  });

  test('parent fees page loads', async ({ page }) => {
    await loginAsParent(page, 'vikas-1-a', '123456');
    await page.goto('/parent/fees');
    await expectPath(page, '/parent/fees');
    await expect(page.getByText(/Fees/i).first()).toBeVisible();
  });
});
