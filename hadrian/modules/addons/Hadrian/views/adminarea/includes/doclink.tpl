{*
    Documentation link. One partial so every "docs" affordance in the admin
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
    - Plain text + a CSS-drawn arrow (.mt-doclink::after in admin.css), not an
      inline SVG -- the same arrow the "Learn more" line inside a tip popup
      uses (includes/tip.tpl's article/anchor params), so every doc link in
      the admin is visually one mark, defined once.
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
   target="_blank" rel="noopener" title="Open documentation for this section">docs</a>
