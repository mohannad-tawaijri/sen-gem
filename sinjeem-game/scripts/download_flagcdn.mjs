// Downloads PNG flags from flagcdn.com (w512) into public/media/questions/flags/
// Usage: node scripts/download_flagcdn.mjs
import fs from 'node:fs/promises'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const root = process.cwd()
const manifestPath = path.join(__dirname, '..', 'manifest', 'countries_ar.json')
const outDir = path.join(root, 'public', 'media', 'questions', 'flags')

async function ensureDir(p){ await fs.mkdir(p, { recursive: true }) }

async function fetchToFile(url, outFile){
  // Try w512 first, fallback to w320 if not available
  let res = await fetch(url, { redirect: 'follow' })
  if(!res.ok && url.includes('w512')) {
    const fallbackUrl = url.replace('w512', 'w320')
    res = await fetch(fallbackUrl, { redirect: 'follow' })
  }
  if(!res.ok) throw new Error(`HTTP ${res.status} for ${url}`)
  const buf = Buffer.from(await res.arrayBuffer())
  await fs.writeFile(outFile, buf)
}

async function main(){
  const arr = JSON.parse(await fs.readFile(manifestPath, 'utf-8'))
  await ensureDir(outDir)
  let ok=0, fail=0
  for(const {code, name_ar} of arr){
    const url = `https://flagcdn.com/w512/${code}.png`
    const out = path.join(outDir, `${code}.png`)
    try{
      await fetchToFile(url, out)
      console.log('✔', code, '—', name_ar)
      ok++
    }catch(e){
      console.error('✖', code, '—', name_ar, '→', e.message)
      fail++
    }
  }
  console.log('Done. OK=%d FAIL=%d', ok, fail)
}
main().catch(e => { console.error(e); process.exit(1) })
