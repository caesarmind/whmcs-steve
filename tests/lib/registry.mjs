// Every static checker the suite runs, declared IN PLACE.
//
// Two homes. hadrian/scripts holds the theme's own checkers, whose headers and
// docs refer to that path. tests/static holds the ones written for the suite,
// plus the seventeen that lived in the untracked .dashbuild/ scratch folder
// until 2026-10-28 - a fresh checkout used to skip those with a note, which
// left 17 of the 25 static checks visible on one machine only. Every checker
// is tracked now; this file only says how to run each one and whether a
// failure should block.
//
//   blocking: true   - a failure fails the run (and the pre-push gate)
//   blocking: false  - reported, never fails the run (heuristics that flag
//                      things for a human, e.g. "class used but not defined")

import path from 'node:path';
import fs from 'node:fs';
import { REPO_ROOT, PHP, TESTS_DIR } from './env.mjs';

const node = process.execPath;
const HADRIAN = path.join(REPO_ROOT, 'hadrian');
const STATIC = f => path.join(TESTS_DIR, 'static', f);

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
  // --- tests/static ----------------------------------------------------------
  { id: 'css-ascii', title: 'CSS files are ASCII-only', cmd: [node, STATIC('css-ascii.mjs')], cwd: REPO_ROOT,
    blocking: true, why: 'Unicode box-drawing in a CSS comment makes Chrome drop whole sections on this install.' },
  { id: 'php-lint', title: 'Addon + theme PHP parses', cmd: [node, STATIC('php-lint.mjs')], cwd: REPO_ROOT,
    blocking: true, why: 'A parse error in the addon takes out the admin and every client page that runs its hooks.' },
  { id: 'foreach-props', title: 'Loop properties name a foreach item', cmd: [node, STATIC('check-foreach-props.mjs')], cwd: REPO_ROOT,
    blocking: true, why: '$key@iteration is undefined: the plan cards never applied their "first 4 features" cap, and WHMCS logged a warning per feature.' },
  { id: 'whmcs-lang-keys', title: 'WHMCS $LANG keys exist as used', cmd: [PHP, STATIC('check-whmcs-lang-keys.php')], cwd: REPO_ROOT,
    blocking: true, why: 'A missing key prints nothing and a group prints Array: the markdown guide asked for flat keys and all 27 of its strings were blank.' },
  { id: 'form-contracts', title: 'Forms post what WHMCS reads (vs stock)', cmd: [node, STATIC('check-form-contracts.mjs')], cwd: REPO_ROOT,
    blocking: true, why: 'The 2FA challenge posted to itself (405: nobody with 2FA could sign in); the card form used field names WHMCS ignores.' },
  { id: 'coverage-manifest', title: 'Every page/variant/cart tpl is tested or listed', cmd: [node, STATIC('check-coverage.mjs')], cwd: REPO_ROOT,
    blocking: true, why: 'A new page or variant must not ship without a decision on how it is tested (tests/e2e/coverage.mjs).' },

  // --- hadrian/scripts (tracked) --------------------------------------------
  { id: 'smarty-balance', title: 'Smarty block tags balance', cmd: [node, 'scripts/check-smarty-balance.mjs'], cwd: HADRIAN, blocking: true },
  { id: 'i18n-safety', title: 'Every $hadrianLang key resolves', cmd: () => [node, 'hadrian/scripts/check-i18n-safety.mjs', ...tplFiles()], cwd: REPO_ROOT, blocking: true },
  { id: 'color-defaults', title: 'Admin colour defaults match the CSS', cmd: [node, 'scripts/check-color-defaults.mjs'], cwd: HADRIAN, blocking: true },
  { id: 'free-price', title: '"0.00 -> Free" implementations agree', cmd: [node, 'scripts/check-free-price.mjs'], cwd: HADRIAN, blocking: true },
  { id: 'html-balance', title: 'Container tags balance (heuristic)', cmd: [node, 'scripts/check-html-balance.mjs'], cwd: HADRIAN, blocking: false },
  { id: 'css-classes', title: 'Classes used are defined (heuristic)', cmd: [node, 'scripts/check-css-classes.mjs'], cwd: HADRIAN, blocking: false },

  // --- tests/static, moved in from .dashbuild on 2026-10-28 ------------------
  // Four of these (colors-panel, login-styles, savebar-rollout, creating-pages)
  // render through the Smarty that `composer install -d tests/static` provides;
  // the preflight checks for it.
  { id: 'smarty-lint', title: 'Admin templates: Smarty safety lint', cmd: [node, STATIC('smarty-lint.mjs')], cwd: REPO_ROOT, blocking: true },
  { id: 'admin-js', title: 'Admin inline JS parses', cmd: [node, STATIC('check-admin-js.mjs')], cwd: REPO_ROOT, blocking: true },
  { id: 'doc-anchors', title: 'Admin tooltips link to real doc anchors', cmd: [node, STATIC('check-doc-anchors.mjs')], cwd: REPO_ROOT, blocking: true,
    why: 'Rebuilds hadrian-documentation/dist first, so a renamed heading fails here instead of dropping the reader at the top of the page.' },
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
  ].map(([id, title]) => ({ id, title, cmd: [PHP, STATIC(`check-${id}.php`)], cwd: REPO_ROOT, blocking: true })),
  { id: 'creating-pages', title: 'Custom page creation', cmd: [PHP, STATIC('test-creating-pages.php')], cwd: REPO_ROOT, blocking: true },
  { id: 'visibility-gate', title: 'Page visibility gate', cmd: [PHP, STATIC('test-visibility-gate.php')], cwd: REPO_ROOT, blocking: true },

  // Hadrian Email Templates: a separate addon module (hadrian_email/) that
  // requires Hadrian. Its live checks (takeover, publish, real mail) are in
  // the settings tier: e2e/email.spec.mjs.
  { id: 'email-engine', title: 'Email module: engine', cmd: [PHP, STATIC('test-email-engine.php')], cwd: REPO_ROOT, blocking: true,
    why: 'Merge-field handling, the sanitiser, document validation, colours and the renderer, with no WHMCS.' },
  { id: 'email-smarty-lint', title: 'Email module: Smarty safety lint', cmd: [node, STATIC('smarty-lint.mjs'), 'hadrian_email/modules/addons/HadrianEmail/views'], cwd: REPO_ROOT, blocking: true },
  { id: 'email-builder-js', title: 'Email module: builder script parses', cmd: [node, '--check', 'hadrian_email/modules/addons/HadrianEmail/views/assets/js/email-builder.js'], cwd: REPO_ROOT, blocking: true,
    why: 'The script is inlined into the page by PHP, so check-admin-js never sees its source.' },

  // Add-on products are written from scratch. Lagom is a behaviour reference
  // that stays outside the repo; this catches a paste from it.
  { id: 'no-lagom', title: 'Product modules carry no Lagom code', cmd: [node, STATIC('check-no-lagom.mjs')], cwd: REPO_ROOT, blocking: true,
    why: 'Lagom\'s namespace, table names and data keys in a product folder mean code was copied instead of written.' },
];

// Tier 2 lives here too so run.mjs treats it like any other check.
export const COMPILE = {
  id: 'smarty-compile', title: 'Every template compiles with WHMCS\'s Smarty',
  cmd: [PHP, path.join(TESTS_DIR, 'compile', 'compile-all.php')], cwd: REPO_ROOT, blocking: true,
  why: 'A template that fails to compile renders an EMPTY content area with HTTP 200 and no error text.',
};
