// Normalize IDs across all category JSON files to <slug>-<difficulty>-NNN
// - Rewrites each questions JSON under public/questions/<slug>.json
// - Ensures per-difficulty contiguous numbering (001..N) in file order
// - Generates an alias map public/questions/id_aliases.json mapping old->new IDs

import { promises as fs } from 'fs';
import path from 'path';
import url from 'url';

const __filename = url.fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const root = path.resolve(__dirname, '..');
const questionsDir = path.join(root, 'public', 'questions');
const categoriesPath = path.join(questionsDir, 'categories.json');
const aliasOutPath = path.join(questionsDir, 'id_aliases.json');

function pad3(n) {
  return String(n).padStart(3, '0');
}

async function readJson(file) {
  const b = await fs.readFile(file);
  // Strip BOM if present
  const buf = (b[0] === 0xef && b[1] === 0xbb && b[2] === 0xbf) ? b.slice(3) : b;
  return JSON.parse(buf.toString('utf8'));
}

async function writeJson(file, data) {
  const json = JSON.stringify(data, null, 2) + '\n';
  await fs.writeFile(file, json, 'utf8');
}

async function normalizeFileForSlug(slug, aliasMap) {
  const file = path.join(questionsDir, `${slug}.json`);
  try {
    const arr = await readJson(file);
    if (!Array.isArray(arr)) return;
    // Build groups by difficulty, keeping original order
    const byDiff = new Map(); // diff -> array of indexes in arr
    for (let i = 0; i < arr.length; i++) {
      const q = arr[i] || {};
      if (!q || typeof q !== 'object') continue;
      const diff = Number(q.difficulty || q.Difficulty || q.diff || 0);
      const id = (q.id || '').toString().trim();
      if (!diff || !id) continue;
      if (!byDiff.has(diff)) byDiff.set(diff, []);
      byDiff.get(diff).push(i);
    }
    // Assign new IDs per difficulty sequentially in file order
    for (const [diff, idxs] of byDiff.entries()) {
      let serial = 1;
      for (const i of idxs) {
        const q = arr[i];
        const oldID = String(q.id || '').trim();
        const newID = `${slug}-${diff}-${pad3(serial)}`;
        if (oldID && oldID !== newID) aliasMap[oldID] = newID;
        q.id = newID;
        // ensure tags include slug
        const tags = Array.isArray(q.tags) ? q.tags : [];
        if (!tags.includes(slug)) tags.push(slug);
        q.tags = tags;
        // ensure numeric difficulty field is correct
        q.difficulty = diff;
        serial++;
      }
    }
    await writeJson(file, arr);
    return true;
  } catch (e) {
    // file may not exist or not be a JSON array; skip silently
    return false;
  }
}

async function main() {
  const cats = await readJson(categoriesPath);
  const slugs = cats.map(c => c.slug);
  const aliasMap = {};
  for (const slug of slugs) {
    await normalizeFileForSlug(slug, aliasMap);
  }
  await writeJson(aliasOutPath, aliasMap);
  // eslint-disable-next-line no-console
  console.log(`Normalization complete. Alias map written to ${path.relative(root, aliasOutPath)}.`);
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
