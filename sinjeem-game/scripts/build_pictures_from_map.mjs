import fs from 'fs'
import path from 'path'

const mapPath = path.resolve(path.join(process.cwd(), '..', 'pics', 'pictures_map.json'))
const outPath = path.resolve(path.join(process.cwd(), 'public', 'questions', 'pictures.json'))

const raw = fs.readFileSync(mapPath, 'utf8')
const items = JSON.parse(raw)

function difficultyFor(ix){
  // cycle 200,400,600
  const r = ix % 3
  return r===1?200: r===2?400:600
}

const out = items.map((p, i)=>({
  id: `pic-${difficultyFor(i+1)}-${p.index}`,
  difficulty: difficultyFor(i+1),
  q: ' ',
  a: p.answer,
  media: [{ type: 'image', src: `/media/questions/pictures/Picture${p.index}.jpg`, alt: `لغز ${p.index}` }],
  tags: ['visual','pictures']
}))

fs.writeFileSync(outPath, JSON.stringify(out, null, 2), 'utf8')
console.log('Wrote', out.length, 'items to', outPath)
