// Local-only release preview with WASM MIME and isolation headers.
import http from 'node:http';
import { readFile, stat } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const root = fileURLToPath(new URL('../app/build/web/', import.meta.url));
const types = { '.html': 'text/html', '.js': 'text/javascript', '.json': 'application/json',
  '.wasm': 'application/wasm', '.png': 'image/png', '.ttf': 'font/ttf' };
http.createServer(async (req, res) => {
  try {
    const requested = decodeURIComponent(new URL(req.url, 'http://localhost').pathname);
    let file = path.resolve(root, '.' + requested);
    const relative = path.relative(root, file);
    if (relative === '..' || relative.startsWith('..' + path.sep) || path.isAbsolute(relative)) {
      res.writeHead(403).end(); return;
    }
    if ((await stat(file)).isDirectory()) file = path.join(file, 'index.html');
    res.writeHead(200, { 'Content-Type': types[path.extname(file)] ?? 'application/octet-stream',
      'Cache-Control': 'no-store', 'Cross-Origin-Opener-Policy': 'same-origin',
      'Cross-Origin-Embedder-Policy': 'require-corp' });
    res.end(await readFile(file));
  } catch { res.writeHead(404).end('Not found'); }
}).listen(3000, '127.0.0.1', () => console.log('Preview: http://127.0.0.1:3000'));
