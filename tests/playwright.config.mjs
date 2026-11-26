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
import { playwrightOutputDir } from './lib/site-lock.mjs';

// run.mjs runs the site tiers and the advisory visual tier as separate
// invocations; a tag keeps their reports from overwriting each other.
const TAG = process.env.HADRIAN_REPORT_TAG || 'playwright';

export default defineConfig({
  testDir: './e2e',
  // reports/output/<tag>-<pid>: one per invocation, because Playwright empties
  // its outputDir on start and a shared one lost another run's traces.
  // globalSetup (lib/warmup.mjs) takes the site lock and prunes ended runs' folders.
  outputDir: playwrightOutputDir(TAG),
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
      // client-area.spec and order.spec: one test per feature in tests/FEATURES.md (TH-*, OF-*)
      // that needs no setting changed. The ones that do are in theme-settings.spec (settings project).
      // colour-scope.spec measures the panes check-colors-scope-leak.php writes (a local file, no site).
      name: 'browser', testMatch: /(browser|flows|flows-more|sweep|client-area|order|colour-scope)\.spec\.mjs/, dependencies: ['setup'],
      use: { ...devices['Desktop Chrome'], userAgent: USER_AGENT, viewport: { width: 1280, height: 860 } },
    },
    {
      // Mutates the site's settings: run.mjs runs it on its own, never beside smoke/browser.
      // email.spec.mjs belongs here for the same reason: it switches the header
      // of every email the install sends, and the flows tier reads that inbox.
      // admin-uploads.spec.mjs too: a logo upload changes every client page.
      // admin-csrf.spec.mjs saves real settings through the admin screens.
      // builder.spec.mjs creates and publishes pages on the install the other tiers crawl.
      // sitemap.spec.mjs rewrites sitemap.xml and robots.txt in the web root, and puts them back.
      // known-bugs.spec.mjs renames the live guest menu and saves page settings.
      name: 'settings', testMatch: /(settings|email|builder|admin-uploads|admin-csrf|sitemap|known-bugs)\.spec\.mjs/, dependencies: ['setup'],
      use: { ...devices['Desktop Chrome'], userAgent: USER_AGENT, viewport: { width: 1280, height: 860 } },
    },
    {
      // axe-core, WCAG 2.2 A + AA, against tests/e2e/a11y-baseline.json. Switches
      // the stored layout pointers, so like settings it runs on its own, one worker.
      name: 'a11y', testMatch: /a11y\.spec\.mjs/, dependencies: ['setup'],
      use: { ...devices['Desktop Chrome'], userAgent: USER_AGENT, viewport: { width: 1280, height: 860 } },
    },
    {
      name: 'visual', testMatch: /visual\.spec\.mjs/, dependencies: ['setup'],
      use: { ...devices['Desktop Chrome'], userAgent: USER_AGENT, viewport: { width: 1280, height: 860 } },
    },
  ],
});
