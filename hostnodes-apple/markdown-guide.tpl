{* =========================================================================
   markdown-guide.tpl — reference for the WHMCS markdown editor syntax.
   ========================================================================= *}
<div class="page-header">
    <h1 class="page-title">{lang key='markdown.title'}</h1>
    <p class="page-subtitle">{lang key='markdown.subtitle'}</p>
</div>

<div class="kb-grid">
    <div class="card">
        <div class="card-header"><h3 class="card-title">{lang key='markdown.headings'}</h3></div>
        <div class="card-body"><pre><code># H1
## H2
### H3</code></pre></div>
    </div>
    <div class="card">
        <div class="card-header"><h3 class="card-title">{lang key='markdown.emphasis'}</h3></div>
        <div class="card-body"><pre><code>**bold**
*italic*
~~strikethrough~~</code></pre></div>
    </div>
    <div class="card">
        <div class="card-header"><h3 class="card-title">{lang key='markdown.lists'}</h3></div>
        <div class="card-body"><pre><code>- Item 1
- Item 2
  - Nested

1. First
2. Second</code></pre></div>
    </div>
    <div class="card">
        <div class="card-header"><h3 class="card-title">{lang key='markdown.links'}</h3></div>
        <div class="card-body"><pre><code>[Link text](https://example.com)
![Alt](image.jpg)</code></pre></div>
    </div>
    <div class="card">
        <div class="card-header"><h3 class="card-title">{lang key='markdown.code'}</h3></div>
        <div class="card-body"><pre><code>`inline code`

```
code block
```</code></pre></div>
    </div>
    <div class="card">
        <div class="card-header"><h3 class="card-title">{lang key='markdown.quotes'}</h3></div>
        <div class="card-body"><pre><code>&gt; Blockquote
---
Horizontal rule</code></pre></div>
    </div>
</div>
