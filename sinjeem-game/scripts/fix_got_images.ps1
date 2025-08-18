# PowerShell script to fix broken GOT images
$gotJsonPath = "C:\Users\Admin\Desktop\sen-gem\sinjeem-game\public\questions\got.json"

Write-Host "Fixing broken GOT images..."

# Read the JSON file
$content = Get-Content $gotJsonPath -Raw -Encoding UTF8

# Create a backup first
$backupPath = $gotJsonPath + ".images_backup"
Copy-Item $gotJsonPath $backupPath
Write-Host "Created backup at: $backupPath"

# Option 1: Replace with working placeholder URLs
$replacementCount = 0

# Replace all local image paths with placeholder URLs
$pattern = '"src":\s*"\./media/questions/got/([^"]+)"'
$replacement = '"src": "https://via.placeholder.com/400x300/2D4A87/FFFFFF?text=$1"'

$newContent = $content -replace $pattern, $replacement
if ($newContent -ne $content) {
    $content = $newContent
    $imageMatches = [regex]::Matches($content, '"src":\s*"https://via.placeholder.com')
    $replacementCount = $imageMatches.Count
    Write-Host "Replaced $replacementCount broken image paths with placeholder URLs"
}

# Write the updated content back to the file
$content | Set-Content $gotJsonPath -Encoding UTF8

Write-Host "Completed! Fixed broken images in GOT questions."
Write-Host "Original file backed up to: $backupPath"
