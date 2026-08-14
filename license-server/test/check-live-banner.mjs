// Read-only: fetch the live client area and report whether the whmcs-licensing-modern
// banner is being injected (it only injects when it decides to nag).
//   node test/check-live-banner.mjs [url]
import https from 'node:https';

function get(url, depth) {
  return new Promise((resolve, reject) => {
    const u = new URL(url);
    https.get({ hostname: u.hostname, path: u.pathname + u.search, headers: { 'User-Agent': 'Mozilla/5.0' } }, (r) => {
      if ([301, 302, 303, 307, 308].includes(r.statusCode) && r.headers.location && depth > 0) {
        r.resume();
        return resolve(get(new URL(r.headers.location, url).href, depth - 1));
      }
      let d = '';
      r.on('data', (c) => (d += c));
      r.on('end', () => resolve({ status: r.statusCode, url, html: d }));
    }).on('error', reject);
  });
}

const start = process.argv[2] || 'https://bill.hostnodes.com/';
const r = await get(start, 5);
const h = r.html;
console.log('final URL      :', r.url);
console.log('status         :', r.status, ' bytes:', h.length);
console.log('theme rendered :', /mytheme header/i.test(h) ? 'yes (mytheme)' : '(no mytheme marker)');

const hookPresent = h.includes('Hostnodes theme license') || h.includes('hn-lic-banner');
console.log('license hook   :', hookPresent ? 'BANNER SCRIPT PRESENT' : 'no banner injected');
if (hookPresent) {
  const m = h.match(/not licensed[^<"']*|license is suspended[^<"']*|license has expired[^<"']*/i);
  console.log('  -> nagging. message:', m ? m[0].trim() : '(present; see markup)');
} else {
  console.log('  -> licensed/Active for this domain, OR the hook is not loaded on this page');
}
