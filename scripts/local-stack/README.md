# Hadrian local stack

A real WHMCS 9.0.4 running on the Laragon binaries already installed on this
machine, with the theme folders of this repo mounted straight into it. Edit a
`.tpl` / `.css` here, reload the page, done - no push, no deploy Action.

| Piece | Where |
|---|---|
| WHMCS install | `C:\laragon\www\whmcs` (copied from `Downloads\whmcs-9.0.4-release.1`) |
| Client area / admin | `http://localhost:8088/` and `http://localhost:8088/admin/` |
| Apache | Laragon `httpd` 2.4, vhost `C:\laragon\etc\apache2\sites-enabled\10-whmcs-local.conf` (root of its own port, like bill.hostnodes.com) |
| PHP | Laragon PHP 8.3 (thread-safe, mod_php); `zip`, `soap`, `gmp`, `imap` enabled; `date.timezone=UTC`; ionCube Loader as `zend_extension` |
| MySQL | Laragon MySQL 8.4, db `whmcs`, user `whmcs` / `whmcs`; root has no password; `sql_mode=NO_ENGINE_SUBSTITUTION` (WHMCS needs strict mode off) |
| Logs | `C:\laragon\www\whmcs-local-error.log`, `...-access.log` |

## The repo is mounted, not copied

Three directory junctions inside the install point back into this checkout:

```
C:\laragon\www\whmcs\templates\hadrian                 -> hadrian\templates\hadrian
C:\laragon\www\whmcs\modules\addons\Hadrian            -> hadrian\modules\addons\Hadrian
C:\laragon\www\whmcs\templates\orderforms\hadrian_cart -> hadrian_cart
```

That is exactly the set the deploy Action ships (`.github/workflows/main.yml`),
so what you see locally is what a push would put on the live box. Anything
else in the repo (mockups, docs, scripts) is invisible to WHMCS, same as prod.

`git checkout` of another branch flips the local site with it - there is no
separate copy to keep in sync.

**The junction works both ways.** WHMCS and the Hadrian addon can write into
your working tree through it, and they do: activating the addon creates
`hadrian/templates/hadrian/assets/img/branding/.htaccess`, and any branding
logo uploaded in the local admin lands in that same directory. Those are
runtime artifacts, not source - the addon recreates the `.htaccess` on any
server it runs on. Since this is a deploy path, check `git status` before
committing so an uploaded test logo never rides along:

```bash
git status --short -- hadrian/ hadrian_cart/
```

Adding `hadrian/templates/hadrian/assets/img/branding/` to `.gitignore` is the
durable fix if you plan to upload branding locally.

## Start / stop

```bash
powershell -ExecutionPolicy Bypass -File scripts/local-stack/up.ps1
```

```bash
powershell -ExecutionPolicy Bypass -File scripts/local-stack/down.ps1
```

`up.ps1` is idempotent: it leaves anything already listening on 3306 / 8088
alone, so it coexists with the Laragon tray app. Use one or the other to
*start* things; either can stop them.

In the Claude Code app the same stack is `preview_start {name: "whmcs-local"}`
(`.claude/launch.json`): that runs `up.ps1 -Foreground`, which starts MySQL
detached and then blocks on Apache, so stopping the preview stops Apache only.

## Replacing the WHMCS files

To drop in a different WHMCS build (an upgrade, or a copy of the live install):

```bash
powershell -ExecutionPolicy Bypass -File scripts/local-stack/install-whmcs-files.ps1 -Source "C:\path\to\whmcs.zip"
```

`-Source` takes a folder or a `.zip` (a zip wrapping a single top-level folder
is unwrapped for you). It stops the stack, **removes the three junctions before
copying** so nothing can write into the repo through them, copies the files,
re-creates the junctions and starts the stack again. Your `configuration.php`
is preserved unless you pass `-ResetConfig`.

## First run

1. Open `http://localhost:8088/install/install.php`.
2. DB host `localhost`, name `whmcs`, user `whmcs`, password `whmcs`.
3. Enter a WHMCS licence key valid for `localhost` (a Development licence from
   the WHMCS client area is the normal answer).
4. When the installer is done, delete `C:\laragon\www\whmcs\install\` as it asks.
5. Admin > System Settings > General Settings > Template: `hadrian`;
   Ordering > Order Form Template: `hadrian_cart`. Activate the Hadrian addon
   under Addon Modules.

The Hadrian licence-enforcement hook (`whmcs-licensing-modern`, a manual
upload on prod) is *not* installed here, so the theme renders regardless of
the addon's licence status - the admin Licence page will just say no key.

## Demo data

Once the install is finished, fill it with a plausible catalogue and customer
base so the theme can be exercised against populated pages:

```bash
php scripts/local-stack/seed-demo-data.php
```

(`php` here is `C:\laragon\bin\php\php-8.3.30-Win32-vs16-x64\php.exe`.)

Creates 5 product groups / 12 products, 14 fictional clients across 14
countries, 18 services spanning Active / Pending / Suspended / Cancelled /
Terminated, 12 domains including an expired one, a spread of paid, unpaid,
overdue and cancelled invoices, 7 tickets across two departments, and 4
announcements.

It works through WHMCS's own local API (`AddClient`, `AddProduct`, `AddOrder`,
`AcceptOrder`, `OpenTicket`) so pricing rows, service records and invoice
totals are built by WHMCS rather than by INSERTs that would drift from the
schema. Only objects with no API - product groups, ticket departments,
announcements - are written directly.

Safety: it refuses to run unless `SystemURL` points at localhost, and demo rows
carry a `hadrian-demo` marker so cleanup never touches anything else.

```bash
php scripts/local-stack/seed-demo-data.php --force
```

```bash
php scripts/local-stack/seed-demo-data.php --wipe
```

The demo client logins are local fixtures - `<handle>@demo.hadrian.test` with a
shared password the script prints when it finishes - so the client area can be
viewed with real data in it.

## Rebuilding from scratch

```bash
powershell -ExecutionPolicy Bypass -File scripts/local-stack/down.ps1
```

then remove `C:\laragon\www\whmcs` (`rmdir` on the three junctions first, or
`Remove-Item` - a junction removal never touches the repo), drop the `whmcs`
database, and repeat the copy + `mklink /J` + installer steps above.
