// page-index-server.mjs
// Zero-dependency static + state server for page-index.html.
// Serves the QA launchpad and persists OK/Bug/notes to page-index-data.json
// on disk so progress survives server restarts and browser cache clears.
//
//   node page-index-server.mjs            (defaults to port 3005)
//   PORT=4000 node page-index-server.mjs  (custom port)

import { createServer } from "http";
import { readFile, writeFile } from "fs/promises";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

const __dirname = dirname(fileURLToPath(import.meta.url));
const PORT = parseInt(process.env.PORT || "3005", 10);
const HTML_FILE = join(__dirname, "page-index.html");
const DATA_FILE = join(__dirname, "page-index-data.json");
const MAX_BODY = 5 * 1024 * 1024; // 5 MB cap on POSTed state

function send(res, code, body, type) {
  res.writeHead(code, { "Content-Type": type || "text/plain; charset=utf-8", "Cache-Control": "no-store" });
  res.end(body);
}

const server = createServer((req, res) => {
  let pathname = "/";
  try { pathname = new URL(req.url, "http://localhost").pathname; } catch (e) {}

  // --- state API -----------------------------------------------------------
  if (pathname === "/api/state") {
    if (req.method === "GET") {
      readFile(DATA_FILE, "utf8")
        .then((txt) => send(res, 200, txt, "application/json"))
        .catch(() => send(res, 200, "{}", "application/json")); // no file yet
      return;
    }
    if (req.method === "POST") {
      let body = "";
      let aborted = false;
      req.on("data", (chunk) => {
        body += chunk;
        if (body.length > MAX_BODY) { aborted = true; req.destroy(); }
      });
      req.on("end", () => {
        if (aborted) return;
        try {
          JSON.parse(body); // validate before writing
        } catch (e) {
          return send(res, 400, '{"ok":false,"error":"invalid json"}', "application/json");
        }
        writeFile(DATA_FILE, body, "utf8")
          .then(() => send(res, 200, '{"ok":true}', "application/json"))
          .catch(() => send(res, 500, '{"ok":false,"error":"write failed"}', "application/json"));
      });
      return;
    }
    return send(res, 405, "Method not allowed");
  }

  // --- the page ------------------------------------------------------------
  if (req.method === "GET" && (pathname === "/" || pathname === "/page-index" || pathname === "/page-index.html")) {
    readFile(HTML_FILE)
      .then((html) => send(res, 200, html, "text/html; charset=utf-8"))
      .catch(() => send(res, 500, "page-index.html not found next to the server"));
    return;
  }

  send(res, 404, "Not found");
});

server.listen(PORT, () => {
  console.log("page-index server running:");
  console.log("  page : http://localhost:" + PORT + "/page-index");
  console.log("  data : " + DATA_FILE);
});
