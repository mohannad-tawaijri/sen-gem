// Compact each question to a single line per object inside the array
// Uses categories.json to determine which files to process.

import { promises as fs } from 'fs';
import path from 'path';
import url from 'url';

const __filename = url.fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const root = path.resolve(__dirname, '..');
const questionsDir = path.join(root, 'public', 'questions');
const categoriesPath = path.join(questionsDir, 'categories.json');

async function readJson(file) {
  const b = await fs.readFile(file);
  // Strip UTF-8 BOM if present
  const buf = (b[0] === 0xef && b[1] === 0xbb && b[2] === 0xbf) ? b.slice(3) : b;
  return JSON.parse(buf.toString('utf8'));
}

async function compactArrayFile(file) {
  let arr;
  try {
    arr = await readJson(file);
  } catch (e) {
    return false; // skip non-JSON arrays
  }
  if (!Array.isArray(arr)) return false;
  const lines = arr.map(obj => JSON.stringify(obj));
  const out = '[\n' + lines.join(',\n') + '\n]\n';
  await fs.writeFile(file, out, 'utf8');
  return true;
}

async function main() {
  const cats = await readJson(categoriesPath);
  const slugs = Array.isArray(cats) ? cats.map(c => c.slug).filter(Boolean) : [];
  let changed = 0;
  for (const slug of slugs) {
    const file = path.join(questionsDir, `${slug}.json`);
    const ok = await compactArrayFile(file);
    if (ok) changed++;
  }
  console.log(`Compacted ${changed} files to one-line-per-question.`);
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
