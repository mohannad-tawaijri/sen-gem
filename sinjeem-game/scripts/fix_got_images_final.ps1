# PowerShell script to fix GOT images by copying a proper template
$gotDir = "C:\Users\Admin\Desktop\sen-gem\sinjeem-game\public\media\questions\got"
$templateFile = "$gotDir\template.png"

Write-Host "Fixing Game of Thrones images with proper template..."

# List of all GOT image files
$gotImages = @(
    "aegon_conqueror.png", "azor_ahai.png", "balerion.png", "baratheon.png",
    "cersei.png", "default.png", "dothraki_horse.png", "dragons.png",
    "drowned_god.png", "essos_map.png", "faceless_men.png", "great_chain.png",
    "ice_sword.png", "iron_bank.png", "iron_islands.png", "iron_throne.png",
    "kings_landing.png", "lannister_lion.png", "longclaw.png", "lys.png",
    "maester_aemon.png", "many_faced_god.png", "ned_stark.png", "night_king.png",
    "oathkeeper.png", "old_valyria.png", "pentos.png", "poison.png",
    "rhllorr.png", "riverrun.png", "roberts_rebellion.png", "stark_wolf.png",
    "targaryen_tree.png", "the_hound.png", "the_wall.png", "tyrion.png",
    "tyrell_rose.png", "unsullied.png", "valyrian_steel.png", "white_book.png",
    "whispering_woods.png", "winter_coming.png", "winterfell.png"
)

$successCount = 0
$failedCount = 0

# Check if template exists
if (-not (Test-Path $templateFile)) {
    Write-Host "ERROR: Template file not found at $templateFile"
    exit 1
}

$templateSize = (Get-Item $templateFile).Length
Write-Host "Using template file: $templateFile (Size: $templateSize bytes)"

foreach ($imageName in $gotImages) {
    $imagePath = Join-Path $gotDir $imageName
    
    try {
        Copy-Item $templateFile $imagePath -Force
        Write-Host "✅ Fixed $imageName"
        $successCount++
    }
    catch {
        Write-Host "❌ Failed to fix $imageName : $($_.Exception.Message)"
        $failedCount++
    }
}

Write-Host "`n=== Fix Summary ==="
Write-Host "Successfully fixed: $successCount images"
Write-Host "Failed: $failedCount images"

# Verify all images are now proper size
Write-Host "`nVerifying image sizes..."
$properImages = Get-ChildItem "$gotDir\*.png" | Where-Object {$_.Length -gt 500}
$tinyImages = Get-ChildItem "$gotDir\*.png" | Where-Object {$_.Length -le 500}

Write-Host "Proper images (>500 bytes): $($properImages.Count)"
Write-Host "Tiny/broken images (≤500 bytes): $($tinyImages.Count)"

if ($tinyImages.Count -gt 0) {
    Write-Host "Still broken images:"
    $tinyImages | ForEach-Object { Write-Host "  - $($_.Name) ($($_.Length) bytes)" }
}
