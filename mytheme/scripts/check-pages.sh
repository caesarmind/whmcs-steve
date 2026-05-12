#!/usr/bin/env bash
# scripts/check-pages.sh — verify Hostnodes WHMCS theme pages.
#
# Subcommands:
#   files   [page...]   — every page has all 5 files + git-tracked CSS
#   lint    [page...]   — grep tpl/css for known anti-patterns (PAGE-CHECKLIST §3 + §10)
#   live    [page...]   — curl live URL, confirm content-area not empty + state-chip present
#   assets  [page...]   — curl CSS reachability (HTTP 200) + freshness (local SHA vs served SHA)
#   all     [page...]   — run files + lint locally, live + assets if BASE_URL set
#
# With no [page...] args, all pages from scripts/pages.csv are checked.
#
# Env:
#   BASE_URL   — live site (default: https://bill.hostnodes.com)
#   COOKIES    — path to a logged-in cookies.txt (default: scripts/cookies.txt)

set -uo pipefail

THEME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CSV="$THEME_ROOT/scripts/pages.csv"
BASE_URL="${BASE_URL:-https://bill.hostnodes.com}"
COOKIES="${COOKIES:-$THEME_ROOT/scripts/cookies.txt}"

# Color codes (ANSI; gracefully degrade if terminal doesn't support them).
if [[ -t 1 ]]; then
    R="\033[0;31m"; G="\033[0;32m"; Y="\033[0;33m"; B="\033[0;34m"; X="\033[0m"
else
    R=""; G=""; Y=""; B=""; X=""
fi

fail_count=0
pass_count=0
warn_count=0

fail() { echo -e "${R}FAIL${X} $*"; fail_count=$((fail_count+1)); }
pass() { echo -e "${G}PASS${X} $*"; pass_count=$((pass_count+1)); }
warn() { echo -e "${Y}WARN${X} $*"; warn_count=$((warn_count+1)); }
info() { echo -e "${B}info${X} $*"; }

# Read pages from CSV (skipping header).
all_pages() {
    awk -F, 'NR>1 && $1 !~ /^#/ { print $1 }' "$CSV"
}

# Look up url / prefix for a page from CSV.
page_url()    { awk -F, -v p="$1" 'NR>1 && $1==p { print $2; exit }' "$CSV"; }
page_prefix() { awk -F, -v p="$1" 'NR>1 && $1==p { print $3; exit }' "$CSV"; }

# Resolve [page...] args; default to all pages from CSV.
resolve_pages() {
    if [[ $# -eq 0 ]]; then
        all_pages
    else
        printf '%s\n' "$@"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# (a) File-completeness audit
# ─────────────────────────────────────────────────────────────────────────────
cmd_files() {
    local pages
    mapfile -t pages < <(resolve_pages "$@")

    for page in "${pages[@]}"; do
        local rel_dispatcher="templates/mytheme/${page}.tpl"
        local rel_page="templates/mytheme/core/pages/${page}/page.php"
        local rel_default="templates/mytheme/core/pages/${page}/default/default.tpl"
        local rel_opt="templates/mytheme/core/pages/${page}/default/pageoption.php"
        local rel_css="templates/mytheme/assets/css/pages/${page}.css"

        local entries=(
            "dispatcher|$rel_dispatcher"
            "page.php|$rel_page"
            "default.tpl|$rel_default"
            "pageoption.php|$rel_opt"
            "css|$rel_css"
        )

        for entry in "${entries[@]}"; do
            local label="${entry%%|*}"
            local rel="${entry#*|}"
            local abs="$THEME_ROOT/$rel"
            if [[ -f "$abs" ]]; then
                pass "$page · $label · present"
            else
                fail "$page · $label · MISSING ($rel)"
            fi
        done

        # CSS must be git-tracked (§10 gotcha — untracked CSS = 404 on live).
        if [[ -f "$THEME_ROOT/$rel_css" ]]; then
            if (cd "$THEME_ROOT" && git ls-files --error-unmatch "$rel_css" >/dev/null 2>&1); then
                pass "$page · css · git-tracked"
            else
                fail "$page · css · EXISTS BUT NOT GIT-TRACKED ($rel_css)"
            fi
        fi
    done
}

# ─────────────────────────────────────────────────────────────────────────────
# (b) Anti-pattern lint
# ─────────────────────────────────────────────────────────────────────────────
cmd_lint() {
    local pages
    mapfile -t pages < <(resolve_pages "$@")

    for page in "${pages[@]}"; do
        local tpl="$THEME_ROOT/templates/mytheme/core/pages/${page}/default/default.tpl"
        local css="$THEME_ROOT/templates/mytheme/assets/css/pages/${page}.css"

        # Smarty: inline assignment {$x = y} (§3)
        if [[ -f "$tpl" ]] && grep -nE '\{\$[a-zA-Z_]+ *= [^}]+\}' "$tpl" >/dev/null 2>&1; then
            fail "$page · tpl uses {\$x = y} inline assignment (use {assign var=x value=y})"
            grep -nE '\{\$[a-zA-Z_]+ *= [^}]+\}' "$tpl" | head -3 | sed 's/^/      /'
        else
            [[ -f "$tpl" ]] && pass "$page · tpl · no {\$x = y} assignment"
        fi

        # Smarty: |count (Collection-unsafe) — must be |@count (§3)
        if [[ -f "$tpl" ]] && grep -nE '\|count[^a-zA-Z_]' "$tpl" >/dev/null 2>&1; then
            fail "$page · tpl uses |count (use |@count for Collection safety)"
            grep -nE '\|count[^a-zA-Z_]' "$tpl" | head -3 | sed 's/^/      /'
        else
            [[ -f "$tpl" ]] && pass "$page · tpl · no |count (uses |@count)"
        fi

        # Smarty: custom foreach iterator (§10 gotcha — $x@idx is invalid)
        if [[ -f "$tpl" ]] && grep -nE 'as +\$[a-zA-Z_]+@[a-zA-Z_]+' "$tpl" >/dev/null 2>&1; then
            fail "$page · tpl has invalid foreach iterator (as \$x@custom — Smarty doesn't support)"
            grep -nE 'as +\$[a-zA-Z_]+@[a-zA-Z_]+' "$tpl" | head -3 | sed 's/^/      /'
        else
            [[ -f "$tpl" ]] && pass "$page · tpl · valid foreach iterators"
        fi

        # Dispatcher: $myTheme.pages.<hyphenated-name>.fullPath in templates/mytheme/<page>.tpl
        # — Smarty parses dot-notation with hyphens as SUBTRACTION, silently produces empty
        #   content-area. Must use bracket form: $myTheme.pages['hyphenated-name'].fullPath.
        if [[ "$page" == *-* ]]; then
            local dispatcher="$THEME_ROOT/templates/mytheme/${page}.tpl"
            if [[ -f "$dispatcher" ]] && grep -nE '\$myTheme\.pages\.[a-zA-Z0-9_-]+-[a-zA-Z0-9_-]+\.fullPath' "$dispatcher" >/dev/null 2>&1; then
                fail "$page · dispatcher uses \$myTheme.pages.${page}.fullPath (Smarty parses hyphens as subtraction; use \$myTheme.pages['${page}'].fullPath)"
                grep -nE '\$myTheme\.pages\.[a-zA-Z0-9_-]+-[a-zA-Z0-9_-]+\.fullPath' "$dispatcher" | head -2 | sed 's/^/      /'
            else
                [[ -f "$dispatcher" ]] && pass "$page · dispatcher · hyphenated page key uses bracket notation"
            fi
        fi

        # CSS: body { display: block } (§6 rule 5 — breaks flex layout chain)
        if [[ -f "$css" ]] && grep -nE 'body\s*\{[^}]*display:\s*block' "$css" >/dev/null 2>&1; then
            fail "$page · css sets body { display: block } (breaks flex chain, §6 rule 5)"
        else
            [[ -f "$css" ]] && pass "$page · css · no body { display: block }"
        fi

        # CSS: data-subnav-side="outside" without :not([data-layout="top"]) scoping (§6c)
        if [[ -f "$css" ]] && grep -nE 'data-subnav-side="outside' "$css" >/dev/null 2>&1; then
            # Must always be paired with :not([data-layout="top"])
            local unscoped
            unscoped=$(grep -nE 'data-subnav-side="outside[^"]*"\][^{]*\{' "$css" | grep -v 'data-layout="top"' || true)
            if [[ -n "$unscoped" ]]; then
                # Some rules legitimately don't need the scoping (.split aside positioning), so warn not fail.
                # Only fail if rule uses translateX or margin-left on .content-area.
                local risky
                risky=$(echo "$unscoped" | grep -E '(translateX|margin-left)' || true)
                if [[ -n "$risky" ]]; then
                    fail "$page · css has unscoped data-subnav-side outside rule that transforms .content-area (§6c)"
                    echo "$risky" | head -3 | sed 's/^/      /'
                fi
            fi
        fi
    done

    # Lint hooks.php for the register hook pattern bugs.
    local hooks_php="$THEME_ROOT/modules/addons/MyTheme/hooks.php"
    if [[ -f "$hooks_php" ]]; then
        if grep -nE 'ClientAreaPage[A-Za-z]+' "$hooks_php" >/dev/null 2>&1; then
            pass "hooks.php · has ClientAreaPage hook registrations"
        else
            warn "hooks.php · no ClientAreaPage hook registrations found"
        fi
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# (c) Live URL probe
# ─────────────────────────────────────────────────────────────────────────────
cmd_live() {
    local pages
    mapfile -t pages < <(resolve_pages "$@")

    if [[ ! -f "$COOKIES" ]]; then
        warn "no cookies file at $COOKIES — live checks will hit the login redirect; many checks won't be meaningful"
    fi

    for page in "${pages[@]}"; do
        local url
        url="$(page_url "$page")"
        if [[ -z "$url" ]]; then
            warn "$page · no URL in pages.csv — skip"
            continue
        fi

        local prefix
        prefix="$(page_prefix "$page")"
        local full="$BASE_URL$url"

        local tmp
        tmp="$(mktemp)"
        local http_code
        http_code=$(curl -sL -b "$COOKIES" -c "$COOKIES" -o "$tmp" -w "%{http_code}" "$full" 2>/dev/null || echo "000")

        if [[ "$http_code" != "200" ]]; then
            fail "$page · HTTP $http_code at $url"
            rm -f "$tmp"
            continue
        fi

        # content-area must contain *something*. Anything other than only whitespace is OK.
        # Use Perl-style multiline match via tr to flatten then grep.
        local content
        content=$(tr '\n' ' ' < "$tmp" | grep -oE '<div class="content-area">[^<]*' | head -1 | sed -E 's/<div class="content-area">[[:space:]]*//')
        if [[ -z "${content// }" ]]; then
            # Either empty literally, or the next char after content-area is <. Check more thoroughly.
            local body_chunk
            body_chunk=$(tr '\n' ' ' < "$tmp" | grep -oE '<div class="content-area">.*</div>[[:space:]]*<footer' | head -1)
            if echo "$body_chunk" | grep -qE '<div class="content-area">[[:space:]]*</div>'; then
                fail "$page · .content-area is empty (silent Smarty compile fail or missing dispatcher — §10)"
                rm -f "$tmp"
                continue
            fi
        fi
        pass "$page · .content-area · not empty"

        # state-chip must be present (every page has the preview chip).
        if grep -q 'class="state-chip"' "$tmp"; then
            pass "$page · state-chip · present"
        else
            warn "$page · state-chip · NOT FOUND (preview chip may not be rendering)"
        fi

        # Page-prefixed class hook should appear (e.g. .inv-* for invoices).
        if [[ -n "$prefix" ]] && grep -q "class=\"$prefix" "$tmp"; then
            pass "$page · class hook ($prefix-*) · present"
        elif [[ -n "$prefix" ]]; then
            warn "$page · class hook ($prefix-*) · not found (template might not have rendered)"
        fi

        rm -f "$tmp"
    done
}

# ─────────────────────────────────────────────────────────────────────────────
# (d) Asset reachability + freshness
# ─────────────────────────────────────────────────────────────────────────────
cmd_assets() {
    local pages
    mapfile -t pages < <(resolve_pages "$@")

    for page in "${pages[@]}"; do
        local local_css="$THEME_ROOT/templates/mytheme/assets/css/pages/${page}.css"
        local remote_url="$BASE_URL/templates/mytheme/assets/css/pages/${page}.css"

        if [[ ! -f "$local_css" ]]; then
            warn "$page · local css missing ($local_css) — skip asset check"
            continue
        fi

        # HTTP 200?
        local http_code
        http_code=$(curl -sI "$remote_url" -o /dev/null -w "%{http_code}" 2>/dev/null || echo "000")
        if [[ "$http_code" == "200" ]]; then
            pass "$page · css HTTP $http_code"
        else
            fail "$page · css HTTP $http_code (expected 200) at $remote_url"
            continue
        fi

        # SHA-1 match? (catches stale deploy or CDN cache.)
        local local_sha remote_sha
        local_sha=$(sha1sum "$local_css" | awk '{print $1}')
        remote_sha=$(curl -s "$remote_url" | sha1sum | awk '{print $1}')
        if [[ "$local_sha" == "$remote_sha" ]]; then
            pass "$page · css SHA match (deploy fresh)"
        else
            warn "$page · css SHA mismatch: local=${local_sha:0:10} remote=${remote_sha:0:10} (stale deploy or cache)"
        fi
    done
}

# ─────────────────────────────────────────────────────────────────────────────
# (all) run everything in order
# ─────────────────────────────────────────────────────────────────────────────
cmd_all() {
    info "── files ──"
    cmd_files "$@"
    info "── lint ──"
    cmd_lint "$@"
    if [[ -f "$COOKIES" ]]; then
        info "── live ──"
        cmd_live "$@"
    else
        info "── live skipped (no cookies file at $COOKIES) ──"
    fi
    info "── assets ──"
    cmd_assets "$@"
}

# ─────────────────────────────────────────────────────────────────────────────
# Dispatch
# ─────────────────────────────────────────────────────────────────────────────
case "${1:-}" in
    files)  shift; cmd_files "$@" ;;
    lint)   shift; cmd_lint "$@" ;;
    live)   shift; cmd_live "$@" ;;
    assets) shift; cmd_assets "$@" ;;
    all)    shift; cmd_all "$@" ;;
    list)   all_pages ;;
    "")
        cat >&2 <<EOF
Usage: $0 <files|lint|live|assets|all|list> [page...]

  files   confirm 5 files exist for each page + CSS is git-tracked
  lint    grep tpl/css for known PAGE-CHECKLIST anti-patterns
  live    curl live URL, confirm .content-area not empty + chip present
  assets  curl CSS reachability + SHA freshness check
  all     run all four (live skipped if no cookies.txt)
  list    print every page name in scripts/pages.csv

With no [page...] args, all pages from scripts/pages.csv are checked.

Env:
  BASE_URL   default https://bill.hostnodes.com
  COOKIES    default scripts/cookies.txt
EOF
        exit 1
        ;;
    *)
        echo "Unknown subcommand: $1" >&2
        exit 1
        ;;
esac

echo
echo -e "Summary: ${G}${pass_count} passed${X}, ${R}${fail_count} failed${X}, ${Y}${warn_count} warnings${X}"
exit $(( fail_count > 0 ? 1 : 0 ))
