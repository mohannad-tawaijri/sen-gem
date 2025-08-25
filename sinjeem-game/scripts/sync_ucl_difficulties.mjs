#!/usr/bin/env node
// Sync difficulties from championsleague_no_answers.json to championsleague.json by id
// Also pretty-format both files

import { readFile, writeFile } from 'node:fs/promises'
import { fileURLToPath } from 'node:url'
import { dirname, resolve } from 'node:path'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)
const questionsDir = resolve(__dirname, '../public/questions')
const realPath = resolve(questionsDir, 'championsleague.json')
const reviewPath = resolve(questionsDir, 'championsleague_no_answers.json')

const RULE_FORBID_600_ANSWERS = new Set(['ريال مدريد', 'ليونيل ميسي', 'كريستيانو رونالدو'])

function validateEntryShape(entry, source) {
  if (!entry || typeof entry !== 'object') throw new Error(`Invalid entry in ${source}`)
  if (!entry.id) throw new Error(`Missing id in ${source}`)
  if (entry.difficulty !== 200 && entry.difficulty !== 400 && entry.difficulty !== 600) {
    throw new Error(`Invalid difficulty ${entry.difficulty} for id ${entry.id} in ${source}`)
  }
}

async function main() {
  const [reviewRaw, realRaw] = await Promise.all([
    readFile(reviewPath, 'utf8'),
    readFile(realPath, 'utf8')
  ])

  const review = JSON.parse(reviewRaw)
  const real = JSON.parse(realRaw)

  // Build review map and validate
  const seen = new Set()
  const byId = new Map()
  for (const e of review) {
    validateEntryShape(e, 'review')
    if (seen.has(e.id)) throw new Error(`Duplicate id in review: ${e.id}`)
    seen.add(e.id)
    byId.set(e.id, e.difficulty)
  }

  let updated = 0
  let demoted = 0
  for (const e of real) {
    if (!e || typeof e !== 'object') continue
    const newDiff = byId.get(e.id)
    if (newDiff != null && e.difficulty !== newDiff) {
      e.difficulty = newDiff
      updated++
    }
    // Enforce constraint: if answer is RM/Messi/Ronaldo, not 600
    if (RULE_FORBID_600_ANSWERS.has(e.a) && e.difficulty === 600) {
      e.difficulty = 400
      demoted++
    }
  }

  // Pretty-format and write back
  await Promise.all([
    writeFile(realPath, JSON.stringify(real, null, 2) + '\n', 'utf8'),
    writeFile(reviewPath, JSON.stringify(review, null, 2) + '\n', 'utf8')
  ])

  console.log(`Synced difficulties. Updated: ${updated}, auto-demoted (RM/Messi/Ronaldo): ${demoted}`)
}

main().catch(err => {
  console.error(err)
  process.exit(1)
})
