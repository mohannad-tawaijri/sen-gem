import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'
import { PdfReader } from 'pdfreader'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)
const pdfPath = path.resolve(path.join(__dirname, '..', '..', 'pics', 'pics.pdf'))
const outPath = path.resolve(path.join(__dirname, '..', 'public', 'questions', 'pictures.json'))

function difficultyFor(n){ const r=n%3; return r===1?200:r===2?400:600 }

const lines=[]
new PdfReader().parseFileItems(pdfPath, (err, item) => {
  if (err) return console.error(err)
  if (!item) return finish()
  if (item.text) lines.push(item.text)
})

function finish(){
  const text = lines.join('\n')
  try {
    const debugPath = path.resolve(path.join(__dirname, '..', 'scripts', 'tmp_pics_text.txt'))
    fs.writeFileSync(debugPath, text, 'utf8')
    console.log('Wrote debug text to', debugPath)
  } catch(e) { /* ignore */ }
  const pairs = parsePairs(text)
  if (!pairs.length){ console.error('No pairs found'); return }
  const out = pairs.map((p,ix)=>({
    id: `pic-${difficultyFor(ix+1)}-${p.idx}`,
    difficulty: difficultyFor(ix+1),
    q: ' ',
    a: p.answer,
    media: [{ type: 'image', src: `/media/questions/pictures/Picture${p.idx}.jpg`, alt: `لغز ${p.idx}` }],
    tags: ['visual','pictures']
  }))
  fs.writeFileSync(outPath, JSON.stringify(out,null,2), 'utf8')
  console.log('Wrote', out.length, 'items to', outPath)
}

function parsePairs(text){
  const lines = text.split(/\r?\n/).map(s=>s.trim()).filter(Boolean)
  const items=[]
  for(let i=0;i<lines.length;i++){
    const m = lines[i].match(/^(?:pic|picture)\s*#?\s*(\d+)/i)
    if(m){
      const idx = Number(m[1])
      // answer on next line likely
      let ans=''
      for(let j=i+1;j<lines.length;j++){
        const l=lines[j]
        if(/^(?:pic|picture)\s*#?\s*\d+/i.test(l)) break
        if(l) { ans = l.replace(/^answer\s*[:\-]?\s*/i,'').trim(); break }
      }
      if(ans) items.push({ idx, answer: ans })
    }
  }
  const map=new Map(); for(const it of items){ if(!map.has(it.idx)) map.set(it.idx,it) }
  return [...map.values()].sort((a,b)=>a.idx-b.idx)
}
