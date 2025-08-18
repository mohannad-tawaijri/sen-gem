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

# Define difficulty levels based on how well-known the countries are
# Level 200 (Easy) - Very well-known countries
$level200Countries = @(
    'السعودية', 'مصر', 'الإمارات', 'قطر', 'الكويت', 'عُمان', 'البحرين', 'الأردن', 'المغرب', 'الجزائر', 'تونس', 'ليبيا',
    'اليابان', 'الصين', 'الهند', 'كوريا الجنوبية', 'تركيا', 'فرنسا', 'ألمانيا', 'إيطاليا', 'إسبانيا', 'البرتغال',
    'بريطانيا', 'أيرلندا', 'هولندا', 'بلجيكا', 'سويسرا', 'أمريكا', 'كندا', 'البرازيل', 'الأرجنتين', 'المكسيك',
    'أستراليا', 'نيوزيلندا', 'روسيا', 'اليونان', 'السويد', 'النرويج', 'الدنمارك', 'العراق'
)

# Level 400 (Medium) - Moderately known countries
$level400Countries = @(
    'سوريا', 'لبنان', 'فلسطين', 'اليمن', 'السودان', 'موريتانيا', 'الصومال', 'جيبوتي',
    'جنوب أفريقيا', 'نيجيريا', 'غانا', 'السنغال', 'ساحل العاج', 'الكاميرون', 'إثيوبيا', 'كينيا', 'تنزانيا', 'أوغندا', 'رواندا',
    'بولندا', 'النمسا', 'التشيك', 'سلوفاكيا', 'المجر', 'رومانيا', 'بلغاريا', 'أوكرانيا', 'مولدوفا', 'جورجيا', 'أرمينيا', 'أذربيجان',
    'باكستان', 'بنغلاديش', 'سريلانكا', 'نيبال', 'بوتان', 'تايلاند', 'فيتنام', 'إندونيسيا', 'ماليزيا', 'الفلبين',
    'الأوروغواي', 'تشيلي', 'كولومبيا', 'بيرو', 'فنزويلا', 'الإكوادور', 'فنلندا'
)

# All others will be Level 600 (Hard) - Lesser-known countries, small islands, difficult flags

$replacementCount = 0

# Function to update difficulty for a country
function Update-CountryDifficulty($countryName, $newDifficulty) {
    $pattern = '("a":\s*"' + [regex]::Escape($countryName) + '".*?"difficulty":\s*)(\d+)'
    $replacement = '${1}' + $newDifficulty
    
    $script:content = $script:content -replace $pattern, $replacement
    
    # Also update the ID to match the new difficulty
    $oldIdPattern = '("id":\s*"flags-)\d+(-\d+",.*?"a":\s*"' + [regex]::Escape($countryName) + '")'
    $newIdReplacement = '${1}' + $newDifficulty + '${2}'
    $script:content = $script:content -replace $oldIdPattern, $newIdReplacement
}

# Update Level 200 countries
Write-Host "Setting easy countries to difficulty 200..."
foreach ($country in $level200Countries) {
    Update-CountryDifficulty $country 200
    $replacementCount++
}

# Update Level 400 countries  
Write-Host "Setting medium countries to difficulty 400..."
foreach ($country in $level400Countries) {
    Update-CountryDifficulty $country 400
    $replacementCount++
}

# All remaining countries will automatically be 600 (hard) as they are the least known

# Write the updated content back to the file
$content | Set-Content $flagsJsonPath -Encoding UTF8

Write-Host "Completed! Updated difficulty levels for flag questions."
Write-Host "Original file backed up to: $backupPath"

# Show the new distribution
$difficulties = (Get-Content $flagsJsonPath | Select-String '"difficulty": (\d+)' | ForEach-Object { $_.Matches[0].Groups[1].Value } | Group-Object | Sort-Object Name)
Write-Host "`nNew difficulty distribution:"
foreach ($diff in $difficulties) {
    Write-Host "Level $($diff.Name): $($diff.Count) questions"
}
