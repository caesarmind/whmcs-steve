{*
    Info-tooltip trigger. One partial so every icon is identical.

      {include file="includes/tip.tpl" text="Plain sentence, no HTML."}

    - A real <button type="button">, so it is keyboard reachable and never
      submits a form. aria-label carries the copy, so a screen reader reads the
      whole tip on focus without any aria-describedby plumbing.
    - The 12x12 circle-i is the same shape Lagom uses, but drawn with
      currentColor (not a baked hex) so it themes. The popup itself is rendered
      at document.body by the controller in footer.tpl, keyed off data-tip.
    - Place it OUTSIDE any <label for=...>: a button inside a label inherits the
      label's activation and would focus/open the labelled control.
*}
<button type="button" class="mt-tip" data-tip="{$text|escape}"
        aria-label="{$text|escape}" tabindex="0">
    <svg viewBox="0 0 12 12" width="12" height="12" fill="none" aria-hidden="true">
        <circle cx="6" cy="6" r="5.5" stroke="currentColor"/>
        <path d="M7 6V9H5V6H7ZM5 5V3H7V5H5Z" fill="currentColor"/>
    </svg>
</button>
