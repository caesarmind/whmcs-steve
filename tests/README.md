# Hadrian test suite

Automated checks that the theme (`hadrian/templates/hadrian`), the order form
(`hadrian_cart`) and the admin addon (`hadrian/modules/addons/Hadrian`) work -
run against the **real local WHMCS** from [`scripts/local-stack`](../scripts/local-stack/README.md).

```bash
node tests/run.mjs
```

Or double-click **`tests/TEST.bat`** - it runs everything and opens the report.
Start the stack first (`scripts/local-stack/START-SERVER.bat`), and once per
checkout install the Smarty that four of the static checkers render with:

```bash
composer install -d tests/static
```

(On a Laragon machine without Composer on the PATH:
`php C:\laragon\bin\composer\composer.phar install -d tests/static`.)

| Result | Meaning |
|---|---|
| exit 0, `PASSED` | nothing blocking failed |
| exit 1, `FAILED` | a blocking check failed - the report says which and why |
| exit 2 | the **environment** is not ready (preflight) - a setup problem, not a theme bug; the message names the fix. Also: another run is using the site and `--no-wait` was given (see "Things worth knowing") |

The report is `tests/reports/index.html` (summary) with a link to the detailed
Playwright report (screenshots, traces, the HTML of every failing page).

## Tiers

| Tier | What it checks | Needs the site | Time |
|---|---|---|---|
| **preflight** | the stack is up, serves *this* checkout, the template is `hadrian`, the addon's hooks load, data is seeded, a gateway is active | yes | ~5 s |
| **static** | 33 checkers: every page is tested or has a stated reason why not, CSS is ASCII-only, PHP parses, Smarty balance, every `$hadrianLang` key resolves, colour defaults match the CSS, the three "Free" implementations agree, admin JS parses, docs anchors, ... | no | ~30 s |
| **compile** | every one of the 314 templates compiled by **WHMCS's own Smarty** (its modifiers + security policy) | WHMCS files | ~12 s |
| **smoke** | every page x persona over HTTP, every Hadrian admin screen, and a crawl that follows every link the theme renders | yes | ~3 min |
| **browser** | real Chromium: every key page in 3 layouts x light/dark + phone width; JS errors, failed assets, layout geometry, unreadable text; the user flows; one test per client-area and order-form feature that needs no setting changed (`client-area.spec`, `order.spec`, the TH and OF rows of [FEATURES.md](FEATURES.md)) | yes | ~15 min |
| **a11y** | axe-core, WCAG 2.2 A + AA: every route in the sidebar layout, the order steps with a cart, six pages in each other layout, ten pages at 320 px; light and dark. Compared with `e2e/a11y-baseline.json` (see below). **Not in `--gate` yet** | yes | ~15 min |
| **visual** | screenshots compared against approved baselines - **advisory**, never fails the run | yes | ~2 min |

### Accessibility

Plan: [docs/accessibility-hadrian-plan.md](../docs/accessibility-hadrian-plan.md). The site does not pass WCAG 2.2 AA yet, so both accessibility checks compare against a baseline of what fails today and fail on anything worse, and on anything better. A fix shrinks the baseline in the same change, so a finding cannot quietly come back.

- `tests/e2e/a11y-baseline.json` (a11y tier): page -> axe rule -> number of failing elements. After a fix, run `HADRIAN_A11Y_UPDATE=1 node tests/run.mjs --tier a11y` and review the diff. `node tests/lib/a11y-summary.mjs` turns the last run's detail (`tests/reports/a11y-detail/`) into `tests/reports/a11y-summary.md`.
- `tests/static/a11y-markup-baseline.json` (static tier, in the gate): template -> rule -> count for five source heuristics (icon-only buttons, icon-only labels, unlabelled fields, English names written into templates, inline SVGs not hidden). `node tests/static/check-a11y-markup.mjs --update` after a fix; `--list <rule> [file]` prints every hit.
- Layouts are switched through the stored layout pointers, never `?preview=1&layout=`: preview draws every layout's chrome at once, so landmarks and ids would be counted twice.
- axe does not see everything. It accepts a placeholder as a field's name, so the checkout's icon-only labels pass it; the static check catches those. Keyboard behaviour, focus order and what a screen reader announces still need a person.

### Hadrian Email Templates

A separate addon module (`hadrian_email/`, mounted at `modules/addons/HadrianEmail`)
that requires Hadrian. It is tested in two places:

- **static**: three checks. `test-email-engine.php` drives the engine with no WHMCS
  (merge-field handling, the sanitiser, document validation, colour resolution, the
  renderer); the other two lint its templates and its builder script.
- **settings** (`e2e/email.spec.mjs`, beside `settings.spec.mjs`, one worker): the
  module driven through its admin UI in Chromium, with the emails WHMCS then sends read
  back from Mailpit. It also runs `tests/php/email-live.php`, the checks that need WHMCS
  itself: the takeover and its fallback, publishing, translations, edits made outside,
  and that turning it off restores WHMCS byte for byte.

The spec switches the header of every email the install sends, which is why it never
runs beside the smoke or browser tiers. It removes the mail-log rows it creates: an
email left in a persona's history is opened by the smoke crawl, links and all.

```bash
node tests/run.mjs --tier static,compile   # no site needed
node tests/run.mjs --tier smoke
node tests/run.mjs --gate                  # every blocking tier (what pre-push runs)
node tests/run.mjs --approve               # accept today's look as the visual baseline
```

## What counts as broken

A page can return HTTP 200 and still be broken. Each rule below is a bug that
actually shipped; the suite found most of them on its first run.

| Oracle | Bug it encodes |
|---|---|
| a template must compile with WHMCS's Smarty | Security Settings and Affiliates rendered **blank** for months: `{'close': ...}` in a `<script>` is a Smarty tag, the compile failed, WHMCS returned 200 with an empty content area |
| the content area must not be empty | same - and any future swallowed compile error |
| no WHMCS error screen, no PHP/Smarty error text | `count('')` fatal on PHP 8 took down contact.php and the cart |
| `<body data-tpl>` must be the page we asked for | stale routes that silently redirect to the dashboard |
| headings and the locale button must carry text | `$hadrianLang` renders empty when the addon's hooks do not load |
| no sidebar item draws the placeholder dot | menu presets seeded without icons |
| no class name with a stray hyphen | `" Closed "` became `-closed-`: closed tickets kept their Close button, status pills went unstyled |
| following a link must not sign the customer out | the Close Ticket link had no CSRF token: WHMCS signed the customer out instead |
| no broken link or redirect loop in the navigation | Domain Pricing pointed at `domainchecker.php` (a redirect loop); Network map was a 404 |
| judged on the variant the visitor sees (`when-full` vs `when-empty`) | a missing ticket showed a stray `#` and a Close button for no ticket above "Ticket not available" |
| a new customer can check out | the phone field was rewritten to E.164, which WHMCS refuses: every valid number was "not valid" |
| checkout survives the CDN being blocked | the order form loads jQuery, Bootstrap and intl-tel-input from third-party CDNs |

## Personas and data

`tests/php/fixtures.php` runs in the preflight. It **ensures** records exist and
never resets them, so it is safe against a local install you have been
clicking around in:

| Persona | Who |
|---|---|
| `guest` | not signed in |
| `full` | Mara Okonkwo: services, domains, invoices, an open ticket; an affiliate |
| `empty` | Erin Empty: an active client with nothing - every page's when-empty state |
| `suspended` | the seeded client whose service is Suspended |
| `admin` | `hadrian-test`, a dedicated test admin (not your login) |

Credentials are generated locally into `tests/.local/credentials.json`
(gitignored) and never printed. It also activates the Offline Credit Card
gateway, without which WHMCS hides the payment-methods pages. Records the
flows create (customers `flow+<n>@demo.hadrian.test`, tickets titled
`[flow] ...`) are removed on the next run.

The demo data itself comes from `scripts/local-stack/seed-demo-data.php`.

## The pre-push gate

`.githooks/pre-push` runs `node tests/run.mjs --gate` when a push carries any
file the deploy Action ships, and refuses the push if it fails - because a push
to main *is* the deploy. It also refuses when deploy paths have uncommitted
changes (the suite tests the working tree, so it would be testing something
other than what is pushed). Docs/tooling-only pushes are not gated.

```bash
git config core.hooksPath .githooks
```

Bypass once with `git push --no-verify` - you are then deploying untested.

## Known issues

`tests/e2e/known-issues.mjs` lists real bugs that are understood but not fixed
yet. They are reported on every run without failing it, so one open bug cannot
block every other fix at the gate. Entries clean themselves up: if a listed
issue stops occurring, the run fails asking for the entry to be removed.

## Known bugs

A bug that is confirmed but not fixed gets a test that asserts the right
behaviour, so it fails today, plus a marker that keeps that failure out of the
gate. The run lists each one under "Known issues". When a fix makes the test
pass, the run fails until the marker is removed, and the test stays as a
regression test.

- **Playwright:** check the scenario was set up first, then call
  `test.fail(true, 'BUG n in tests/FEATURES.md: ...')` and assert. A setup
  failure before that line still fails the run. See `e2e/known-bugs.spec.mjs`.
- **Static checkers:** print `KNOWN BUG <id>: ...` instead of failing and exit 0;
  print `FIXED <id>: ...` and exit 1 once the check passes.
  `static/check-root-paths.mjs` has the mechanism (its `KNOWN` list, empty
  since bug 7 was fixed).

`e2e/known-bugs.spec.mjs` runs in the settings project, because it renames the
live guest menu and saves page settings. Its PHP half is `php/known-bugs.php`,
which refuses to touch a menu an admin made. When a bug is fixed, its test can
move to where its feature is tested: bugs 1 and 2 (email drafts) went to
`php/email-live.php`.

The bugs and the rows they affect are listed in [FEATURES.md](FEATURES.md).

## Adding coverage

- **A new page:** add a line to `ROUTES` in `tests/e2e/routes.mjs` with its URL,
  the personas that should see it and the `data-tpl` it must render. The crawl
  will usually have found it already; the route makes it explicit.
- **A new admin screen:** add its `action=` to `ADMIN_ACTIONS` in the same file.
  Menu, style and page editors are discovered automatically.
- **A new checker script:** put it in `tests/static/` and declare it in
  `tests/lib/registry.mjs` - how to run it, and whether a failure should block.
- **A new kind of bug:** add an oracle to `tests/e2e/oracles.mjs`, then prove it
  catches the bug by running it against the broken version first.

## Coverage

Two questions, two tools.

**Is every page tested at all?** `tests/e2e/coverage.mjs` lists every page
folder, variant and cart template that no test renders yet, each with a status
(`todo` and the plan step that closes it, `inner`, `local`, `legacy`) and a
reason. The static check `check-coverage.mjs` fails when something is in
neither place, and when an entry goes stale because a test now renders it.

```bash
node tests/static/check-coverage.mjs --list
```

**How much of each template runs?** The coverage runner measures template
branch coverage: every `{if}`, `{elseif}`, `{else}`, `{foreach}` and the
implicit "condition false" / "list empty" sides of them.

```bash
node tests/coverage/run.mjs
```

There is no PHP coverage driver on this stack, so it instruments a copy of
the templates with markers that only reach the HTML when a branch runs,
points the local install at the copy for the length of the run, visits every
route and crawls as guest and full, then puts the junctions back and clears
the compiled cache. Each swap waits out PHP's realpath cache (120 s), because
Apache threads keep reading the old directory until it expires, so a run costs
about 4 minutes more than the page loads themselves. Report: `tests/reports/coverage/index.html`, worst files
first, each missed branch with its line and condition. Don't run it at the
same time as `run.mjs`. If it is killed halfway, `node tests/coverage/run.mjs
--restore` puts the junctions back (the preflight will otherwise fail on them).

It only measures over HTTP: markers inside `<script>` would break the page in
a browser, so the flows don't count towards it yet. `{capture}` blocks are not
instrumented, because templates test captured output for emptiness.

## Things worth knowing

- **Runs that use the site go one at a time.** The settings tier and its
  neighbours change what every request sees, so two runs started from
  different terminals (or Claude sessions) used to break each other: on
  2026-11-25 one run's email "stands down" test took Hadrian out of
  `ActiveAddonModules` under another run's builder test, and one run emptied
  the Playwright output folder the other was writing traces to. Now a run
  takes `tests/.local/site.lock` (pid, command, start time) first:
  `run.mjs` for every tier but static, Playwright's `globalSetup` for a direct
  `playwright test`, and the coverage runner. A second run prints who holds
  it and waits; `--no-wait` (or `HADRIAN_SITE_LOCK_WAIT=0` for any run) makes
  it refuse with exit 2 instead, and `HADRIAN_SITE_LOCK_WAIT=<minutes>` sets
  how long it waits (default 60). The lock goes on exit, failure and Ctrl+C;
  a lock whose process is gone (a run that was killed) is taken over by the
  next run. `--tier static` alone never takes it. The PHP drivers that change
  global state (`settings.php`, `email-live.php`, `known-bugs.php`) refuse
  with exit 75 while another process holds it; under the holder they get its
  token through `HADRIAN_SITE_LOCK_TOKEN` and run. Code: `lib/site-lock.mjs`,
  `php/site-lock.php`.
- **Each Playwright invocation has its own output folder**,
  `tests/reports/output/<tag>-<pid>`, because Playwright empties its
  `outputDir` when it starts. Folders of runs that have ended are removed at
  the start of the next one (the HTML reports keep their own copies of
  traces and screenshots). `--last-failed` needs `--output` to point at the
  previous run's folder.
- **Windows + a cold template cache.** Smarty cannot replace a compiled
  template atomically on Windows, so parallel requests against a cold or just-
  edited template can get truncated pages (Linux production is not affected).
  `tests/lib/warmup.mjs` compiles sequentially before the workers start, but
  only when the cache is cold or a template changed - otherwise it costs nothing.
- **Every static checker is tracked.** Until 2026-10-28, 17 of the 25 lived in
  the untracked `.dashbuild/` scratch folder and a fresh checkout skipped them
  with a note; they are in `tests/static/` now. The four that render templates
  through Smarty need `composer install -d tests/static` once (into the
  gitignored `tests/static/vendor/`) - without it the run stops in the
  preflight with exit 2 and that command.
- **The doc-anchors check builds the docs first** (`node scripts/build-docs.mjs
  --base=`, into the gitignored `hadrian-documentation/dist`), so it judges the
  current source rather than whatever an earlier build left behind. Three
  checkers also write the pages they rendered to `tests/.local/adminpreview/`
  for a human to look at: the colours panel, the colour-scope leak probe and
  the login variants.
- **Visual baselines are per machine** (fonts, GPU) and live in
  `tests/.local/visual`. A difference is a question, not a failure.
- **What it cannot test:** anything that only exists in production - licence
  enforcement against the licence server, cPanel SSO, real payment gateways.
