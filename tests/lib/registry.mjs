// Every static checker the suite runs, declared IN PLACE.
//
// The existing checkers stay where they live (hadrian/scripts, .dashbuild):
// their own headers, the docs and older notes all refer to those paths, and
// moving them would rot every one of those references. This file only says
// how to run each one and whether a failure should block.
//
//   blocking: true   - a failure fails the run (and the pre-push gate)
//   blocking: false  - reported, never fails the run (heuristics that flag
//                      things for a human, e.g. "class used but not defined")
//   optional: true   - skipped with a note when the file is missing.
//                      .dashbuild/ is not tracked in git, so a fresh checkout
//                      has none of those; the suite must still run there.

import path from 'node:path';
import fs from 'node:fs';
import { REPO_ROOT, PHP, TESTS_DIR } from './env.mjs';

const node = process.execPath;
const HADRIAN = path.join(REPO_ROOT, 'hadrian');

const tplFiles = () => {
  const out = [];
  const walk = d => {
    for (const e of fs.readdirSync(d, { withFileTypes: true })) {
      const p = path.join(d, e.name);
      if (e.isDirectory()) walk(p); else if (e.name.endsWith('.tpl')) out.push(path.relative(REPO_ROOT, p));
    }
  };
  walk(path.join(HADRIAN, 'templates', 'hadrian'));
  walk(path.join(REPO_ROOT, 'hadrian_cart'));
  return out;
};

export const CHECKS = [
  // --- new in tests/ -------------------------------------------------------
  { id: 'css-ascii', title: 'CSS files are ASCII-only', cmd: [node, path.join(TESTS_DIR, 'static', 'css-ascii.mjs')], cwd: REPO_ROOT,
    blocking: true, why: 'Unicode box-drawing in a CSS comment makes Chrome drop whole sections on this install.' },
  { id: 'php-lint', title: 'Addon + theme PHP parses', cmd: [node, path.join(TESTS_DIR, 'static', 'php-lint.mjs')], cwd: REPO_ROOT,
    blocking: true, why: 'A parse error in the addon takes out the admin and every client page that runs its hooks.' },

  // --- hadrian/scripts (tracked) --------------------------------------------
  { id: 'smarty-balance', title: 'Smarty block tags balance', cmd: [node, 'scripts/check-smarty-balance.mjs'], cwd: HADRIAN, blocking: true },
  { id: 'i18n-safety', title: 'Every $hadrianLang key resolves', cmd: () => [node, 'hadrian/scripts/check-i18n-safety.mjs', ...tplFiles()], cwd: REPO_ROOT, blocking: true },
  { id: 'color-defaults', title: 'Admin colour defaults match the CSS', cmd: [node, 'scripts/check-color-defaults.mjs'], cwd: HADRIAN, blocking: true },
  { id: 'free-price', title: '"0.00 -> Free" implementations agree', cmd: [node, 'scripts/check-free-price.mjs'], cwd: HADRIAN, blocking: true },
  { id: 'html-balance', title: 'Container tags balance (heuristic)', cmd: [node, 'scripts/check-html-balance.mjs'], cwd: HADRIAN, blocking: false },
  { id: 'css-classes', title: 'Classes used are defined (heuristic)', cmd: [node, 'scripts/check-css-classes.mjs'], cwd: HADRIAN, blocking: false },

  // --- .dashbuild (untracked, optional) --------------------------------------
  { id: 'smarty-lint', title: 'Admin templates: Smarty safety lint', cmd: [node, '.dashbuild/smarty-lint.mjs'], cwd: REPO_ROOT, blocking: true, optional: '.dashbuild/smarty-lint.mjs' },
  { id: 'admin-js', title: 'Admin inline JS parses', cmd: [node, '.dashbuild/check-admin-js.mjs'], cwd: REPO_ROOT, blocking: true, optional: '.dashbuild/check-admin-js.mjs' },
  { id: 'doc-anchors', title: 'Admin tooltips link to real doc anchors', cmd: [node, '.dashbuild/check-doc-anchors.mjs'], cwd: REPO_ROOT, blocking: true, optional: '.dashbuild/check-doc-anchors.mjs' },
  ...[
    ['announcements', 'Announcements page model'],
    ['colors-panel', 'Colours admin panel'],
    ['colors-scope-leak', 'Colour tokens do not leak across scopes'],
    ['lang-loading', 'Theme language files load'],
    ['layout-dispatch', 'Layout dispatch is data-driven'],
    ['login-styles', 'Login page styles'],
    ['menu-migration-guards', 'Menu migrations are guarded'],
    ['preset-reset', 'Style preset reset'],
    ['savebar-rollout', 'Admin save bar rollout'],
    ['settings-doc-coverage', 'Every setting is documented'],
    ['style-seed', 'Style seed'],
    ['style-swatch', 'Style swatches'],
  ].map(([id, title]) => ({ id, title, cmd: [PHP, `.dashbuild/check-${id}.php`], cwd: REPO_ROOT, blocking: true, optional: `.dashbuild/check-${id}.php` })),
  { id: 'creating-pages', title: 'Custom page creation', cmd: [PHP, '.dashbuild/test-creating-pages.php'], cwd: REPO_ROOT, blocking: true, optional: '.dashbuild/test-creating-pages.php' },
  { id: 'visibility-gate', title: 'Page visibility gate', cmd: [PHP, '.dashbuild/test-visibility-gate.php'], cwd: REPO_ROOT, blocking: true, optional: '.dashbuild/test-visibility-gate.php' },
];

// Tier 2 lives here too so run.mjs treats it like any other check.
export const COMPILE = {
  id: 'smarty-compile', title: 'Every template compiles with WHMCS\'s Smarty',
  cmd: [PHP, path.join(TESTS_DIR, 'compile', 'compile-all.php')], cwd: REPO_ROOT, blocking: true,
  why: 'A template that fails to compile renders an EMPTY content area with HTTP 200 and no error text.',
};
