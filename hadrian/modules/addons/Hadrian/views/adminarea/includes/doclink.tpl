{*
    Documentation link. One partial so every "Docs" affordance in the admin
    points at the same base URL and looks identical.

      {include file="includes/doclink.tpl" article="styles" anchor="colors"}
      {include file="includes/doclink.tpl" article="settings"}

    - `article` is the doc's slug under docs.hadrianthegreat.com/client-theme/
      (the `slug:` frontmatter in hadrian-documentation/content/client-theme/,
      or the numeric filename with its prefix stripped when there is no
      explicit slug).
    - `anchor` is optional -- the id a `##`/`###` heading gets, i.e.
      slugify(heading text) as scripts/build-docs.mjs computes it. Omit it to
      link the article's top.
    - Opens in a new tab: this is reference material consulted mid-edit, not a
      navigation away from the settings the admin has open.
    - Self-contained on purpose -- the base URL is a literal below, not read
      off $viewHelper or any injected var. Every .dashbuild/build-*-harness.php
      fetches a bare page/section template directly (never through
      includes/header.tpl), each with its OWN hand-rolled $viewHelper stub
      that only implements url(). Reading the base off $viewHelper would 500
      in every one of those harnesses the moment they render a block that
      carries a doc link -- i.e. immediately, since this partial is now on
      most of them. A literal here means zero PHP touched, on either side.
*}
{assign var="mtDocsBase" value="https://docs.hadrianthegreat.com/client-theme"}
<a class="mt-doclink" href="{$mtDocsBase}/{$article|escape}/{if $anchor}#{$anchor|escape}{/if}"
   target="_blank" rel="noopener" title="Open documentation for this section">
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
        <path d="M3 2.5h6.5L13 6v7.5a1 1 0 01-1 1H3a1 1 0 01-1-1v-10a1 1 0 011-1z" stroke="currentColor" stroke-width="1.4" stroke-linejoin="round"/>
        <path d="M9.5 2.5V6H13" stroke="currentColor" stroke-width="1.4" stroke-linejoin="round"/>
        <path d="M5 9h6M5 11.5h4" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/>
    </svg>
    <span>Docs</span>
</a>
