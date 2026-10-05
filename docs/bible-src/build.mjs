// Build the DevOps bible: chapters/*.md -> bible.html -> bible.pdf
import fs from 'node:fs';
import path from 'node:path';
import { Marked } from 'marked';
import hljs from 'highlight.js';
import { chromium } from 'playwright-core';

const ROOT = path.dirname(new URL(import.meta.url).pathname);
const CH_DIR = path.join(ROOT, 'chapters');
const OUT_HTML = path.join(ROOT, 'bible.html');
const OUT_PDF = process.argv[2] || path.join(ROOT, 'bible.pdf');

const slugify = (s) =>
  s.toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '')
    .replace(/<[^>]+>/g, '').replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');

const toc = [];
let inBox = 0;
const boxes = [];
const used = new Map();
const marked = new Marked({
  gfm: true,
  renderer: {
    heading({ tokens, depth }) {
      const text = this.parser.parseInline(tokens);
      let id = slugify(text) || 'h';
      const n = used.get(id) || 0; used.set(id, n + 1);
      if (n) id += '-' + n;
      if (depth <= 2 && !inBox) toc.push({ depth, text, id });
      const cls = depth === 1 ? ' class="chapter"' : '';
      return `<h${depth} id="${id}"${cls}>${text}</h${depth}>\n`;
    },
    code({ text, lang }) {
      const l = (lang || '').trim();
      let html;
      if (l && !['markdown','md','ascii','text'].includes(l) && hljs.getLanguage(l)) html = hljs.highlight(text, { language: l }).value;
      else html = text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
      const label = l && !['text', 'plain', 'ascii'].includes(l) ? `<span class="lang">${l}</span>` : '';
      if (l === 'ascii') {
        const n = Math.max(...text.split('\n').map((x) => [...x.trimEnd()].length));
        const fs = Math.min(8, (8 * 135) / n).toFixed(2);
        return `<pre class="code lang-ascii ascii"><code style="font-size:${fs}pt;white-space:pre">${html}</code></pre>\n`;
      }
      return `<pre class="code lang-${l || "none"}">${label}<code>${html}</code></pre>\n`;
    },
  },
});

// ::: containers -> styled boxes. Syntax:  :::tip Optional title  ...  :::
const BOX = {
  tip: ['Astuce', '💡'], warn: ['Attention', '⚠️'], danger: ['Danger — coûts / sécurité', '🛑'],
  info: ['À savoir', 'ℹ️'], why: ['Pourquoi ?', '🧠'], check: ['Vérification', '✅'],
  clean: ['Nettoyage obligatoire', '🧹'], exo: ['Exercice', '🏋️'], interview: ['Questions d’entretien', '🎤'],
  analogy: ['Analogie', '🧩'], fix: ['Dépannage', '🔧'], card: ['Fiche projet', '📋'],
};
function preprocess(md) {
  const lines = md.split('\n');
  const out = [];
  const stack = [];
  for (const line of lines) {
    const part = line.match(/^@@part\s+(.*?)\s*\|\s*(.*?)\s*\|\s*(.*)$/);
    if (part) {
      const id = 'part-' + slugify(part[2]);
      toc.push({ depth: 0, text: part[1] + ' — ' + part[2], id, h: part[2] });
      out.push('', `<div class="part-page" id="${id}"><div class="kicker">${part[1]}</div><h1>${part[2]}</h1><p>${part[3]}</p></div>`, '');
      continue;
    }
    const open = line.match(/^:::(\w+)\s*(.*)$/);
    if (open && BOX[open[1]]) {
      stack.push({ type: open[1], title: open[2].trim(), buf: [] });
      continue;
    }
    if (line.trim() === ':::' && stack.length) {
      const b = stack.pop();
      const [def, icon] = BOX[b.type];
      inBox++; const inner = marked.parse(b.buf.join('\n')).replace(/<!--BOX:(\d+)-->/g, (_, i) => boxes[+i]); inBox--;
      const html = `<div class="box box-${b.type}"><div class="box-title"><span class="ico">${icon}</span>${b.title || def}</div><div class="box-body">${inner}</div></div>`;
      boxes.push(html);
      (stack.length ? stack[stack.length - 1].buf : out).push('', `<!--BOX:${boxes.length - 1}-->`, '');
      continue;
    }
    (stack.length ? stack[stack.length - 1].buf : out).push(line);
  }
  return out.join('\n');
}

const files = fs.readdirSync(CH_DIR).filter((f) => f.endsWith('.md')).sort();
let body = '';
for (const f of files) {
  const md = fs.readFileSync(path.join(CH_DIR, f), 'utf8');
  body += `<section class="file" data-src="${f}">` + marked.parse(preprocess(md)).replace(/<!--BOX:(\d+)-->/g, (_, i) => boxes[+i]) + '</section>\n';
}

const pageMap = fs.existsSync(path.join(ROOT, 'pages.json'))
  ? JSON.parse(fs.readFileSync(path.join(ROOT, 'pages.json'), 'utf8')) : {};
const tocHtml = toc
  .filter((t) => !t.text.includes('Table des matières') && t.depth <= 1)
  .map((t) => `<li class="toc-${t.depth}"><a href="#${t.id}"><span class="t">${t.text}</span><span class="dots"></span><span class="p">${pageMap[t.id] ?? ''}</span></a></li>`)
  .join('\n');

const font = (fam, file, w) => {
  const p = path.join(ROOT, 'node_modules/@fontsource', fam, 'files', file);
  const b64 = fs.readFileSync(p).toString('base64');
  return `@font-face{font-family:'${fam === 'inter' ? 'Inter' : 'JetBrains Mono'}';font-weight:${w};src:url(data:font/woff2;base64,${b64}) format('woff2');}`;
};
const fonts = [
  ...[400, 600, 700, 800].flatMap((w) => [font('inter', `inter-latin-${w}-normal.woff2`, w), font('inter', `inter-latin-ext-${w}-normal.woff2`, w)]),
  font('jetbrains-mono', 'jetbrains-mono-latin-400-normal.woff2', 400),
  font('jetbrains-mono', 'jetbrains-mono-latin-700-normal.woff2', 700),
].join('\n');

const css = fs.readFileSync(path.join(ROOT, 'style.css'), 'utf8');
const cover = fs.readFileSync(path.join(ROOT, 'cover.html'), 'utf8');
const html = `<!doctype html><html lang="fr"><head><meta charset="utf-8"><title>La Bible DevOps &amp; Cloud</title>
<style>${fonts}\n${css}</style></head><body>
${cover}
<nav class="toc"><h1 class="toc-title" id="table-des-matieres">Table des matières</h1><ol>${tocHtml}</ol></nav>
${body}
</body></html>`;
fs.writeFileSync(OUT_HTML, html);
fs.writeFileSync(path.join(ROOT, 'toc.json'), JSON.stringify(toc.filter((t) => t.depth <= 1)));

const browser = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium-1194/chrome-linux/chrome' });
const page = await browser.newPage();
await page.goto('file://' + OUT_HTML, { waitUntil: 'load' });
await page.pdf({
  path: OUT_PDF,
  format: 'A4',
  printBackground: true,
  outline: true,
  tagged: true,
  displayHeaderFooter: true,
  headerTemplate: '<div></div>',
  footerTemplate: `<div style="width:100%;font-family:Inter,DejaVu Sans,sans-serif;font-size:8px;color:#8a94a6;padding:0 16mm;display:flex;justify-content:space-between;">
    <span>La Bible DevOps &amp; Cloud — parcours IO</span><span class="pageNumber"></span></div>`,
  margin: { top: '16mm', bottom: '16mm', left: '16mm', right: '16mm' },
});
await browser.close();
console.log('PDF:', OUT_PDF, 'chapters:', files.length, 'toc entries:', toc.length);
