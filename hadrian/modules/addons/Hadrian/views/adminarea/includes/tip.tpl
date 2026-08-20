{*
    Info-tooltip trigger. One partial so every icon is identical.

      {include file="includes/tip.tpl" text="Plain sentence, no HTML."}
      {include file="includes/tip.tpl" text="Plain sentence, no HTML." article="settings" anchor="enable-dark-mode"}

    - A real <button type="button">, so it is keyboard reachable and never
      submits a form. aria-label carries the copy, so a screen reader reads the
      whole tip on focus without any aria-describedby plumbing.
    - The 12x12 circle-i is the same shape Lagom uses, but drawn with
      currentColor (not a baked hex) so it themes. The popup itself is rendered
      at document.body by the controller in footer.tpl, keyed off data-tip.
    - Place it OUTSIDE any <label for=...>: a button inside a label inherits the
      label's activation and would focus/open the labelled control.
    - `article` (+ optional `anchor`) adds a "Learn more" line to the popup,
      pointing at docs.hadrianthegreat.com/client-theme/<article>/#<anchor>.
      Both params are optional; omit them for a plain tip with no doc link.
      The base URL is the same literal includes/doclink.tpl uses, for the same
      reason: every .dashbuild/build-*-admin-harness.php renders this partial
      through a $viewHelper stub that only implements url(), so reading the
      base off it would break every harness the instant it hit a tip that
      carries one.
*}
{if $article}{assign var="mtTipDocsBase" value="https://docs.hadrianthegreat.com/client-theme"}{/if}
<button type="button" class="mt-tip" data-tip="{$text|escape}"
        {if $article}data-tip-href="{$mtTipDocsBase}/{$article|escape}/{if $anchor}#{$anchor|escape}{/if}"{/if}
        aria-label="{$text|escape}" tabindex="0">
    <svg viewBox="0 0 12 12" width="12" height="12" fill="none" aria-hidden="true">
        <circle cx="6" cy="6" r="5.5" stroke="currentColor"/>
        <path d="M7 6V9H5V6H7ZM5 5V3H7V5H5Z" fill="currentColor"/>
    </svg>
</button>
