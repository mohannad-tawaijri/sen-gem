# PowerShell script to create proper GOT-themed placeholder images
Add-Type -AssemblyName System.Drawing

$gotDir = "C:\Users\Admin\Desktop\sen-gem\sinjeem-game\public\media\questions\got"

Write-Host "Creating Game of Thrones themed placeholder images..."

# Function to create a colored image with text
function Create-GOTImage($filename, $bgColor, $textColor, $title, $subtitle) {
    $filepath = Join-Path $gotDir $filename
    
    try {
        # Create a bitmap (200x150 pixels)
        $bitmap = New-Object System.Drawing.Bitmap(200, 150)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        
        # Set background color
        $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromName($bgColor))
        $graphics.FillRectangle($brush, 0, 0, 200, 150)
        
        # Set up text drawing
        $textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromName($textColor))
        $font1 = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
        $font2 = New-Object System.Drawing.Font("Arial", 10)
        
        # Draw title and subtitle
        $graphics.DrawString($title, $font1, $textBrush, 10, 50)
        $graphics.DrawString($subtitle, $font2, $textBrush, 10, 80)
        $graphics.DrawString("Game of Thrones", $font2, $textBrush, 10, 120)
        
        # Save as PNG
        $bitmap.Save($filepath, [System.Drawing.Imaging.ImageFormat]::Png)
        
        # Clean up
        $graphics.Dispose()
        $bitmap.Dispose()
        $brush.Dispose()
        $textBrush.Dispose()
        $font1.Dispose()
        $font2.Dispose()
        
        Write-Host "✅ Created $filename"
        return $true
    }
    catch {
        Write-Host "❌ Failed to create $filename : $($_.Exception.Message)"
        return $false
    }
}

# Define GOT images with colors and descriptions
$gotImages = @{
    "aegon_conqueror.png" = @{ bg = "DarkRed"; text = "White"; title = "Aegon I"; subtitle = "The Conqueror" }
    "azor_ahai.png" = @{ bg = "OrangeRed"; text = "White"; title = "Azor Ahai"; subtitle = "The Prince" }
    "balerion.png" = @{ bg = "Black"; text = "Red"; title = "Balerion"; subtitle = "Black Dread" }
    "baratheon.png" = @{ bg = "Gold"; text = "Black"; title = "Baratheon"; subtitle = "Ours is the Fury" }
    "cersei.png" = @{ bg = "Gold"; text = "DarkRed"; title = "Cersei"; subtitle = "Lannister" }
    "default.png" = @{ bg = "DarkSlateGray"; text = "White"; title = "Game of"; subtitle = "Thrones" }
    "dothraki_horse.png" = @{ bg = "SaddleBrown"; text = "White"; title = "Dothraki"; subtitle = "Horse Lords" }
    "dragons.png" = @{ bg = "DarkRed"; text = "Gold"; title = "Three"; subtitle = "Dragons" }
    "drowned_god.png" = @{ bg = "DarkCyan"; text = "White"; title = "Drowned"; subtitle = "God" }
    "essos_map.png" = @{ bg = "Peru"; text = "White"; title = "Essos"; subtitle = "Eastern Continent" }
    "faceless_men.png" = @{ bg = "Black"; text = "White"; title = "Faceless"; subtitle = "Men" }
    "great_chain.png" = @{ bg = "Gray"; text = "White"; title = "Great"; subtitle = "Chain" }
    "ice_sword.png" = @{ bg = "LightBlue"; text = "DarkBlue"; title = "Ice"; subtitle = "Valyrian Steel" }
    "iron_bank.png" = @{ bg = "DarkSlateGray"; text = "Gold"; title = "Iron"; subtitle = "Bank of Braavos" }
    "iron_islands.png" = @{ bg = "DarkSlateGray"; text = "White"; title = "Iron"; subtitle = "Islands" }
    "iron_throne.png" = @{ bg = "DimGray"; text = "White"; title = "Iron"; subtitle = "Throne" }
    "kings_landing.png" = @{ bg = "Gold"; text = "DarkRed"; title = "King's"; subtitle = "Landing" }
    "lannister_lion.png" = @{ bg = "Gold"; text = "DarkRed"; title = "Lannister"; subtitle = "Hear Me Roar" }
    "longclaw.png" = @{ bg = "Silver"; text = "Black"; title = "Longclaw"; subtitle = "Jon's Sword" }
    "lys.png" = @{ bg = "Pink"; text = "DarkMagenta"; title = "Lys"; subtitle = "Free City" }
    "maester_aemon.png" = @{ bg = "Gray"; text = "White"; title = "Maester"; subtitle = "Aemon" }
    "many_faced_god.png" = @{ bg = "Black"; text = "White"; title = "Many-Faced"; subtitle = "God" }
    "ned_stark.png" = @{ bg = "Gray"; text = "White"; title = "Ned"; subtitle = "Stark" }
    "night_king.png" = @{ bg = "Blue"; text = "White"; title = "Night"; subtitle = "King" }
    "oathkeeper.png" = @{ bg = "Gold"; text = "Red"; title = "Oathkeeper"; subtitle = "Brienne's Sword" }
    "old_valyria.png" = @{ bg = "DarkRed"; text = "Gold"; title = "Old"; subtitle = "Valyria" }
    "pentos.png" = @{ bg = "Purple"; text = "White"; title = "Pentos"; subtitle = "Free City" }
    "poison.png" = @{ bg = "DarkMagenta"; text = "White"; title = "The"; subtitle = "Strangler" }
    "rhllorr.png" = @{ bg = "OrangeRed"; text = "White"; title = "R'hllor"; subtitle = "Lord of Light" }
    "riverrun.png" = @{ bg = "Blue"; text = "White"; title = "Riverrun"; subtitle = "Tully Castle" }
    "roberts_rebellion.png" = @{ bg = "DarkRed"; text = "White"; title = "Robert's"; subtitle = "Rebellion" }
    "stark_wolf.png" = @{ bg = "Gray"; text = "White"; title = "Stark"; subtitle = "Winter is Coming" }
    "targaryen_tree.png" = @{ bg = "DarkRed"; text = "White"; title = "Targaryen"; subtitle = "Family Tree" }
    "the_hound.png" = @{ bg = "DarkGray"; text = "White"; title = "The"; subtitle = "Hound" }
    "the_wall.png" = @{ bg = "LightBlue"; text = "DarkBlue"; title = "The"; subtitle = "Wall" }
    "tyrion.png" = @{ bg = "Gold"; text = "DarkRed"; title = "Tyrion"; subtitle = "Lannister" }
    "tyrell_rose.png" = @{ bg = "Green"; text = "White"; title = "Tyrell"; subtitle = "Growing Strong" }
    "unsullied.png" = @{ bg = "SaddleBrown"; text = "White"; title = "Unsullied"; subtitle = "Elite Warriors" }
    "valyrian_steel.png" = @{ bg = "Silver"; text = "Black"; title = "Valyrian"; subtitle = "Steel" }
    "white_book.png" = @{ bg = "White"; text = "Black"; title = "White"; subtitle = "Book" }
    "whispering_woods.png" = @{ bg = "DarkGreen"; text = "White"; title = "Whispering"; subtitle = "Woods" }
    "winter_coming.png" = @{ bg = "Blue"; text = "White"; title = "Winter"; subtitle = "is Coming" }
    "winterfell.png" = @{ bg = "Gray"; text = "White"; title = "Winterfell"; subtitle = "Stark Castle" }
}

$successCount = 0
$failedCount = 0

foreach ($filename in $gotImages.Keys) {
    $imageInfo = $gotImages[$filename]
    
    if (Create-GOTImage $filename $imageInfo.bg $imageInfo.text $imageInfo.title $imageInfo.subtitle) {
        $successCount++
    } else {
        $failedCount++
    }
}

Write-Host "`n=== Creation Summary ==="
Write-Host "Successfully created: $successCount GOT images"
Write-Host "Failed: $failedCount images"
Write-Host "Images saved to: $gotDir"

# Verify final count and sizes
$finalImages = Get-ChildItem "$gotDir\*.png"
Write-Host "Total PNG files: $($finalImages.Count)"
Write-Host "Average file size: $(($finalImages | Measure-Object -Property Length -Average).Average) bytes"
