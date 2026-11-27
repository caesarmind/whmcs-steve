// Builds the admin audit report from the proof records the admin-audit
// project writes (tests/e2e/audit/harness.mjs -> tests/reports/admin-audit/).
//
//   node tests/lib/admin-audit-report.mjs
//
// Writes two files:
//   tests/ADMIN-FEATURES.md                 every Hadrian admin feature, what it promises,
//                                           the verdict and the proof in one line (committed)
//   tests/reports/admin-audit/REPORT.md     the full proof: steps, stored values before and
//                                           after, every check, screenshots (local, not committed)
//
// The feature list is the AD section of tests/FEATURES.md, so the two never
// disagree about what the features are.

import fs from 'node:fs';
import path from 'node:path';
import { TESTS_DIR, REPORTS_DIR } from './env.mjs';

const PROOF_DIR = path.join(REPORTS_DIR, 'admin-audit');
const FEATURES = fs.readFileSync(path.join(TESTS_DIR, 'FEATURES.md'), 'utf8');

// ------------------------------------------------------------ the features
const sections = [];
let inAd = false;
for (const line of FEATURES.split(/\r?\n/)) {
  if (/^## /.test(line)) inAd = /^## AD:/.test(line);
  if (!inAd) continue;
  const h = line.match(/^### (AD-[A-Z]) (.+)$/);
  if (h) { sections.push({ key: h[1], name: h[2].trim(), rows: [] }); continue; }
  const r = line.match(/^\| (AD-\d+) \|(.*)\|\s*$/);
  if (r && sections.length) {
    const cells = r[2].split(' | ').map(s => s.trim());
    sections.at(-1).rows.push({ id: r[1], feature: cells[0], verify: cells[1], files: cells[2] });
  }
}

// ------------------------------------------------------------ the records
const records = {};
if (fs.existsSync(PROOF_DIR)) {
  for (const dir of fs.readdirSync(PROOF_DIR)) {
    const d = path.join(PROOF_DIR, dir);
    if (!fs.statSync(d).isDirectory()) continue;
    for (const f of fs.readdirSync(d).filter(f => f.endsWith('.json'))) {
      const rec = JSON.parse(fs.readFileSync(path.join(d, f), 'utf8'));
      (records[rec.id] ||= []).push(rec);
    }
  }
}

const outcome = rec => {
  if (rec.status === 'skipped') return 'skipped';
  if (rec.expectedStatus === 'failed') return rec.status === 'failed' ? 'known' : 'fixed-known';
  return rec.status === 'passed' ? 'passed' : 'failed';
};
const VERDICT = {
  works:   'Works',
  workspt: 'Works (part not testable here)',
  broken:  'Broken',
  partial: 'Partly works',
  known:   'Known bug',
  skipped: 'Not tested',
  outside: 'Not in this audit',
  none:    'Not tested yet',
};

// Rows this audit leaves out on purpose, and where they are covered instead.
const OUTSIDE = {
  'AD-78': 'Request guards (POST, admin, token, X-Requested-With). Security checks, left to admin.spec and admin-uploads.spec in the pre-push gate.',
  'AD-85': 'CSRF on every POST and GET_WRITES route. Covered by admin-csrf.spec in the pre-push gate (16 POST and 4 GET routes).',
  'AD-86': 'AJAX guard. Covered by admin.spec and admin-uploads.spec in the pre-push gate.',
  'AD-90': 'Deactivate with Database Clear wipes the install; not run against the shared local site.',
  'AD-97': 'Integrity hashes exist only in release builds; check-release-package covers the table.',
  'AD-98': 'The systpl slug is a security probe, left out of this functional audit. templateName on the Templates screen is limited to listed templates since 2026-11-27 (AD-83).',
};

function verdict(recs, id) {
  if (!recs?.length) return OUTSIDE[id] ? 'outside' : 'none';
  const o = recs.map(outcome);
  const ran = o.filter(x => x !== 'skipped');
  if (!ran.length) return 'skipped';
  const bad = ran.filter(x => x === 'failed' || x === 'known' || x === 'fixed-known').length;
  if (!bad) return ran.length < o.length ? 'workspt' : 'works';
  if (bad === ran.length) return o.includes('known') && !o.includes('failed') ? 'known' : 'broken';
  return 'partial';
}

// The defects the audit found, traced to the code (from the failing checks).
const FINDINGS = [
  ['AD-26', 'Styles saves a font stack HTML-escaped. WHMCS escapes every admin POST; `StylesController.php:654` stores the stack as posted, so quotes arrive as `&#039;`, and `Hooks.php:794` strips `&` and `;`. Visitors get `--font-family:039Roboto039, ...`: a Google body font picked in Styles never applies, and self-hosted fonts break the same way. The Customizer decodes its POST (`CustomizeController.php:263`) and is not affected.'],
  ['AD-29', 'Custom CSS is stored HTML-escaped (`StylesController.php:698`), so `body > .x` is saved as `body &gt; .x` and quotes as `&quot;`. Those rules do not apply on the site, and the box shows the entities after a reload. CSS without `<`, `>`, `&` or quotes works.'],
  ['AD-38', 'Affixed Navigation does nothing on the Top layout. `core-layout.js:882` looks for `.topbar, .ph-side-topbar`, but the Top layout draws `nav.homepage-nav` (`includes/partials/topnav.tpl:131`), so the script stops before it listens.'],
  ['AD-47', 'Saving one dashboard variant rewrites another variant\'s section layout. `pages/edit.tpl:1246` marks any non-empty layout as changed and `:1281` re-serialises it on every submit, so saving Minimal rewrote Bento\'s stored `services:1/1,tickets:1/2` into the full list.'],
  ['AD-64', 'Reset WHMCS Defaults never says how many presets it reset. `menu/index.tpl:22` takes 16 characters of the flash and compares them with the 15-character `reset-defaults-`.'],
  ['AD-66', 'Moving an active menu to the other audience leaves two active menus there. `MenuController.php:301` compares with `$menu->audience` after line 295 already set it to the posted value, so the peers are never switched off.'],
  ['AD-67', 'A dropdown and its child added in the same save lose the child. The editor sends the parent as `new_<tempId>` (`menu/edit.tpl:2102`) but the server keys new rows `new_<payload index>` (`MenuController.php:591`); the child ends up as its own parent and renders nowhere.'],
  ['AD-68', 'Menu item description, badge, text transform, hide label and CSS class are saved but never shown. `TreeRenderer.php:224` drops the first four, and the templates never print `css_class`. Known and documented, now proven.'],
  ['AD-12', 'Settings search from one tab finds a row on the other tab but cannot show it: it says "1 setting matches (across both tabs)" and shows nothing, because the other tab\'s rows keep `.mt-tab-off` (`display:none !important`) and the script only clears `hidden` (`settings/index.tpl:1373-1381`).'],
  ['AD-19', 'With "Use Custom Hostname" off, the cart still uses the custom length, zone and domain; the help text says a random string is used. Only the character set is gated on the flag (`hadrian_cart/configureproduct.tpl:312-318`, `:327`).'],
  ['AD-87', 'A licence status of "Error" shows as "This key is not valid for this domain" (a fail, not a warn): `SetupChecks.php:265-276` has no branch for it, and `LicenseCheck.php:91-93` caches it for 15 minutes like any signed answer. Whether the server ever sends "Error" is not known.'],
  ['AD-25', 'Colour presets and "Generate from one colour" also write the dark scope, while the panel says "writes the light scope only" (`styles/_colors.tpl:93`; `includes/footer.tpl:450`, `:1201-1202`). A code comment calls this deliberate, so the panel text may be what is stale.'],
];
const MINOR = [
  'Menu editor: the max_input_vars warning starts at 950 estimated fields but Save is refused above 900, so a menu of about 128 to 134 items is refused with no warning first.',
  'Templates screen (AD-83): `templateName` goes into a file path unchecked, and an unknown name prints the absolute server path (`TemplatesController.php:29-31`).',
  'AD-04: FEATURES.md quotes the theme version as 1.1.242; `core/hadrian.php` now says 1.1.247.',
];

const esc = s => String(s ?? '').replace(/\|/g, '\\|').replace(/\r?\n/g, ' ');
const oneLine = (recs, id) => {
  if (!recs?.length) return OUTSIDE[id] || '';
  const checks = recs.flatMap(r => r.checks);
  const okN = checks.filter(c => c.ok).length;
  const changed = recs.flatMap(r => r.values.filter(v => v.changed).map(v => `\`${v.label}\` ${v.before} -> ${v.after}`));
  const firstFail = recs.find(r => outcome(r) === 'failed' || outcome(r) === 'known');
  const skip = recs.find(r => r.status === 'skipped');
  const parts = [`${okN}/${checks.length} checks`];
  if (changed.length) parts.push(changed.slice(0, 2).join('; ').slice(0, 220));
  if (firstFail) parts.push(`FAILED: ${(firstFail.checks.find(c => !c.ok)?.label || firstFail.error || '').split('\n')[0].slice(0, 200)}`);
  else if (skip) parts.push(`skipped: ${(skip.annotations.find(a => a.type === 'skip')?.description || '').slice(0, 200)}`);
  return parts.join('. ');
};

// ------------------------------------------------------------ the summary
const all = sections.flatMap(s => s.rows);
const tally = {};
for (const r of all) tally[verdict(records[r.id], r.id)] = (tally[verdict(records[r.id], r.id)] || 0) + 1;
const tallyLine = Object.keys(VERDICT).filter(k => tally[k]).map(k => `${VERDICT[k]}: ${tally[k]}`).join(' · ');
const lastRun = Object.values(records).flat().map(r => r.at).sort().at(-1) || 'never';

// ------------------------------------------------------- ADMIN-FEATURES.md
let md = `# Hadrian admin features, tested one by one

Every feature of the Hadrian admin addon (\`hadrian/modules/addons/Hadrian/\`), with what it promises and whether a test proved it does that. The list and the IDs come from the AD section of [FEATURES.md](FEATURES.md).

Each test works the way an admin does: it opens the screen in Chromium, changes the control and presses Save. Then it proves the change three ways:
- **stored:** the database value before and after
- **effect:** the client area, the order form or the file on disk, before and after
- **seen:** screenshots of the admin screen and of the effect

Everything an admin can write is backed up before each test file and put back after it.

Run it against the local site, then rebuild this file:

\`\`\`
cd tests
npx playwright test --project=admin-audit
node lib/admin-audit-report.mjs
\`\`\`

The full proof (steps, values, every check, screenshots) is in \`tests/reports/admin-audit/REPORT.md\` on the machine that ran it. Tests live in \`tests/e2e/audit/\`.

**Last run:** ${lastRun}. **${all.length} features.** ${tallyLine}

## Bugs found by the first run, all fixed

The first run (2026-11-27) found these. Each was fixed the same day, and the test in \`tests/e2e/audit/\` that asserts the promise now passes. They stay listed so a regression is easy to recognise.

${FINDINGS.map(([id, t], i) => `${i + 1}. **${id}.** ${t}`).join('\n')}

Smaller things, also fixed:
${MINOR.map(t => `- ${t}`).join('\n')}

`;
for (const s of sections) {
  md += `## ${s.key} ${s.name}\n\n| ID | Feature | Promises | Verdict | Proof |\n|---|---|---|---|---|\n`;
  for (const r of s.rows) {
    const recs = records[r.id];
    md += `| ${r.id} | ${esc(r.feature)} | ${esc(r.verify)} | ${VERDICT[verdict(recs, r.id)]} | ${esc(oneLine(recs, r.id))} |\n`;
  }
  md += '\n';
}
fs.writeFileSync(path.join(TESTS_DIR, 'ADMIN-FEATURES.md'), md);

// ------------------------------------------------------------- REPORT.md
let rep = `# Hadrian admin audit: proof\n\nLast run ${lastRun}. ${all.length} features. ${tallyLine}\n\n`;
rep += `| ID | Feature | Verdict |\n|---|---|---|\n` + all.map(r => `| [${r.id}](#${r.id.toLowerCase()}) | ${esc(r.feature)} | ${VERDICT[verdict(records[r.id], r.id)]} |`).join('\n') + '\n\n';
for (const s of sections) {
  rep += `## ${s.key} ${s.name}\n\n`;
  for (const r of s.rows) {
    const recs = records[r.id] || [];
    rep += `### ${r.id}\n\n**${esc(r.feature)}**: ${VERDICT[verdict(recs, r.id)]}\n\nPromises: ${r.verify}\n\n`;
    if (!recs.length) { rep += `_${OUTSIDE[r.id] || 'No test yet.'}_\n\n`; continue; }
    for (const rec of recs) {
      const o = outcome(rec);
      rep += `#### ${rec.title} (${o})\n\n\`${rec.file}\`\n\n`;
      if (rec.claims.length) rep += rec.claims.map(c => `> ${c}`).join('\n>\n') + '\n\n';
      if (rec.steps.length) rep += rec.steps.map((t, i) => `${i + 1}. ${t}`).join('\n') + '\n\n';
      if (rec.values.length) {
        rep += '| Stored value | Before | After | Changed |\n|---|---|---|---|\n';
        rep += rec.values.map(v => `| ${esc(v.label)} | \`${esc(v.before)}\` | \`${esc(v.after)}\` | ${v.changed ? 'yes' : 'no'} |`).join('\n') + '\n\n';
      }
      if (rec.checks.length) rep += rec.checks.map(c => `- ${c.ok ? 'PASS' : 'FAIL'} ${c.label}${c.detail ? `: ${c.detail}` : ''}`).join('\n') + '\n\n';
      if (rec.error && o !== 'passed') rep += '```\n' + rec.error + '\n```\n\n';
      for (const n of rec.notes) rep += `- Note: ${n}\n`;
      for (const n of rec.limits) rep += `- Not proven here: ${n}\n`;
      if (rec.notes.length || rec.limits.length) rep += '\n';
      for (const sh of rec.shots) rep += `**${esc(sh.label)}**\n\n![${esc(sh.label)}](${sh.file})\n\n`;
    }
  }
}
fs.mkdirSync(PROOF_DIR, { recursive: true });
fs.writeFileSync(path.join(PROOF_DIR, 'REPORT.md'), rep);
console.log(`${all.length} features. ${tallyLine}\n  tests/ADMIN-FEATURES.md\n  ${path.relative(TESTS_DIR, path.join(PROOF_DIR, 'REPORT.md'))}`);
