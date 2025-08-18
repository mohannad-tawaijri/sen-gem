# PowerShell script to comprehensively rebalance flag question difficulties
$flagsJsonPath = "C:\Users\Admin\Desktop\sen-gem\sinjeem-game\public\questions\flags.json"

Write-Host "Starting comprehensive flag difficulty rebalancing..."

# Read the JSON content
$jsonContent = Get-Content $flagsJsonPath -Raw -Encoding UTF8

# Create a backup first
$backupPath = $flagsJsonPath + ".difficulty_backup3"
Copy-Item $flagsJsonPath $backupPath
Write-Host "Created backup at: $backupPath"

# Define difficulty mappings based on country codes extracted from image paths
$difficultyMapping = @{
    # Level 200 (Easy) - Very well-known countries and major powers
    'sa' = 200; 'eg' = 200; 'ae' = 200; 'qa' = 200; 'kw' = 200; 'om' = 200; 'bh' = 200; 'jo' = 200; 'ma' = 200; 'dz' = 200; 'tn' = 200; 'ly' = 200; 'iq' = 200;
    'us' = 200; 'ca' = 200; 'br' = 200; 'ar' = 200; 'mx' = 200; 'au' = 200; 'nz' = 200; 'ru' = 200; 'cn' = 200; 'jp' = 200; 'in' = 200; 'kr' = 200;
    'fr' = 200; 'de' = 200; 'it' = 200; 'es' = 200; 'pt' = 200; 'gb' = 200; 'ie' = 200; 'nl' = 200; 'be' = 200; 'ch' = 200; 'tr' = 200; 'gr' = 200; 'se' = 200; 'no' = 200; 'dk' = 200;
    
    # Level 400 (Medium) - Regional powers and moderately known countries
    'sy' = 400; 'lb' = 400; 'ps' = 400; 'ye' = 400; 'sd' = 400; 'mr' = 400; 'so' = 400; 'dj' = 400;
    'za' = 400; 'ng' = 400; 'gh' = 400; 'sn' = 400; 'ci' = 400; 'cm' = 400; 'et' = 400; 'ke' = 400; 'tz' = 400; 'ug' = 400; 'rw' = 400;
    'pl' = 400; 'at' = 400; 'cz' = 400; 'sk' = 400; 'hu' = 400; 'ro' = 400; 'bg' = 400; 'ua' = 400; 'md' = 400; 'ge' = 400; 'am' = 400; 'az' = 400;
    'pk' = 400; 'bd' = 400; 'lk' = 400; 'np' = 400; 'bt' = 400; 'th' = 400; 'vn' = 400; 'id' = 400; 'my' = 400; 'ph' = 400; 'sg' = 400; 'fi' = 400; 'is' = 400;
    'cl' = 400; 'co' = 400; 'pe' = 400; 've' = 400; 'ec' = 400; 'uy' = 400;
    
    # All others will be Level 600 (Hard) by default
}

$updatedCount = 0

# Process each country code mapping
foreach ($countryCode in $difficultyMapping.Keys) {
    $targetDifficulty = $difficultyMapping[$countryCode]
    
    # Create pattern to match the entire question block with this country code
    $pattern = '(\{[^}]*"src":\s*"[^"]*/' + $countryCode + '\.png"[^}]*"difficulty":\s*)(\d+)([^}]*\})'
    
    $matches = [regex]::Matches($jsonContent, $pattern)
    foreach ($match in $matches) {
        $currentDifficulty = [int]$match.Groups[2].Value
        if ($currentDifficulty -ne $targetDifficulty) {
            $replacement = $match.Groups[1].Value + $targetDifficulty + $match.Groups[3].Value
            $jsonContent = $jsonContent.Replace($match.Value, $replacement)
            $updatedCount++
            Write-Host "Updated $countryCode from difficulty $currentDifficulty to $targetDifficulty"
        }
    }
}

# Also update any remaining countries to difficulty 600 (hard) if they're not already
$remainingPattern = '(\{[^}]*"src":\s*"[^"]*/)([a-z]{2})\.png("[^}]*"difficulty":\s*)(\d+)([^}]*\})'
$allMatches = [regex]::Matches($jsonContent, $remainingPattern)

foreach ($match in $allMatches) {
    $countryCode = $match.Groups[2].Value
    $currentDifficulty = [int]$match.Groups[4].Value
    
    # If this country is not in our mapping and is not already 600, set it to 600
    if (-not $difficultyMapping.ContainsKey($countryCode) -and $currentDifficulty -ne 600) {
        $replacement = $match.Groups[1].Value + $countryCode + '.png' + $match.Groups[3].Value + '600' + $match.Groups[5].Value
        $jsonContent = $jsonContent.Replace($match.Value, $replacement)
        $updatedCount++
        Write-Host "Updated unknown country $countryCode from difficulty $currentDifficulty to 600 (hard)"
    }
}

# Write the updated content back to the file
$jsonContent | Set-Content $flagsJsonPath -Encoding UTF8

Write-Host "`nCompleted! Updated $updatedCount flag difficulties."
Write-Host "Original file backed up to: $backupPath"

# Show the new distribution
Write-Host "`nCalculating new difficulty distribution..."
$difficulties = (Get-Content $flagsJsonPath | Select-String '"difficulty": (\d+)' | ForEach-Object { $_.Matches[0].Groups[1].Value } | Group-Object | Sort-Object Name)
Write-Host "`nNew difficulty distribution:"
foreach ($diff in $difficulties) {
    Write-Host "Level $($diff.Name): $($diff.Count) questions"
}

Write-Host "`nDifficulty levels explanation:"
Write-Host "Level 200 (Easy): Very well-known countries (Arab countries, major world powers)"
Write-Host "Level 400 (Medium): Regional powers and moderately known countries"
Write-Host "Level 600 (Hard): Lesser-known countries, small islands, difficult flags"
