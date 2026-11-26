// The light-only colour block must not reach dark mode or a ?palette preview.
//
// tests/static/check-colors-scope-leak.php builds four panes from the theme's
// real CSS plus the block Hooks::buildColorsHead emits for a light override
// with no dark counterpart. It used to leave the measuring to a person, and
// from 2026-08-21 to 2026-11-25 it read stylesheets that had been renamed, so
// every pane it wrote carried no theme CSS (bug 6 in tests/FEATURES.md). This
// measures the panes, so the check can fail on its own.
//
// Needs no site: the page is a local file.

import { test, expect } from '@playwright/test';
import { spawnSync } from 'node:child_process';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { PHP, TESTS_DIR, LOCAL_DIR } from '../lib/env.mjs';

// The overrides the checker saves for the light scope only.
const LIGHT_TEXT = 'rgb(29, 29, 33)';     // --sidebar-text: #1d1d21
const LIGHT_ACCENT = '#7c3aed';           // --color-accent

test('a light-only colour override stays out of dark mode and ?palette previews', async ({ page }) => {
  const r = spawnSync(PHP, [path.join(TESTS_DIR, 'static', 'check-colors-scope-leak.php')], { encoding: 'utf8' });
  expect(r.status, r.stdout + r.stderr).toBe(0);

  await page.goto(pathToFileURL(path.join(LOCAL_DIR, 'adminpreview', 'scopeleak.html')).href);
  const panes = Object.fromEntries(await page.$$eval('.probe', probes => probes.map(p => {
    const host = getComputedStyle(p.querySelector('.host'));
    return [p.dataset.case, {
      text: getComputedStyle(p.querySelector('.sidebar-item')).color,
      accent: host.getPropertyValue('--color-accent').trim(),
    }];
  })));

  expect(Object.keys(panes), 'the four panes').toEqual(['light', 'dark', 'light + ?palette', 'dark + ?palette']);
  expect(panes.light, 'the override applies where it was saved').toMatchObject({ text: LIGHT_TEXT, accent: LIGHT_ACCENT });
  for (const name of ['dark', 'light + ?palette', 'dark + ?palette']) {
    expect(panes[name].text, `${name}: sidebar text is not the light override`).not.toBe(LIGHT_TEXT);
    expect(panes[name].accent, `${name}: accent is not the light override`).not.toBe(LIGHT_ACCENT);
    expect(panes[name].accent, `${name}: the theme CSS defined an accent at all`).not.toBe('');
  }
});
