import { expect, test } from '@playwright/test';
import { expectPath, loginAsParent } from './helpers/auth';
import path from 'path';
import fs from 'fs';
import os from 'os';

test.describe('Fee Receipt Download', () => {
  test.beforeEach(async ({ page }) => {
    await loginAsParent(page, 'vikas-1-a', '123456');
    await expectPath(page, '/parent');
  });

  test('fee page loads with fee records', async ({ page }) => {
    await page.goto('/parent/fees');
    await page.waitForLoadState('networkidle');

    // Page should show fee section
    await expect(page.getByText('Fee Payment').first()).toBeVisible({ timeout: 15000 });
    await expect(page.getByText('Fee Details').first()).toBeVisible();
  });

  test('download receipt button is visible for paid fees', async ({ page }) => {
    await page.goto('/parent/fees');
    await page.waitForLoadState('networkidle');

    // Wait for fees to load
    await page.waitForTimeout(2000);

    const receiptBtn = page.getByRole('button', { name: /receipt/i }).first();
    const downloadBtn = page.getByRole('button', { name: /download receipt/i }).first();

    const hasPaidFee = (await receiptBtn.count()) > 0 || (await downloadBtn.count()) > 0;

    if (!hasPaidFee) {
      test.skip(true, 'No paid fees found for this parent — skipping receipt download test');
      return;
    }

    const btn = (await receiptBtn.count()) > 0 ? receiptBtn : downloadBtn;
    await expect(btn).toBeVisible();
  });

  test('clicking receipt button triggers PDF download', async ({ page }) => {
    await page.goto('/parent/fees');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(2000);

    const receiptBtn = page.getByRole('button', { name: /receipt/i }).first();
    const downloadBtn = page.getByRole('button', { name: /download receipt/i }).first();

    const hasReceipt = (await receiptBtn.count()) > 0 || (await downloadBtn.count()) > 0;
    if (!hasReceipt) {
      test.skip(true, 'No paid fees found — skipping');
      return;
    }

    const btn = (await receiptBtn.count()) > 0 ? receiptBtn : downloadBtn;

    // Listen for download event
    const [download] = await Promise.all([
      page.waitForEvent('download', { timeout: 10000 }),
      btn.click(),
    ]);

    const suggestedFilename = download.suggestedFilename();
    expect(suggestedFilename).toMatch(/^Receipt_.*\.pdf$/i);

    // Save and verify file is non-empty
    const tmpPath = path.join(os.tmpdir(), suggestedFilename);
    await download.saveAs(tmpPath);

    const stats = fs.statSync(tmpPath);
    expect(stats.size).toBeGreaterThan(1000); // PDF should be at least 1KB

    // Verify PDF header magic bytes
    const buf = Buffer.alloc(5);
    const fd = fs.openSync(tmpPath, 'r');
    fs.readSync(fd, buf, 0, 5, 0);
    fs.closeSync(fd);
    expect(buf.toString('ascii')).toBe('%PDF-');

    fs.unlinkSync(tmpPath);
  });

  test('payment history section shows download buttons', async ({ page }) => {
    await page.goto('/parent/fees');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(2000);

    const historySection = page.getByText('Payment History').first();
    if ((await historySection.count()) === 0) {
      test.skip(true, 'No payment history found — skipping');
      return;
    }

    await expect(historySection).toBeVisible();

    // Each payment history item should have a download button
    const historyDownloadBtns = page.locator('.shrink-0').filter({ has: page.locator('svg') });
    expect(await historyDownloadBtns.count()).toBeGreaterThan(0);
  });

  test('receipt API endpoint returns template', async ({ page }) => {
    // Intercept the template API call
    const [response] = await Promise.all([
      page.waitForResponse(res => res.url().includes('/settings/receipt-template') && res.status() === 200),
      page.goto('/parent/fees'),
    ]);

    const body = await response.json();
    expect(body).toHaveProperty('template');
  });
});
