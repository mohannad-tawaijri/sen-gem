# PowerShell script to fix flag URLs in flags.json
# Replace all flagcdn.com URLs with local file paths

$flagsJsonPath = "C:\Users\Admin\Desktop\sen-gem\sinjeem-game\public\questions\flags.json"
$flagsDir = "C:\Users\Admin\Desktop\sen-gem\sinjeem-game\public\media\questions\flags"

Write-Host "Starting to fix flag URLs in flags.json..."

# Read the JSON file
$content = Get-Content $flagsJsonPath -Raw -Encoding UTF8

# Get list of available flag files
$flagFiles = Get-ChildItem $flagsDir -Name "*.png"
Write-Host "Found $($flagFiles.Count) flag files locally"

# Create a backup first
$backupPath = $flagsJsonPath + ".backup"
Copy-Item $flagsJsonPath $backupPath
Write-Host "Created backup at: $backupPath"

# Replace each flagcdn.com URL with local path
$replacementCount = 0
foreach ($flagFile in $flagFiles) {
    $countryCode = [System.IO.Path]::GetFileNameWithoutExtension($flagFile)
    
    # Handle special cases for files with different names
    $oldPattern = "https://flagcdn\.com/w512/$countryCode\.png"
    $newPath = "./media/questions/flags/$flagFile"
    
    $oldContent = $content
    $content = $content -replace $oldPattern, $newPath
    
    if ($content -ne $oldContent) {
        $replacementCount++
        Write-Host "Replaced $countryCode flag URL"
    }
}

# Handle special cases for countries with different naming
$specialCases = @{
    "bhutan" = "bt"
    "brazil" = "br" 
    "canada" = "ca"
    "egypt" = "eg"
    "germany" = "de"
    "japan" = "jp"
    "nepal" = "np"
    "saudi" = "sa"
}

foreach ($specialFile in $specialCases.Keys) {
    $countryCode = $specialCases[$specialFile]
    $oldPattern = "https://flagcdn\.com/w512/$countryCode\.png"
    $newPath = "./media/questions/flags/$specialFile.png"
    
    $oldContent = $content
    $content = $content -replace $oldPattern, $newPath
    
    if ($content -ne $oldContent) {
        $replacementCount++
        Write-Host "Replaced $countryCode flag URL with special file: $specialFile.png"
    }
}

# Write the updated content back to the file
$content | Set-Content $flagsJsonPath -Encoding UTF8

Write-Host "Completed! Made $replacementCount replacements."
Write-Host "Original file backed up to: $backupPath"
