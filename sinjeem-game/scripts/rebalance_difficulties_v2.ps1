# PowerShell script to rebalance flag question difficulties
# Making 600 level truly difficult and 400 level more reasonable

$flagsJsonPath = "C:\Users\Admin\Desktop\sen-gem\sinjeem-game\public\questions\flags.json"

Write-Host "Starting to rebalance flag question difficulties..."

# Read the JSON file
$content = Get-Content $flagsJsonPath -Raw -Encoding UTF8

# Create a backup first
$backupPath = $flagsJsonPath + ".difficulty_backup"
Copy-Item $flagsJsonPath $backupPath
Write-Host "Created backup at: $backupPath"

# Easy countries (Level 200) - Major world powers, Arab countries, well-known countries
# These should stay at 200 or be moved to 200
$easyCountries = @(
    'sa.png', 'eg.png', 'ae.png', 'qa.png', 'kw.png', 'om.png', 'bh.png', 'jo.png', 'ma.png', 'dz.png', 'tn.png', 'ly.png',
    'us.png', 'ca.png', 'br.png', 'ar.png', 'mx.png', 'au.png', 'nz.png', 'ru.png', 'cn.png', 'jp.png', 'in.png', 'kr.png',
    'fr.png', 'de.png', 'it.png', 'es.png', 'pt.png', 'gb.png', 'ie.png', 'nl.png', 'be.png', 'ch.png', 'tr.png', 'gr.png', 'se.png', 'no.png', 'dk.png'
)

# Medium countries (Level 400) - Regional powers, some European/Asian/African countries
$mediumCountries = @(
    'iq.png', 'sy.png', 'lb.png', 'ps.png', 'ye.png', 'sd.png', 'mr.png', 'so.png', 'dj.png',
    'za.png', 'ng.png', 'gh.png', 'sn.png', 'ci.png', 'cm.png', 'et.png', 'ke.png', 'tz.png', 'ug.png', 'rw.png',
    'pl.png', 'at.png', 'cz.png', 'sk.png', 'hu.png', 'ro.png', 'bg.png', 'ua.png', 'md.png', 'ge.png', 'am.png', 'az.png',
    'pk.png', 'bd.png', 'lk.png', 'np.png', 'bt.png', 'th.png', 'vn.png', 'id.png', 'my.png', 'ph.png', 'sg.png', 'fi.png'
)

# All other countries will be Level 600 (Hard) - Small islands, less known countries, difficult flags

$replacementCount = 0

# Function to update difficulty based on flag filename
function Update-FlagDifficulty($flagFile, $newDifficulty) {
    # Find entries with this flag file and update their difficulty
    $pattern = '("src":\s*"[^"]*/' + [regex]::Escape($flagFile) + '"[^}]*"difficulty":\s*)(\d+)'
    $oldContent = $script:content
    $script:content = $script:content -replace $pattern, ('${1}' + $newDifficulty)
    
    if ($script:content -ne $oldContent) {
        $script:replacementCount++
        Write-Host "Updated $flagFile to difficulty $newDifficulty"
    }
}

# Update easy countries to level 200
Write-Host "Setting easy countries to difficulty 200..."
foreach ($flagFile in $easyCountries) {
    Update-FlagDifficulty $flagFile 200
}

# Update medium countries to level 400
Write-Host "Setting medium countries to difficulty 400..."
foreach ($flagFile in $mediumCountries) {
    Update-FlagDifficulty $flagFile 400
}

# All remaining countries will automatically stay at 600 or be set to 600

# Write the updated content back to the file
$content | Set-Content $flagsJsonPath -Encoding UTF8

Write-Host "Completed! Updated $replacementCount flag difficulties."
Write-Host "Original file backed up to: $backupPath"

# Show the new distribution
Write-Host "`nCalculating new difficulty distribution..."
$difficulties = (Get-Content $flagsJsonPath | Select-String '"difficulty": (\d+)' | ForEach-Object { $_.Matches[0].Groups[1].Value } | Group-Object | Sort-Object Name)
Write-Host "`nNew difficulty distribution:"
foreach ($diff in $difficulties) {
    Write-Host "Level $($diff.Name): $($diff.Count) questions"
}
