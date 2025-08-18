# PowerShell script to create simple colored placeholder images for GOT
$gotDir = "C:\Users\Admin\Desktop\sen-gem\sinjeem-game\public\media\questions\got"

Write-Host "Creating simple placeholder images for Game of Thrones..."

# Function to create a simple colored PNG using .NET
function Create-ColoredImage($filename, $color, $text) {
    $filepath = Join-Path $gotDir $filename
    
    try {
        # Create a simple HTML file that can be used as placeholder
        $htmlContent = @"
<html><body style='background-color:$color;margin:0;padding:20px;font-family:Arial;color:white;text-align:center;'>
<h2>$text</h2>
<p>Game of Thrones</p>
</body></html>
"@
        
        # For now, let's just create a simple text file as placeholder
        $textContent = "$text - Game of Thrones"
        Set-Content -Path ($filepath -replace '\.png$', '.txt') -Value $textContent
        
        # Copy a generic image if available, or create an empty file
        if (Test-Path "$gotDir\default.png") {
            Copy-Item "$gotDir\default.png" $filepath -Force
            Write-Host "Created placeholder for $filename using default.png"
            return $true
        } else {
            # Create a minimal PNG file (1x1 pixel)
            $pngBytes = [Convert]::FromBase64String("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==")
            [System.IO.File]::WriteAllBytes($filepath, $pngBytes)
            Write-Host "Created minimal PNG for $filename"
            return $true
        }
    } catch {
        Write-Host "Failed to create $filename : $($_.Exception.Message)"
        return $false
    }
}

# Define images with colors and descriptions
$images = @{
    "baratheon.png" = @{ color = "#FFD700"; text = "House Baratheon" }
    "iron_throne.png" = @{ color = "#2F2F2F"; text = "Iron Throne" }
    "ned_stark.png" = @{ color = "#8B4513"; text = "Ned Stark" }
    "dragons.png" = @{ color = "#DC143C"; text = "Three Dragons" }
    "kings_landing.png" = @{ color = "#DAA520"; text = "Kings Landing" }
    "stark_wolf.png" = @{ color = "#696969"; text = "Stark Direwolf" }
    "winter_coming.png" = @{ color = "#4682B4"; text = "Winter is Coming" }
    "cersei.png" = @{ color = "#FFD700"; text = "Cersei Lannister" }
    "the_hound.png" = @{ color = "#2F4F4F"; text = "The Hound" }
    "longclaw.png" = @{ color = "#C0C0C0"; text = "Longclaw Sword" }
    "lannister_lion.png" = @{ color = "#FFD700"; text = "Lannister Lion" }
    "the_wall.png" = @{ color = "#F0F8FF"; text = "The Wall" }
    "tyrion.png" = @{ color = "#FFD700"; text = "Tyrion Lannister" }
    "faceless_men.png" = @{ color = "#2F2F2F"; text = "Faceless Men" }
    "pentos.png" = @{ color = "#DDA0DD"; text = "Pentos" }
    "many_faced_god.png" = @{ color = "#000000"; text = "Many Faced God" }
    "tyrell_rose.png" = @{ color = "#32CD32"; text = "Tyrell Rose" }
    "night_king.png" = @{ color = "#4169E1"; text = "Night King" }
    "poison.png" = @{ color = "#8B008B"; text = "Poison" }
    "ice_sword.png" = @{ color = "#4682B4"; text = "Ice Sword" }
    "winterfell.png" = @{ color = "#708090"; text = "Winterfell" }
    "essos_map.png" = @{ color = "#CD853F"; text = "Essos Map" }
    "rhllorr.png" = @{ color = "#FF4500"; text = "R'hllor Lord of Light" }
    "unsullied.png" = @{ color = "#8B4513"; text = "Unsullied Army" }
    "iron_bank.png" = @{ color = "#2F4F4F"; text = "Iron Bank" }
    "dothraki_horse.png" = @{ color = "#8B4513"; text = "Dothraki Horse" }
    "valyrian_steel.png" = @{ color = "#C0C0C0"; text = "Valyrian Steel" }
    "old_valyria.png" = @{ color = "#8B0000"; text = "Old Valyria" }
    "oathkeeper.png" = @{ color = "#FFD700"; text = "Oathkeeper Sword" }
    "white_book.png" = @{ color = "#F5F5F5"; text = "White Book" }
    "roberts_rebellion.png" = @{ color = "#8B0000"; text = "Roberts Rebellion" }
    "whispering_woods.png" = @{ color = "#228B22"; text = "Whispering Woods" }
    "targaryen_tree.png" = @{ color = "#8B0000"; text = "Targaryen Family Tree" }
    "azor_ahai.png" = @{ color = "#FF4500"; text = "Azor Ahai" }
    "aegon_conqueror.png" = @{ color = "#8B0000"; text = "Aegon the Conqueror" }
    "maester_aemon.png" = @{ color = "#696969"; text = "Maester Aemon" }
    "riverrun.png" = @{ color = "#4682B4"; text = "Riverrun Castle" }
    "balerion.png" = @{ color = "#000000"; text = "Balerion the Black Dread" }
    "iron_islands.png" = @{ color = "#2F4F4F"; text = "Iron Islands" }
    "drowned_god.png" = @{ color = "#008B8B"; text = "Drowned God" }
    "lys.png" = @{ color = "#FFB6C1"; text = "Lys City" }
    "great_chain.png" = @{ color = "#696969"; text = "Great Chain" }
}

$successCount = 0
$failedCount = 0

foreach ($filename in $images.Keys) {
    $imageInfo = $images[$filename]
    
    if (Create-ColoredImage $filename $imageInfo.color $imageInfo.text) {
        $successCount++
    } else {
        $failedCount++
    }
}

Write-Host "`n=== Creation Summary ==="
Write-Host "Successfully created: $successCount images"
Write-Host "Failed: $failedCount images"
Write-Host "Images saved to: $gotDir"

# Verify final count
$finalImageCount = (Get-ChildItem $gotDir -Name "*.png").Count
Write-Host "Total PNG files: $finalImageCount"
