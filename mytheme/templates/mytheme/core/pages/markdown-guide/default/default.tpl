{* Hostnodes - Markdown guide (Apple-style): syntax reference (static content). *}
{assign var=dashIsEmpty value='full'}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/markdown-guide.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'off');
})();
</script>

<header class="page-header">
    <p class="page-eyebrow">{$LANG.supporttab|default:'Support'}</p>
    <h1>{$LANG['markdown.title']}</h1>
    <p class="page-subtitle">{$hadrianLang.support.markdownGuideIntro}</p>
</header>

<div class="md-wrap">
    <div class="md-grid">
        <div class="card md-section">
            <h2 class="md-section-title"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 7V4h16v3"/><line x1="9" y1="20" x2="15" y2="20"/><line x1="12" y1="4" x2="12" y2="20"/></svg>{$LANG['markdown.emphasis']}</h2>
            <pre class="md-pre">**<strong>{$LANG['markdown.bold']}</strong>**
*<em>{$LANG['markdown.italics']}</em>*
~~{$hadrianLang.support.markdownStrikethrough}~~</pre>
        </div>

        <div class="card md-section">
            <h2 class="md-section-title"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M6 4v16"/><path d="M18 4v16"/><path d="M6 12h12"/></svg>{$LANG['markdown.headers']}</h2>
            <pre class="md-pre"># {$LANG['markdown.bigHeader']}
## {$LANG['markdown.mediumHeader']}
### {$LANG['markdown.smallHeader']}</pre>
        </div>

        <div class="card md-section">
            <h2 class="md-section-title"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>{$LANG['markdown.lists']}</h2>
            <pre class="md-pre">* {$LANG['markdown.genericListItem']}
* {$LANG['markdown.genericListItem']}

1. {$LANG['markdown.numberedListItem']}
2. {$LANG['markdown.numberedListItem']}</pre>
        </div>

        <div class="card md-section">
            <h2 class="md-section-title"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/></svg>{$LANG['markdown.links']}</h2>
            <pre class="md-pre">[{$LANG['markdown.textToDisplay']}](https://example.com)</pre>
        </div>

        <div class="card md-section">
            <h2 class="md-section-title"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>{$LANG['markdown.quotes']}</h2>
            <pre class="md-pre">&gt; {$LANG['markdown.thisIsAQuote']}
&gt; {$LANG['markdown.quoteMultipleLines']}</pre>
        </div>

        <div class="card md-section">
            <h2 class="md-section-title"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg>{$LANG['markdown.displayingCode']}</h2>
            <pre class="md-pre">`var example = "hello";`

```
{$LANG['markdown.spanningMultipleLines']}
```</pre>
        </div>
    </div>

    <div class="card md-section" style="margin-top:16px;">
        <h2 class="md-section-title"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="3" y1="15" x2="21" y2="15"/><line x1="12" y1="3" x2="12" y2="21"/></svg>{$LANG['markdown.tables']}</h2>
        <pre class="md-pre">| {$LANG['markdown.columnOne']} | {$LANG['markdown.columnTwo']} |
| -------- | -------- |
| {$LANG['markdown.john']} | {$LANG['markdown.doe']} |
| {$LANG['markdown.mary']} | {$LANG['markdown.smith']} |</pre>
        <p class="md-note">{$hadrianLang.support.markdownTablesNote}</p>
    </div>
</div>
