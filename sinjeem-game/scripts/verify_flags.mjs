// Verifies that all local flag images exist under public/media/questions/flags/
// Usage: node scripts/verify_flags.mjs
import fs from 'node:fs/promises'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const root = process.cwd()
const manifestPath = path.join(__dirname, '..', 'manifest', 'countries_ar.json')
const dir = path.join(root, 'public', 'media', 'questions', 'flags')

async function main(){
  const arr = JSON.parse(await fs.readFile(manifestPath, 'utf-8'))
  let missing = []
  for(const {code, name_ar} of arr){
    const p = path.join(dir, `${code}.png`)
    try{
      await fs.stat(p)
    }catch{
      missing.push({code, name_ar})
    }
  }
  if(missing.length){
    console.log('Missing files (%d):', missing.length)
    for(const m of missing) console.log('-', m.code, '—', m.name_ar)
    process.exitCode = 1
  } else {
    console.log('All files present:', arr.length)
  }
}
main().catch(e => { console.error(e); process.exit(1) })
