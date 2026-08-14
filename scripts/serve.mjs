// Zero-dependency static dev server for the apple-client-area HTML mockups.
//
//   node scripts/serve.mjs            -> serves apple-client-area/ on :3002
//   node scripts/serve.mjs 4000       -> custom port
//   node scripts/serve.mjs ./mytheme  -> custom root dir
//
// GET /            -> live, always-in-sync page list (re-scanned every request)
// GET /<file>      -> static file from the root dir (html, css, js, img, partials)
//
// The page list is generated from the actual files on disk, so newly added
// pages show up the moment you refresh -- no build step.

import http from "node:http";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, "..");

// ---- args ----------------------------------------------------------------
const args = process.argv.slice(2);
let PORT = 3002;
let ROOT = path.join(PROJECT_ROOT, "apple-client-area");
for (const a of args) {
  if (/^\d+$/.test(a)) PORT = Number(a);
  else ROOT = path.resolve(PROJECT_ROOT, a);
}
if (!fs.existsSync(ROOT) || !fs.statSync(ROOT).isDirectory()) {
  console.error("Root directory not found: " + ROOT);
  process.exit(1);
}

// ---- content types -------------------------------------------------------
const TYPES = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".mjs": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".map": "application/json; charset=utf-8",
  ".svg": "image/svg+xml",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".gif": "image/gif",
  ".webp": "image/webp",
  ".avif": "image/avif",
  ".ico": "image/x-icon",
  ".woff": "font/woff",
  ".woff2": "font/woff2",
  ".ttf": "font/ttf",
  ".otf": "font/otf",
  ".md": "text/plain; charset=utf-8",
  ".txt": "text/plain; charset=utf-8",
  ".webmanifest": "application/manifest+json",
};
const typeFor = (p) => TYPES[path.extname(p).toLowerCase()] || "application/octet-stream";

// ---- page label + grouping ----------------------------------------------
function labelFor(file, abs) {
  let head = "";
  try {
    const fd = fs.openSync(abs, "r");
    const buf = Buffer.alloc(8192);
    const n = fs.readSync(fd, buf, 0, 8192, 0);
    fs.closeSync(fd);
    head = buf.toString("utf8", 0, n);
  } catch {
    /* fall through to filename */
  }
  let dpt = (head.match(/data-page-title="([^"]*)"/i) || [])[1];
  if (dpt && dpt.trim()) return dpt.trim();
  let title = (head.match(/<title>([\s\S]*?)<\/title>/i) || [])[1];
  if (title && title.trim()) {
    // strip the common " - WHMCS by Apple" / " -- WHMCS by Apple" suffix
    return title.replace(/\s*[\-–—]+\s*WHMCS by Apple\s*$/i, "").trim() || title.trim();
  }
  return file.replace(/\.html$/i, "");
}

// Ordered category rules; first match wins. Anything unmatched -> "Other".
const MARKETING = new Set([
  "index.html", "homepage.html", "portal-home.html", "cloud-hosting.html", "vps.html",
  "domains.html", "ssl-certificates.html", "email.html", "email-services.html",
  "website-builder.html", "website-security.html", "website-backup.html", "seo-tools.html",
  "site-builder.html", "builder.html", "support-page.html", "sitelock-vpn.html",
  "nordvpn.html", "monitoring-360.html", "xovi-now.html", "socialbee.html",
  "domain-pricing.html", "usagebillingpricing.html", "partners.html", "contact.html",
]);
const re = (rx) => (f) => rx.test(f);
const RULES = [
  ["Marketing & Public", (f) => MARKETING.has(f)],
  ["Auth & Onboarding", re(/^(login|clientregister|password-reset|twofactor|user-verify-email|user-invite-accept|user-password|remotemodulelogin|contactaccessdenied|downloaddenied)/)],
  ["Dashboard", re(/^clientareahome/)],
  ["Domains", re(/(domain|whois|smartdomainsearch)/)],
  ["Services & Products", re(/^(clientareaproduct|upgrade|subscription-manage|bundle-configure|configureproduct)/)],
  ["Billing & Payments", re(/^(clientareainvoices|viewinvoice|invoice|clientareaaddfunds|clientareacredit|account-paymentmethods|paymentmethodsadd|masspay|clientareaquotes|viewquote|quotepdf|clientareacancelrequest|viewbillingnote)/)],
  ["Support & Help", re(/^(support|viewticket|ticketfeedback|knowledgebase|downloads|serverstatus)/)],
  ["SSL", re(/ssl/)],
  ["Order Form (cart)", re(/^(cart|checkout|store)/)],
  ["Account & Users", re(/^(clientareadetails|clientareasecurity|account-|user-|clientareaemails|viewemail)/)],
  ["Email & Announcements", re(/^(announcements|viewannouncement)/)],
];

function groupFor(file) {
  for (const [name, test] of RULES) if (test(file)) return name;
  return "Other";
}
const GROUP_ORDER = RULES.map((r) => r[0]).concat(["Other"]);

function listHtmlFiles(dir) {
  return fs
    .readdirSync(dir, { withFileTypes: true })
    .filter((d) => d.isFile() && /\.html$/i.test(d.name))
    .map((d) => d.name)
    .sort((a, b) => a.localeCompare(b));
}

const esc = (s) =>
  String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");

function renderIndex() {
  const files = listHtmlFiles(ROOT);
  const groups = new Map(GROUP_ORDER.map((g) => [g, []]));
  for (const f of files) {
    const g = groupFor(f);
    groups.get(g).push({ file: f, label: labelFor(f, path.join(ROOT, f)) });
  }
  const sections = GROUP_ORDER.filter((g) => groups.get(g).length).map((g) => {
    const items = groups.get(g);
    const rows = items
      .map(
        (it) =>
          '<li class="row" data-search="' +
          esc((it.label + " " + it.file).toLowerCase()) +
          '"><a class="open" href="/' +
          esc(it.file) +
          '"><span class="lbl">' +
          esc(it.label) +
          '</span><span class="file">' +
          esc(it.file) +
          "</span></a></li>"
      )
      .join("");
    return (
      '<section class="grp"><h2>' +
      esc(g) +
      ' <span class="gn">' +
      items.length +
      "</span></h2><ul>" +
      rows +
      "</ul></section>"
    );
  });

  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Page list - apple-client-area</title>
<style>
  :root{--bg:#f5f5f7;--surface:#fff;--border:#e2e2e7;--text:#1d1d1f;--text2:#6e6e73;--text3:#8e8e93;--accent:#0071e3;--radius:12px;--mono:ui-monospace,"SF Mono",Menlo,Consolas,monospace;--sans:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;}
  *{box-sizing:border-box;}
  html,body{margin:0;}
  body{font-family:var(--sans);background:var(--bg);color:var(--text);font-size:14px;line-height:1.45;-webkit-font-smoothing:antialiased;}
  a{color:inherit;text-decoration:none;}
  .wrap{max-width:1080px;margin:0 auto;padding:28px 20px 80px;}
  header.head h1{font-size:26px;font-weight:600;letter-spacing:-.02em;margin:0 0 4px;}
  header.head p{margin:0;color:var(--text2);}
  header.head code{font-family:var(--mono);background:#ececf0;padding:1px 6px;border-radius:6px;font-size:12.5px;color:var(--text2);}
  .bar{position:sticky;top:0;z-index:5;background:var(--bg);padding:16px 0;margin-top:14px;}
  .bar input{width:100%;font-family:var(--sans);font-size:15px;padding:11px 16px;border:1px solid var(--border);border-radius:999px;background:var(--surface);color:var(--text);outline:none;}
  .bar input:focus{border-color:var(--accent);box-shadow:0 0 0 4px rgba(0,113,227,.12);}
  .meta{margin:2px 2px 0;color:var(--text3);font-size:12px;}
  .grp{margin-top:22px;}
  .grp h2{font-size:13px;font-weight:600;text-transform:uppercase;letter-spacing:.05em;color:var(--text3);margin:0 0 10px 2px;}
  .grp h2 .gn{color:var(--text3);opacity:.7;font-weight:500;}
  .grp ul{list-style:none;margin:0;padding:0;display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:8px;}
  .row a{display:flex;flex-direction:column;gap:2px;background:var(--surface);border:1px solid var(--border);border-radius:var(--radius);padding:11px 14px;transition:border-color .12s,transform .04s;}
  .row a:hover{border-color:var(--accent);}
  .row a:active{transform:translateY(1px);}
  .row .lbl{font-weight:500;letter-spacing:-.01em;}
  .row .file{font-family:var(--mono);font-size:11.5px;color:var(--text3);}
  .empty{display:none;color:var(--text2);padding:40px 0;text-align:center;}
  .empty.show{display:block;}
</style>
</head>
<body>
<div class="wrap">
  <header class="head">
    <h1>apple-client-area</h1>
    <p>Live page list &mdash; every <code>.html</code> file in the folder, served over localhost. Refresh to pick up new files.</p>
  </header>
  <div class="bar">
    <input id="q" type="search" placeholder="Filter ${files.length} pages by name or filename..." autocomplete="off" autofocus>
    <div class="meta" id="meta">${files.length} pages</div>
  </div>
  ${sections.join("\n  ")}
  <div class="empty" id="empty">No pages match your filter.</div>
</div>
<script>
  var q=document.getElementById("q"),meta=document.getElementById("meta"),empty=document.getElementById("empty");
  var rows=[].slice.call(document.querySelectorAll(".row"));
  var grps=[].slice.call(document.querySelectorAll(".grp"));
  var total=rows.length;
  q.addEventListener("input",function(){
    var t=q.value.trim().toLowerCase(),shown=0;
    rows.forEach(function(r){var m=!t||r.getAttribute("data-search").indexOf(t)>-1;r.style.display=m?"":"none";if(m)shown++;});
    grps.forEach(function(g){var any=[].slice.call(g.querySelectorAll(".row")).some(function(r){return r.style.display!=="none";});g.style.display=any?"":"none";});
    meta.textContent=shown+" of "+total+" pages";
    empty.classList.toggle("show",shown===0);
  });
</script>
</body>
</html>`;
}

// ---- static file serving (path-traversal safe) ---------------------------
function send(res, status, type, body) {
  res.writeHead(status, { "Content-Type": type, "Cache-Control": "no-cache" });
  res.end(body);
}

function serveStatic(req, res, urlPath) {
  let rel = decodeURIComponent(urlPath.split("?")[0].split("#")[0]);
  rel = rel.replace(/^\/+/, "");
  const abs = path.resolve(ROOT, rel);
  if (abs !== ROOT && !abs.startsWith(ROOT + path.sep)) {
    return send(res, 403, "text/plain; charset=utf-8", "403 Forbidden");
  }
  fs.stat(abs, (err, st) => {
    if (err) return send(res, 404, "text/plain; charset=utf-8", "404 Not Found: " + esc(rel));
    let target = abs;
    if (st.isDirectory()) {
      target = path.join(abs, "index.html");
      if (!fs.existsSync(target)) return send(res, 404, "text/plain; charset=utf-8", "404 Not Found");
    }
    res.writeHead(200, { "Content-Type": typeFor(target), "Cache-Control": "no-cache" });
    fs.createReadStream(target).pipe(res);
  });
}

const server = http.createServer((req, res) => {
  const urlPath = req.url || "/";
  const clean = urlPath.split("?")[0].split("#")[0];
  if (req.method !== "GET" && req.method !== "HEAD") {
    return send(res, 405, "text/plain; charset=utf-8", "405 Method Not Allowed");
  }
  if (clean === "/" || clean === "/_pages" || clean === "/_pages.html") {
    try {
      return send(res, 200, "text/html; charset=utf-8", renderIndex());
    } catch (e) {
      return send(res, 500, "text/plain; charset=utf-8", "500 " + esc(String(e && e.message)));
    }
  }
  serveStatic(req, res, urlPath);
});

server.on("error", (e) => {
  if (e.code === "EADDRINUSE") {
    console.error("Port " + PORT + " is already in use. Try: node scripts/serve.mjs " + (PORT + 1));
  } else {
    console.error(e);
  }
  process.exit(1);
});

server.listen(PORT, () => {
  console.log("Dev server running:");
  console.log("  Page list : http://localhost:" + PORT + "/");
  console.log("  Root dir  : " + ROOT);
  console.log("Press Ctrl+C to stop.");
});
