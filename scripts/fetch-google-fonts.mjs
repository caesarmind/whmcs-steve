#!/usr/bin/env node
/**
 * Refresh the Google Fonts catalog that powers Styles -> Typography -> Google Font.
 *
 * Source: https://fonts.google.com/metadata/fonts -- the same list fonts.google.com
 * renders itself. Public, no API key (unlike the Developer API at
 * googleapis.com/webfonts/v1, which needs one and which Lagom's shipped
 * googleFonts.json is a dump of).
 *
 *   node scripts/fetch-google-fonts.mjs
 *
 * Writes hadrian/templates/hadrian/core/config/google-fonts.json. Nothing at
 * runtime fetches from Google: the catalog is a build artifact, checked in, and
 * read server-side by StylesController. Re-run it when Google adds families.
 *
 * Row format is a tuple, not an object, purely for size -- 1,900-odd families
 * as {"family":..,"category":..} is ~200KB, as tuples it is ~80KB, and this
 * blob is embedded in the admin page.
 *
 *   [ family, category, [weights], hasItalic ]
 *
 * `weights` is what the family actually ships. The css2 API silently drops
 * weights a family lacks, so this is not needed to avoid an HTTP error -- it is
 * needed so we request only real weights (a smaller stylesheet) and so the
 * admin UI can say what it is choosing.
 */
import { writeFileSync, mkdirSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const OUT  = resolve(ROOT, 'hadrian/templates/hadrian/core/config/google-fonts.json');
const SRC  = 'https://fonts.google.com/metadata/fonts';

/* Google's five categories, shortened. The admin picker filters on these. */
const CATEGORY = {
    'Sans Serif':  'sans',
    'Serif':       'serif',
    'Display':     'display',
    'Handwriting': 'hand',
    'Monospace':   'mono',
};

const res = await fetch(SRC, { headers: { 'user-agent': 'hadrian-build' } });
if (!res.ok) {
    console.error(`FAIL ${SRC} -> HTTP ${res.status}`);
    process.exit(1);
}

/* The endpoint sometimes prefixes the anti-JSON-hijack sentinel )]}' -- strip it. */
const body = (await res.text()).replace(/^\)\]\}'?\s*/, '');
const meta = JSON.parse(body);
const list = meta.familyMetadataList;
if (!Array.isArray(list) || list.length === 0) {
    console.error('FAIL payload had no familyMetadataList');
    process.exit(1);
}

const skipped = [];
const families = list
    .filter((f) => {
        if (CATEGORY[f.category]) return true;
        skipped.push(`${f.family} (category "${f.category}")`);
        return false;
    })
    .sort((a, b) => a.family.localeCompare(b.family, 'en'))
    .map((f) => {
        /* fonts is keyed "400", "400i", "700i"... -- weights are the keys with
           the italic suffix dropped, de-duplicated. */
        const keys    = Object.keys(f.fonts || {});
        const weights = [...new Set(keys.map((k) => parseInt(k, 10)))]
            .filter((w) => w >= 100 && w <= 900)
            .sort((a, b) => a - b);
        return [f.family, CATEGORY[f.category], weights.length ? weights : [400], keys.some((k) => k.endsWith('i')) ? 1 : 0];
    });

/* Both the name AND the category are attacker-relevant: the whole file is
   embedded into the admin Styles page as an inline <script> JSON island and
   rendered into option rows via innerHTML, so any value that survives into it
   is a potential injection foothold. The name goes into a CSS font-family and a
   fonts.googleapis.com URL besides. Refuse the whole build rather than ship a
   row that could carry a `</script>` breakout or CSS injection -- Google has
   never emitted such a value; this is a tripwire, matched on read by
   StylesController::loadGoogleFontCatalog. */
const CATEGORY_SLUGS = new Set(Object.values(CATEGORY));
const unsafe = families.filter(
    ([name, category]) => !/^[A-Za-z0-9][A-Za-z0-9 ]*$/.test(name) || !CATEGORY_SLUGS.has(category),
);
if (unsafe.length) {
    console.error(`FAIL ${unsafe.length} row(s) with an unsafe family name or category:`);
    unsafe.slice(0, 20).forEach(([n, c]) => console.error(`  ${n} [${c}]`));
    process.exit(1);
}

const payload = {
    _source: SRC,
    _generated: new Date().toISOString().slice(0, 10),
    _script: 'scripts/fetch-google-fonts.mjs',
    _format: '[family, category, [weights], hasItalic]',
    count: families.length,
    families,
};

/* One family per line: a diff on the next refresh shows added/removed families
   rather than one 80KB line. */
const json =
    '{\n' +
    Object.entries(payload)
        .filter(([k]) => k !== 'families')
        .map(([k, v]) => `  ${JSON.stringify(k)}: ${JSON.stringify(v)}`)
        .join(',\n') +
    ',\n  "families": [\n' +
    families.map((row) => '    ' + JSON.stringify(row)).join(',\n') +
    '\n  ]\n}\n';

mkdirSync(dirname(OUT), { recursive: true });
writeFileSync(OUT, json, 'utf8');

const byCat = {};
for (const [, c] of families) byCat[c] = (byCat[c] || 0) + 1;
console.log(`OK  ${families.length} families -> ${OUT.replace(ROOT + '\\', '').replace(ROOT + '/', '')}`);
console.log('    ' + Object.entries(byCat).map(([c, n]) => `${c}:${n}`).join('  '));
console.log(`    ${(Buffer.byteLength(json) / 1024).toFixed(1)} KB`);
if (skipped.length) console.log(`    skipped ${skipped.length}: ${skipped.slice(0, 5).join(', ')}`);
