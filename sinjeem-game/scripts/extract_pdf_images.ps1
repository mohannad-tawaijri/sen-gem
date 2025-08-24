param(
  [string]$PdfPath = (Join-Path (Split-Path $PSScriptRoot -Parent) '..\pics\pics.pdf'),
  [string]$OutDir = (Join-Path $PSScriptRoot '..\public\media\questions\pictures')
)

$ErrorActionPreference = 'Stop'

function Ensure-Tool {
  param([string]$Name)
  $cmd = Get-Command $Name -ErrorAction SilentlyContinue
  if (-not $cmd) {
    Write-Host "Required tool '$Name' not found in PATH." -ForegroundColor Red
    Write-Host "Install Poppler for Windows and ensure 'pdfimages.exe' is in PATH." -ForegroundColor Yellow
    exit 1
  }
}

Ensure-Tool -Name 'pdfimages'

if (-not (Test-Path $PdfPath)) { Write-Host "PDF not found: $PdfPath" -ForegroundColor Red; exit 1 }

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

# Compute how many images are on page 1 (slide 1) so we can skip them
$list = & pdfimages -list -- "$PdfPath" 2>$null
$skipFirst = 0
if ($LASTEXITCODE -eq 0 -and $list) {
  $lines = ($list -split "`r?`n") | Where-Object { $_ -and ($_ -notmatch 'list of images') }
  foreach ($ln in $lines) {
    $cols = ($ln -split '\s+') | Where-Object { $_ }
    if ($cols.Count -ge 1) {
      $pageNum = 0
      if ([int]::TryParse($cols[0], [ref]$pageNum)) {
        if ($pageNum -eq 1) { $skipFirst++ } else { break }
      }
    }
  }
}

# Extract all images preserving original format
$base = Join-Path $OutDir 'Picture'
& pdfimages -all -- "$PdfPath" "$base" | Out-Null

# Keep only question images (odd order), discard answers (even), and rename
$files = Get-ChildItem -Path $OutDir -File | Where-Object { $_.BaseName -match '^Picture-?\d+$' }
if ($files.Count -eq 0) {
  Write-Host "No extracted files named Picture-000.* were found. Ensure PDF has embedded images." -ForegroundColor Yellow
  exit 0
}
$files = $files | Sort-Object LastWriteTime

# Skip images from slide 1 if any
if ($skipFirst -gt 0 -and $skipFirst -lt $files.Count) {
  $files = $files[$skipFirst..($files.Count-1)]
}

[int]$q = 1
[int]$kept = 0
[int]$removed = 0
for ($idx = 0; $idx -lt $files.Count; $idx++) {
  $f = $files[$idx]
  if (($idx % 2) -eq 0) {
    # Question image
    $ext = $f.Extension
    $target = Join-Path $OutDir ("Picture{0}{1}" -f $q, $ext)
    if (Test-Path $target) { Remove-Item $target -Force }
    Rename-Item -Path $f.FullName -NewName (Split-Path $target -Leaf)
    $q++
    $kept++
  } else {
    # Answer image - remove
    Remove-Item $f.FullName -Force
    $removed++
  }
}

Write-Host ("Kept {0} question images and removed {1} answer images -> {2}" -f $kept, $removed, $OutDir) -ForegroundColor Green
