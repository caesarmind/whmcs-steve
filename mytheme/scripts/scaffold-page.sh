#!/usr/bin/env bash
# scripts/scaffold-page.sh — create the 5-file skeleton for a new WHMCS page.
#
# Usage: scripts/scaffold-page.sh <page-slug> "<Display Name>" <group> "<description>"
#
#   page-slug    e.g. clientregister, pwreset, contact
#   Display Name e.g. "Client Registration"
#   group        Client Area | Billing | Support | Authentication | Public
#   description  short one-line summary used in page.php
#
# Creates:
#   templates/hadrian/<page-slug>.tpl                                       (dispatcher)
#   templates/hadrian/core/pages/<page-slug>/page.php                       (metadata)
#   templates/hadrian/core/pages/<page-slug>/default/default.tpl            (markup stub)
#   templates/hadrian/core/pages/<page-slug>/default/pageoption.php         (variant settings)
#   templates/hadrian/assets/css/pages/<page-slug>.css                      (empty page CSS)
#
# Idempotent — if a file exists it's left alone.

set -euo pipefail

THEME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ $# -lt 4 ]]; then
    echo "Usage: $0 <page-slug> \"<Display Name>\" <group> \"<description>\""
    exit 1
fi

SLUG="$1"
DISPLAY="$2"
GROUP="$3"
DESC="$4"

write_if_missing() {
    local path="$1"
    if [[ -e "$path" ]]; then
        echo "skip  $path"
        return
    fi
    mkdir -p "$(dirname "$path")"
    cat > "$path"
    echo "wrote $path"
}

# 1. Dispatcher
write_if_missing "$THEME_ROOT/templates/hadrian/$SLUG.tpl" <<EOF
{if isset(\$hadrian.pages.$SLUG.fullPath) && \$hadrian.pages.$SLUG.fullPath && file_exists("templates/\`\$hadrian.pages.$SLUG.fullPath\`")}
	{include file="\`\$hadrian.pages.$SLUG.fullPath\`"}
{else}
	{include file="\`\$template\`/core/pages/$SLUG/default/default.tpl"}
{/if}
EOF

# 2. page.php metadata
write_if_missing "$THEME_ROOT/templates/hadrian/core/pages/$SLUG/page.php" <<EOF
<?php
/**
 * Page-level metadata for $SLUG ($DISPLAY).
 */
return [
    'display_name' => '$DISPLAY',
    'group'        => '$GROUP',
    'type'         => 'client-portal',
    'listDisplay'  => true,
    'description'  => '$DESC',
];
EOF

# 3. default.tpl stub
write_if_missing "$THEME_ROOT/templates/hadrian/core/pages/$SLUG/default/default.tpl" <<EOF
{* Hostnodes — $DISPLAY (Apple-style). Stub — fill in markup. *}

<link rel="stylesheet" href="{\$WEB_ROOT}/templates/{\$template}/assets/css/pages/$SLUG.css?v={\$hadrian.version|default:'1.0'}">

<header class="page-header">
    <h1>$DISPLAY</h1>
</header>

<div class="$SLUG-stub">
    <p>TODO: $SLUG content goes here.</p>
</div>
EOF

# 4. pageoption.php variant settings
write_if_missing "$THEME_ROOT/templates/hadrian/core/pages/$SLUG/default/pageoption.php" <<EOF
<?php
return [
    'display_name' => 'Default',
    'description'  => '$DESC',
    'preview'      => 'thumb.png',
    'settings'     => [],
];
EOF

# 5. CSS skeleton (page-prefixed)
write_if_missing "$THEME_ROOT/templates/hadrian/assets/css/pages/$SLUG.css" <<EOF
/* $DISPLAY — page CSS */

.page-header { margin: 8px 0 24px; }
.page-header h1 {
    font-size: 40px;
    font-weight: 600;
    letter-spacing: -0.028em;
    color: var(--color-text-primary);
    margin: 0 0 8px;
    line-height: 1.1;
}

@media (max-width: 880px) {
    .page-header h1 { font-size: 34px; }
}

@media (max-width: 480px) {
    .page-header h1 { font-size: 30px; }
}
EOF

echo "Done: $SLUG"
