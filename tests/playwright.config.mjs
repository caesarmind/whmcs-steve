// Playwright drives every tier that talks to the running site:
//
//   setup    - logs each persona + the test admin in over HTTP, saves the
//              session to .local/auth/<name>.json (no browser involved)
//   smoke    - HTTP-level: every route x persona, HTML oracles. Fast.
//   browser  - real Chromium: console errors, failed assets, layouts, flows.
//   visual   - screenshot comparison against approved baselines. ADVISORY:
//              run.mjs runs it separately and never fails on it.
//
// run.mjs is the entry point; it runs the preflight first. Running
// `npx playwright test` directly skips that, which is fine while iterating.

import { defineConfig, devices } from '@playwright/test';
import path from 'node:path';
import { BASE_URL, USER_AGENT, LOCAL_DIR, REPORTS_DIR } from './lib/env.mjs';

// run.mjs runs the site tiers and the advisory visual tier as separate
// invocations; a tag keeps their reports from overwriting each other.
const TAG = process.env.HADRIAN_REPORT_TAG || 'playwright';

export default defineConfig({
  testDir: './e2e',
  outputDir: path.join(REPORTS_DIR, `${TAG}-artifacts`),
  timeout: 60_000,
  expect: { timeout: 10_000 },
  fullyParallel: true,
  // WHMCS on a single mod_php Apache: more than this and requests queue
  // behind each other, which reads as flaky timeouts rather than as speed.
  workers: 4,
  retries: 0,
  reporter: [
    ['list'],
    ['html', { outputFolder: path.join(REPORTS_DIR, TAG), open: 'never' }],
    ['json', { outputFile: path.join(REPORTS_DIR, `${TAG}.json`) }],
  ],
  use: {
    baseURL: BASE_URL,
    userAgent: USER_AGENT,
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
    ignoreHTTPSErrors: true,
  },
  globalSetup: './lib/warmup.mjs',
  snapshotPathTemplate: path.join(LOCAL_DIR, 'visual', '{testFilePath}', '{arg}{ext}'),
  projects: [
    { name: 'setup', testMatch: /auth\.setup\.mjs/ },
    { name: 'smoke', testMatch: /(smoke|admin|links)\.spec\.mjs/, dependencies: ['setup'] },
    {
      name: 'browser', testMatch: /(browser|flows|flows-more|sweep)\.spec\.mjs/, dependencies: ['setup'],
      use: { ...devices['Desktop Chrome'], userAgent: USER_AGENT, viewport: { width: 1280, height: 860 } },
    },
    {
      // Mutates the site's settings: run.mjs runs it on its own, never beside smoke/browser.
      name: 'settings', testMatch: /settings\.spec\.mjs/, dependencies: ['setup'],
      use: { ...devices['Desktop Chrome'], userAgent: USER_AGENT, viewport: { width: 1280, height: 860 } },
    },
    {
      name: 'visual', testMatch: /visual\.spec\.mjs/, dependencies: ['setup'],
      use: { ...devices['Desktop Chrome'], userAgent: USER_AGENT, viewport: { width: 1280, height: 860 } },
    },
  ],
});
