import { readFile, writeFile } from 'fs/promises';
import path from 'path';

const filePath = path.resolve(process.cwd(), 'sinjeem-game/public/questions/flags.json');

const DIFFICULTY_ORDER = { 200: 0, 400: 1, 600: 2 };

function idToDifficulty(id) {
  const m = /^flags-(\d{3})-/.exec(id);
  if (!m) return null;
  const d = parseInt(m[1], 10);
  return [200, 400, 600].includes(d) ? d : null;
}

function normalizeItem(item) {
  const out = { ...item };

  // Ensure required fields
  out.id = String(out.id || '').trim();
  out.q = out.q ? String(out.q).trim() : 'ما اسم هذا العلم؟';
  out.a = out.a ? String(out.a).trim() : '';

  // Normalize tags to ["flags"]
  out.tags = ["flags"]; // enforce single tag for consistency

  // Ensure media shape
  if (!Array.isArray(out.media)) out.media = [];
  if (out.media.length === 0) {
    // Leave empty; we won't guess missing file names
  } else {
    // Keep only the first image, coerce shape
    const m = out.media.find(x => x && x.type === 'image') || out.media[0] || {};
    out.media = [{
      type: 'image',
      src: m.src || '',
      alt: m.alt || `علم ${out.a || ''}`.trim()
    }];
  }

  // Align difficulty with ID prefix if possible (prefer not to rename IDs)
  const idDiff = idToDifficulty(out.id);
  if (idDiff && out.difficulty !== idDiff) {
    out.difficulty = idDiff;
    out._note = 'difficulty-aligned-to-id';
  }

  return out;
}

function sortItems(a, b) {
  const ao = DIFFICULTY_ORDER[a.difficulty] ?? 99;
  const bo = DIFFICULTY_ORDER[b.difficulty] ?? 99;
  if (ao !== bo) return ao - bo;
  return String(a.id).localeCompare(String(b.id));
}

function toOneLinePerItem(items) {
  // Pretty array with each object as a single line
  const body = items.map(obj => '  ' + JSON.stringify(obj)).join(',\n');
  return `[\n${body}\n]\n`;
}

(async () => {
  let raw = await readFile(filePath, 'utf8');
  // Strip BOM if present to avoid JSON.parse errors
  raw = raw.replace(/^\uFEFF/, '');
  let data;
  try {
    data = JSON.parse(raw);
    if (!Array.isArray(data)) throw new Error('flags.json is not an array');
  } catch (e) {
    console.error('Failed to parse flags.json:', e.message);
    process.exit(1);
  }

  const normalized = data.map(normalizeItem);

  // Remove helper notes if any
  const cleaned = normalized.map(({ _note, ...rest }) => rest);

  // Sort to prefer lower difficulty when deduping
  cleaned.sort(sortItems);

  // Deduplicate by image src (fallback to answer)
  const seen = new Set();
  const deduped = [];
  for (const it of cleaned) {
    const src = (it.media && it.media[0] && it.media[0].src ? String(it.media[0].src) : '').toLowerCase();
    const key = src || `a:${(it.a || '').trim()}`;
    if (seen.has(key)) continue;
    seen.add(key);
    deduped.push(it);
  }

  // Group by difficulty and renumber IDs sequentially within each group
  const groups = { 200: [], 400: [], 600: [] };
  for (const it of deduped) {
    const d = [200, 400, 600].includes(it.difficulty) ? it.difficulty : 600;
    groups[d].push({ ...it, difficulty: d });
  }

  // Stable sort within groups by answer then by existing id
  for (const d of [200, 400, 600]) {
    groups[d].sort((a, b) => {
      const an = (a.a || '').localeCompare(b.a || '');
      if (an !== 0) return an;
      return String(a.id).localeCompare(String(b.id));
    });
  }

  // Assign new IDs flags-<diff>-NNN
  const finalItems = [];
  for (const d of [200, 400, 600]) {
    let i = 1;
    for (const it of groups[d]) {
      const nid = `flags-${String(d).padStart(3, '0')}-${String(i).padStart(3, '0')}`;
      finalItems.push({ ...it, id: nid });
      i++;
    }
  }

  const output = toOneLinePerItem(finalItems);
  await writeFile(filePath, output, 'utf8');

  // Stats
  const counts = finalItems.reduce((acc, it) => {
    acc[it.difficulty] = (acc[it.difficulty] || 0) + 1;
    return acc;
  }, {});
  const removed = cleaned.length - finalItems.length;
  console.log('Normalized flags.json');
  console.log('Counts by difficulty:', counts);
  console.log('Duplicates removed:', removed);
  console.log('Total items:', finalItems.length);
})();
