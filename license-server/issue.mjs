// Issue / update a dev license key in licenses.json.
//
//   node issue.mjs <key> <status> <expiresISO> <domain[,domain2]> [feature[,feature2]]
//
// Example:
//   node issue.mjs ACME-2026-XXce Active 2027-06-04T00:00:00Z "acme.com,www.acme.com" dark-mode,cms-pages
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const DIR = path.dirname(fileURLToPath(import.meta.url));
const DB_PATH = path.join(DIR, 'licenses.json');

const [key, status, expires, domains = '', features = ''] = process.argv.slice(2);
if (!key || !status) {
  console.error('usage: node issue.mjs <key> <status> <expiresISO> <domain[,domain]> [feature[,feature]]');
  process.exit(1);
}

const db = JSON.parse(fs.readFileSync(DB_PATH, 'utf8'));
db[key] = {
  status,
  expires: expires || '',
  allowed_domains: domains ? domains.split(',').map((s) => s.trim()).filter(Boolean) : [],
  features: features ? features.split(',').map((s) => s.trim()).filter(Boolean) : [],
};
fs.writeFileSync(DB_PATH, JSON.stringify(db, null, 2) + '\n');
console.log(`issued: ${key} -> ${status} (domains: ${db[key].allowed_domains.join(', ') || 'none'})`);
