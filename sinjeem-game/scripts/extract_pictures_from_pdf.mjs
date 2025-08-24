import fs from 'fs'
import path from 'path'
import pdfParseCjs from 'pdf-parse/lib/pdf-parse.js'
const pdfParse = pdfParseCjs.default || pdfParseCjs

const pdfPath = path.resolve(path.join(process.cwd(), '..', 'pics', 'pics.pdf'))
const outPath = path.resolve(path.join(process.cwd(), 'public', 'questions', 'pictures.json'))

async function extractText(filePath){
  const data = fs.readFileSync(filePath)
  const res = await pdfParse(data)
  return res.text || ''
}

function parsePairs(text){
  const lines = text.split(/\r?\n/).map(s=>s.trim())
  const items = []
  for (let i=0;i<lines.length;i++){
    const m = lines[i].match(/^(?:pic|picture)\s*#?\s*(\d+)/i)
    if(m){
      const idx = Number(m[1])
      // take the next non-empty line that is not another picture header
      let j=i+1; let answer=''
      while(j<lines.length){
        const l = lines[j].trim()
        if(!l){ j++; continue }
        if(/^(?:pic|picture)\s*#?\s*\d+/i.test(l)) break
        answer = l.replace(/^answer\s*[:\-]?\s*/i,'').trim()
        break
      }
      if(answer) items.push({ idx, answer })
    }
  }
  const map = new Map()
  for(const it of items){ if(!map.has(it.idx)) map.set(it.idx,it) }
  return [...map.values()].sort((a,b)=>a.idx-b.idx)
}

function difficultyFor(n){
  const r = n % 3
  return r===1?200: r===2?400:600
}

const text = await extractText(pdfPath)
const pairs = parsePairs(text)
if(!pairs.length){
  console.error('No pairs parsed from PDF. Check format.')
  process.exit(1)
}
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
