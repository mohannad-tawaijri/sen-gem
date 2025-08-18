# PowerShell script to rebalance flag question difficulties
$flagsJsonPath = "C:\Users\Admin\Desktop\sen-gem\sinjeem-game\public\questions\flags.json"

Write-Host "Starting to rebalance flag question difficulties..."

# Read the JSON file
$content = Get-Content $flagsJsonPath -Raw -Encoding UTF8

# Create a backup first
$backupPath = $flagsJsonPath + ".difficulty_backup2"
Copy-Item $flagsJsonPath $backupPath
Write-Host "Created backup at: $backupPath"

$replacementCount = 0

# Easy countries (should be 200) - Very well known flags
$easyFlags = @('sa.png', 'eg.png', 'ae.png', 'qa.png', 'kw.png', 'om.png', 'bh.png', 'jo.png', 'ma.png', 'dz.png', 'tn.png', 'ly.png', 'iq.png',
    'us.png', 'ca.png', 'br.png', 'ar.png', 'mx.png', 'au.png', 'nz.png', 'ru.png', 'cn.png', 'jp.png', 'in.png', 'kr.png',
    'fr.png', 'de.png', 'it.png', 'es.png', 'pt.png', 'gb.png', 'ie.png', 'nl.png', 'be.png', 'ch.png', 'tr.png', 'gr.png', 'se.png', 'no.png', 'dk.png')

# Medium countries (should be 400) - Moderately known
$mediumFlags = @('sy.png', 'lb.png', 'ps.png', 'ye.png', 'sd.png', 'mr.png', 'so.png', 'dj.png',
    'za.png', 'ng.png', 'gh.png', 'sn.png', 'ci.png', 'cm.png', 'et.png', 'ke.png', 'tz.png', 'ug.png', 'rw.png',
    'pl.png', 'at.png', 'cz.png', 'sk.png', 'hu.png', 'ro.png', 'bg.png', 'ua.png', 'md.png', 'ge.png', 'am.png', 'az.png',
    'pk.png', 'bd.png', 'lk.png', 'np.png', 'bt.png', 'th.png', 'vn.png', 'id.png', 'my.png', 'ph.png', 'sg.png', 'fi.png')

# Process each flag type
foreach ($flag in $easyFlags) {
    $pattern = '("src":\s*"[^"]*/' + [regex]::Escape($flag) + '",[\s\S]*?"difficulty":\s*)(\d+)'
    $newContent = $content -replace $pattern, '${1}200'
    if ($newContent -ne $content) {
        $content = $newContent
        $replacementCount++
        Write-Host "Set $flag to difficulty 200"
    }
}

foreach ($flag in $mediumFlags) {
    $pattern = '("src":\s*"[^"]*/' + [regex]::Escape($flag) + '",[\s\S]*?"difficulty":\s*)(\d+)'
    $newContent = $content -replace $pattern, '${1}400'
    if ($newContent -ne $content) {
        $content = $newContent
        $replacementCount++
        Write-Host "Set $flag to difficulty 400"
    }
}

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
