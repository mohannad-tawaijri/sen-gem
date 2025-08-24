import fs from 'fs'
import path from 'path'

const imagesDir = path.resolve(path.join(process.cwd(), 'public', 'media', 'questions', 'pictures'))
const mapPath = path.resolve(path.join(process.cwd(), '..', 'pics', 'pictures_map.json'))

function readExistingMap() {
  try {
    const raw = fs.readFileSync(mapPath, 'utf8')
    return JSON.parse(raw)
  } catch {
    return []
  }
}

function main(){
  if (!fs.existsSync(imagesDir)) {
    console.error('Images directory not found:', imagesDir)
    process.exit(1)
  }
  const re = /^Picture(\d+)\.(jpe?g|png)$/i
  const files = fs.readdirSync(imagesDir).filter(f=>re.test(f))
  const indices = [...new Set(files.map(f=>Number(f.match(re)[1])))]
  indices.sort((a,b)=>a-b)

  const existing = readExistingMap()
  const byIndex = new Map(existing.map(it=>[Number(it.index), it]))
  const merged = indices.map(i=>({ index: i, answer: (byIndex.get(i)?.answer)||'' }))
  fs.writeFileSync(mapPath, JSON.stringify(merged, null, 2), 'utf8')
  console.log('Wrote', merged.length, 'entries to', mapPath)
}

main()
