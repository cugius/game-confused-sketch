#!/usr/bin/env node
// Inserisce i18n/rows.jsonl in dist/index.html tra /*I18N-BEGIN*/ e /*I18N-END*/.
// Ogni riga: [italiano (chiave), en, es, fr, de, ja]. I segnaposto {n} devono coincidere in tutte le lingue.
// Uso: node tools/build-i18n.cjs [--check]   (--check non scrive: fallisce se il file non è aggiornato)
const fs = require('fs'), path = require('path');
const root = path.resolve(__dirname, '..');
const rowsPath = path.join(root, 'i18n/rows.jsonl'), htmlPath = path.join(root, 'dist/index.html');
const rows = fs.readFileSync(rowsPath, 'utf8').split('\n').filter(l => l.trim()).map((l, i) => {
  try { return JSON.parse(l) } catch (e) { throw new Error('riga ' + (i + 1) + ': JSON non valido') }
});
const errors = [], seen = new Set(), toks = s => (s.match(/\{\d+\}/g) || []).sort().join(',');
rows.forEach((r, i) => {
  const where = 'riga ' + (i + 1) + ' «' + String(r[0]).slice(0, 40) + '»';
  if (!Array.isArray(r) || r.length !== 6) return errors.push(where + ': servono 6 colonne');
  if (r.some(c => typeof c !== 'string' || !c.trim())) errors.push(where + ': colonna vuota');
  if (seen.has(r[0])) errors.push(where + ': chiave duplicata');
  seen.add(r[0]);
  r.slice(1).forEach((c, j) => { if (toks(c) !== toks(r[0])) errors.push(where + ': segnaposto diversi in colonna ' + (j + 2)) });
  r.slice(1).forEach((c, j) => { if ((r[0].match(/✎/g) || []).length !== (c.match(/✎/g) || []).length) errors.push(where + ': simbolo ✎ non coincide in colonna ' + (j + 2)) });
});
if (errors.length) { console.error(errors.join('\n')); process.exit(1) }
rows.sort((a, b) => a[0].localeCompare(b[0], 'it'));
const block = '/*I18N-BEGIN*/const I18N_ROWS=' + JSON.stringify(rows) + ';/*I18N-END*/';
const html = fs.readFileSync(htmlPath, 'utf8');
const m = html.match(/\/\*I18N-BEGIN\*\/[\s\S]*?\/\*I18N-END\*\//);
if (!m) { console.error('Marcatori I18N-BEGIN/END non trovati in dist/index.html'); process.exit(1) }
const out = html.replace(m[0], () => block);
if (process.argv.includes('--check')) {
  if (out !== html) { console.error('dist/index.html non è aggiornato: esegui node tools/build-i18n.cjs'); process.exit(1) }
  console.log('PASS: traduzioni aggiornate (' + rows.length + ' righe)');
} else {
  fs.writeFileSync(htmlPath, out);
  console.log('Traduzioni inserite: ' + rows.length + ' righe');
}
