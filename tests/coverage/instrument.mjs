// Branch instrumentation for Smarty templates.
//
// WHMCS gives us no PHP coverage driver on this stack, so coverage is measured
// in the OUTPUT instead: every branch of every {if} / {foreach} in a copy of
// the templates gets a marker that only reaches the HTML when that branch runs.
//
//   {if $a}X{/if}              ->  {if $a}@@hc:1@@X{else}@@hc:2@@{/if}
//   {if $a}X{elseif $b}Y{/if}  ->  {if $a}@@hc:1@@X{elseif $b}@@hc:2@@Y{else}@@hc:3@@{/if}
//   {foreach $l as $i}X{/foreach} -> {foreach $l as $i}@@hc:4@@X{foreachelse}@@hc:5@@{/foreach}
//
// The implicit {else}/{foreachelse} is what makes this BRANCH coverage, not
// line coverage: "the list was empty" and "the condition was false" are
// branches too, and they are exactly the when-empty states the theme has to
// get right.
//
// Markers are plain ASCII text, so they survive escaping. They land inside
// attributes and <script> blocks too, which is why instrumented output is
// only ever read over HTTP and stripped (strip()) before anything else sees
// it - never executed in a browser.
//
// Not instrumented: {literal} blocks (no Smarty there) and {capture} blocks
// (templates test captured output for emptiness - "show Last chance only
// when a hook returns real markup" - and a marker would make it non-empty).

export const MARK = /@@hc:(\d+)@@/g;
export const strip = html => html.replace(MARK, '');

/**
 * @param {string} src     template source
 * @param {string} file    path, for the report
 * @param {() => number} nextId  global id allocator
 * @returns {{ out: string, points: {id:number, file:string, line:number, kind:string, cond:string}[], skipped: number }}
 */
export function instrument(src, file, nextId) {
  const points = [];
  const stack = [];          // open {if}/{foreach}: { tag, hasElse }
  let out = '';
  let i = 0;
  let line = 1;
  let capture = 0;           // depth of {capture} - no markers inside
  let skipped = 0;

  const lineAt = upto => { for (let k = i; k < upto; k++) if (src.charCodeAt(k) === 10) line++; };
  const point = (kind, cond, at) => {
    if (capture) { skipped++; return ''; }
    const id = nextId();
    points.push({ id, file, line: at, kind, cond: cond.replace(/\s+/g, ' ').trim().slice(0, 120) });
    return `@@hc:${id}@@`;
  };

  while (i < src.length) {
    const open = src.indexOf('{', i);
    if (open < 0) { out += src.slice(i); break; }
    lineAt(open);
    out += src.slice(i, open);
    i = open;

    // Smarty comment {* ... *}
    if (src.startsWith('{*', i)) {
      const end = src.indexOf('*}', i + 2);
      const stop = end < 0 ? src.length : end + 2;
      out += src.slice(i, stop); lineAt(stop); i = stop; continue;
    }
    // auto_literal: "{" followed by whitespace is not a tag (JS/CSS braces).
    if (/\s/.test(src[i + 1] || ' ')) { out += '{'; i++; continue; }

    // Find the closing "}" of this tag, ignoring braces inside quotes.
    let j = i + 1, q = null;
    for (; j < src.length; j++) {
      const ch = src[j];
      if (q) { if (ch === '\\') { j++; continue; } if (ch === q) q = null; continue; }
      if (ch === '"' || ch === "'") { q = ch; continue; }
      if (ch === '}') break;
    }
    const tagEnd = j + 1;
    const tag = src.slice(i, tagEnd);
    const body = tag.slice(1, -1);
    let name = (body.match(/^\/?[a-zA-Z_]+/) || [''])[0].toLowerCase();
    if (name === 'else' && /^else\s+if\b/i.test(body)) name = 'elseif';   // "{else if}" is an elseif
    const at = line;

    if (name === 'literal') {
      const end = src.indexOf('{/literal}', tagEnd);
      const stop = end < 0 ? src.length : end + '{/literal}'.length;
      out += src.slice(i, stop); lineAt(stop); i = stop; continue;
    }

    let insertBefore = '', insertAfter = '';
    switch (name) {
      case 'capture': capture++; break;
      case '/capture': capture = Math.max(0, capture - 1); break;
      case 'if':
        stack.push({ tag: 'if', hasElse: false, line: at, cond: body.slice(2) });
        insertAfter = point('if', body.slice(2), at); break;
      case 'elseif':
        insertAfter = point('elseif', body.replace(/^else\s*if/i, ''), at); break;
      case 'else':
        if (stack.length) stack[stack.length - 1].hasElse = true;
        insertAfter = point('else', 'else of line ' + (stack.at(-1)?.line ?? '?'), at); break;
      case '/if': {
        const top = stack.pop();
        if (top && !top.hasElse) {
          const m = point('else', `(implicit) not: ${top.cond}`, top.line);
          if (m) insertBefore = `{else}${m}`;
        }
        break;
      }
      case 'foreach':
        stack.push({ tag: 'foreach', hasElse: false, line: at, cond: body.slice(7) });
        insertAfter = point('foreach', body.slice(7), at); break;
      case 'foreachelse':
        if (stack.length) stack[stack.length - 1].hasElse = true;
        insertAfter = point('foreachelse', 'empty: ' + (stack.at(-1)?.cond ?? ''), at); break;
      case '/foreach': {
        const top = stack.pop();
        if (top && !top.hasElse) {
          const m = point('foreachelse', `(implicit) empty: ${top.cond}`, top.line);
          if (m) insertBefore = `{foreachelse}${m}`;
        }
        break;
      }
    }
    out += insertBefore + tag + insertAfter;
    lineAt(tagEnd);
    i = tagEnd;
  }
  return { out, points, skipped };
}
