import { expect, Page } from '@playwright/test';

export async function loginAsStaff(page: Page, identifier: string, password: string) {
  await page.goto('/auth');
  await page.getByRole('button', { name: 'Staff Login' }).click();
  await page.getByLabel('Email or Teacher ID').fill(identifier);
  await page.getByLabel('Password').fill(password);
  await page.getByRole('button', { name: 'Sign In' }).click();
}

export async function loginAsParent(page: Page, studentId: string, password: string) {
  await page.goto('/auth');
  await page.getByRole('button', { name: 'Parent / Student' }).click();
  await page.getByLabel('Student ID / Admission Number').fill(studentId);
  await page.getByLabel('Password').fill(password);
  await page.getByRole('button', { name: 'Sign In' }).click();
}

export async function expectPath(page: Page, pathPrefix: string) {
  await page.waitForURL(new RegExp(`${pathPrefix.replace('/', '\\/')}.*`));
  await expect(page).toHaveURL(new RegExp(`${pathPrefix.replace('/', '\\/')}.*`));
}
