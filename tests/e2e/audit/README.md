# Admin audit

One test (or a few) per Hadrian admin feature, each proving the feature does what it says. The features and their IDs are the AD rows of [tests/FEATURES.md](../../FEATURES.md). The verdicts end up in [tests/ADMIN-FEATURES.md](../../ADMIN-FEATURES.md).

```
cd tests
npx playwright test --project=admin-audit --workers=1                 # everything
npx playwright test --project=admin-audit --workers=1 audit/b-settings  # one file
node lib/admin-audit-report.mjs                                       # rebuild the report
```

The run takes the site lock (`tests/.local/site.lock`) like every other run that uses the local site. If another run holds it, this one waits.

## What a test has to prove

A test acts the way an admin does: it opens the screen in the `admin` page, changes the control, and presses the real Save button. Posting the form with `request.post()` doesn't count, and neither does writing the database directly. Then it proves the change:

1. **Stored:** read the value with `db.*` before and after, and record both with `proof.value()`.
2. **Effect:** show the change where the feature promises it, before and after. That can be the client area (`visit('guest')` or `visit('full')`), the order form, a file on disk (`db.file()`), or a redirect or JSON reply. A body attribute, a CSS class or a stylesheet value counts, as long as it is the thing the feature controls.
3. **Seen:** take `proof.shot()` screenshots of the admin screen after Save and of the effect.

Validation promises ("out-of-range resets", "allow-listed", "filtered to installed languages") are proven by sending the bad value. Use the real form where a control allows it. Where it doesn't, change the field in the page with `locator.evaluate()` before pressing Save, so the post still goes through the screen. Then show what was stored.

Each `proof.check()` and `proof.equal()` is one fact, worded as the fact ("the order form now carries data-free-label=\"1\""). A failed check fails the test, and the report shows which fact failed. If the code doesn't do what the row promises, keep the test asserting the promise and let it fail. Don't weaken it until it passes, and don't fix product code: a failing test is the finding. Put what you saw in `proof.note()`.

If a feature can't be tested here, write the test anyway and call `test.skip(true, 'reason')` at the top. Reasons that count: it needs a live server, it would wreck the install, or the code path is dead. Then say in `proof.note()` what you checked instead.

## Rules

- Titles start with the feature ID: `test('AD-23 Colours save drops an invalid hex', ...)`. One feature can have several tests.
- Start every file with `useAuditBackup()`. If tests in the file change settings, also call `settings.snapshot()` and `settings.restore()` in `beforeEach` and `afterEach`, as `b-settings.audit.mjs` does. Put back anything else you change yourself: files you upload, `sitemap.xml` and `robots.txt`, `tblconfiguration` rows like `Template`. `useAuditBackup()` covers every `hadrian_*` table and the `hadrian%`, `Template` and `OrderFormTemplate` config rows, but no files and no other WHMCS tables.
- Never send a real licence key anywhere. Never call license.hostnodes.com more than twice per run, and only with an obviously fake key such as `HN-AUDIT-NOT-A-KEY`. Never touch any host but `localhost`.
- Name files `<section letter>-<name>.audit.mjs`, so no other Playwright project picks them up.
- Don't edit `harness.mjs`, `tests/lib/admin-audit-report.mjs` or `playwright.config.mjs`. If the harness is missing something, put a local helper in your own file.
- Don't run the gate or other tiers (`node tests/run.mjs`). They hold the site for 45 minutes.

## Harness

`harness.mjs` exports:

| Name | What it is |
|---|---|
| `test` | Playwright `test` with the fixtures `admin` (a page signed in to WHMCS admin), `visit(persona)` (a new page as `guest` or a seeded client: `full`, `empty`, `suspended`) and `proof` |
| `proof` | `claim`, `step`, `value(label, before, after)`, `check(label, ok, detail)`, `equal(label, actual, expected)`, `await shot(pageOrLocator, label)`, `note`, `limit` |
| `db` | read-only: `setting(key)`, `settings(prefix)`, `config(key)`, `page(page, tpl)`, `menus()`, `menu(id)`, `file(relPath)`, `hash()` |
| `settings` | `snapshot()`, `restore()`, `set({key: [value, type]})`, `page({...})`, `variant({...})` (see `tests/php/settings.php`) |
| `php(script, ...args)` | run any `tests/php/*.php` driver and parse its JSON |
| `adminUrl(action, params)` | `addonmodules.php?module=Hadrian&action=...` |
| `submit(page, selectorOrLocator)` | press a submit button (or submit a form) and wait for the answering page |
| `flashText(page)` | the alert text the admin screen shows |
| `noErrorText(page, proof, where)` | check that no PHP or Smarty error text reached the page |

Credentials, personas and fixture ids come from `tests/.local/credentials.json` and `fixtures.json` (`creds` and `fx` in `../helpers.mjs`). Don't print them into proof records.
