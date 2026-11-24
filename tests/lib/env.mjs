// Paths and settings shared by the runner, the preflight and the Playwright
// config. Everything machine-specific is overridable by environment variable,
// with defaults matching the Laragon stack in scripts/local-stack.

import path from 'node:path';
import fs from 'node:fs';
import { fileURLToPath } from 'node:url';

export const TESTS_DIR = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
export const REPO_ROOT = path.dirname(TESTS_DIR);
export const LOCAL_DIR = path.join(TESTS_DIR, '.local');
export const REPORTS_DIR = path.join(TESTS_DIR, 'reports');

export const BASE_URL = (process.env.HADRIAN_BASE_URL || 'http://localhost:8088').replace(/\/$/, '');
export const WHMCS_ROOT = process.env.WHMCS_ROOT || 'C:/laragon/www/whmcs';
export const PHP = process.env.HADRIAN_PHP || 'C:/laragon/bin/php/php-8.3.30-Win32-vs16-x64/php.exe';
export const MYSQL_BIN = process.env.HADRIAN_MYSQL_BIN || 'C:/laragon/bin/mysql/mysql-8.4.3-winx64/bin';
// Mailpit catches the mail WHMCS sends (php.ini sendmail_path -> mailpit sendmail
// -> SMTP :1025). The flows read password-reset and verification links from it.
export const MAILPIT_BIN = process.env.HADRIAN_MAILPIT_BIN || 'C:/laragon/bin/mailpit/1.22.3/mailpit.exe';
export const MAILPIT_URL = (process.env.HADRIAN_MAILPIT_URL || 'http://localhost:8025').replace(/\/$/, '');

// The directories the local install serves from this checkout. If a
// junction points anywhere else (another worktree, a stale copy), every test
// would be exercising code you are not looking at.
export const JUNCTIONS = [
  { link: path.join(WHMCS_ROOT, 'templates', 'hadrian'),                  target: path.join(REPO_ROOT, 'hadrian', 'templates', 'hadrian') },
  { link: path.join(WHMCS_ROOT, 'modules', 'addons', 'Hadrian'),          target: path.join(REPO_ROOT, 'hadrian', 'modules', 'addons', 'Hadrian') },
  { link: path.join(WHMCS_ROOT, 'templates', 'orderforms', 'hadrian_cart'), target: path.join(REPO_ROOT, 'hadrian_cart') },
  // Hadrian Email Templates: its own addon module, in its own top-level folder.
  { link: path.join(WHMCS_ROOT, 'modules', 'addons', 'HadrianEmail'),     target: path.join(REPO_ROOT, 'hadrian_email', 'modules', 'addons', 'HadrianEmail') },
];

// A fixed desktop UA. WHMCS binds admin sessions to the user agent, so the
// API logins in auth.setup and the browser contexts must present the same one.
export const USER_AGENT =
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 HadrianTests/1';

export function readJson(file, fallback = null) {
  try { return JSON.parse(fs.readFileSync(file, 'utf8')); } catch { return fallback; }
}

export const credentials = () => readJson(path.join(LOCAL_DIR, 'credentials.json'));
export const fixtures = () => readJson(path.join(LOCAL_DIR, 'fixtures.json'));
export const authStatePath = name => path.join(LOCAL_DIR, 'auth', `${name}.json`);
