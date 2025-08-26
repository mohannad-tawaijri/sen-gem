#!/usr/bin/env node
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

// Resolve paths relative to this script file to avoid CWD issues
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const root = path.resolve(__dirname, '..', 'public', 'questions');
const srcPath = path.join(root, 'football_no_answers.json');
const dstPath = path.join(root, 'football.json');

function readJson(p) {
  return JSON.parse(fs.readFileSync(p, 'utf8'));
}

function writeJson(p, data) {
  fs.writeFileSync(p, JSON.stringify(data, null, 2) + '\n', 'utf8');
}

function main() {
  const noAns = readJson(srcPath);
  const full = readJson(dstPath);

  const mapNo = new Map(noAns.map(it => [it.id, it]));
  const idsNo = new Set(noAns.map(it => it.id));

  let updated = 0;
  let removed = 0;
  let kept = 0;
  let added = 0;

  // Update or filter existing
  const next = [];
  for (const item of full) {
    const m = mapNo.get(item.id);
    if (!m) {
      removed++;
      continue; // drop items not present in no-answers
    }
    const before = item.difficulty;
    if (m.difficulty !== undefined && m.difficulty !== item.difficulty) {
      item.difficulty = m.difficulty; // sync difficulty only
      updated++;
    }
    // Keep existing q and tags and answers to preserve content, per request to sync difficulties only
    next.push(item);
    kept++;
  }

  // Add new ones that exist in no-answers but not in full
  const idsFull = new Set(full.map(it => it.id));
  for (const it of noAns) {
    if (!idsFull.has(it.id)) {
      next.push({
        id: it.id,
        difficulty: it.difficulty,
        q: it.q,
        a: "",
        tags: Array.isArray(it.tags) ? it.tags : []
      });
      added++;
    }
  }

  // Sort by id to keep stable order
  next.sort((a, b) => (a.id > b.id ? 1 : a.id < b.id ? -1 : 0));

  // Backup existing file once per run
  const backupPath = dstPath + '.bak';
  try {
    if (!fs.existsSync(backupPath)) {
      fs.copyFileSync(dstPath, backupPath);
    }
  } catch (e) {
    // Non-fatal
  }

  writeJson(dstPath, next);

  // summary
  const dist = next.reduce((acc, it) => { acc[it.difficulty] = (acc[it.difficulty]||0)+1; return acc; }, {});
  const summary = { updatedDifficulties: updated, removed, kept, added, total: next.length, difficultyDistribution: dist };
  console.log(JSON.stringify(summary, null, 2));
}

main();
