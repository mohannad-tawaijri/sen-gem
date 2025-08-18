# PowerShell script to create better custom GOT images using .NET Graphics
Add-Type -AssemblyName System.Drawing

$gotDir = "C:\Users\Admin\Desktop\sen-gem\sinjeem-game\public\media\questions\got"

Write-Host "Creating better custom Game of Thrones images..."

# Function to create a themed image with better design
function Create-BetterGOTImage($filename, $bgColor, $textColor, $title, $subtitle, $symbol) {
    $filepath = Join-Path $gotDir $filename
    
    try {
        # Create a larger bitmap for better quality (400x300 pixels)
        $bitmap = New-Object System.Drawing.Bitmap(400, 300)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        
        # Enable high quality rendering
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
        
        # Create gradient background
        $rect = New-Object System.Drawing.Rectangle(0, 0, 400, 300)
        $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, [System.Drawing.Color]::FromName($bgColor), [System.Drawing.Color]::Black, 45)
        $graphics.FillRectangle($brush, $rect)
        
        # Add border
        $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromName($textColor), 3)
        $graphics.DrawRectangle($borderPen, 5, 5, 390, 290)
        
        # Set up text drawing
        $textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromName($textColor))
        $font1 = New-Object System.Drawing.Font("Arial", 24, [System.Drawing.FontStyle]::Bold)
        $font2 = New-Object System.Drawing.Font("Arial", 18)
        $font3 = New-Object System.Drawing.Font("Arial", 14)
        
        # Draw symbol/icon in large font
        $symbolFont = New-Object System.Drawing.Font("Arial", 48, [System.Drawing.FontStyle]::Bold)
        $symbolBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(100, [System.Drawing.Color]::FromName($textColor)))
        $graphics.DrawString($symbol, $symbolFont, $symbolBrush, 150, 50)
        
        # Draw title and subtitle
        $graphics.DrawString($title, $font1, $textBrush, 50, 150)
        $graphics.DrawString($subtitle, $font2, $textBrush, 50, 190)
        $graphics.DrawString("Game of Thrones", $font3, $textBrush, 50, 250)
        
        # Save as PNG with high quality
        $bitmap.Save($filepath, [System.Drawing.Imaging.ImageFormat]::Png)
        
        # Clean up
        $graphics.Dispose()
        $bitmap.Dispose()
        $brush.Dispose()
        $textBrush.Dispose()
        $symbolBrush.Dispose()
        $font1.Dispose()
        $font2.Dispose()
        $font3.Dispose()
        $symbolFont.Dispose()
        $borderPen.Dispose()
        
        Write-Host "Created better $filename"
        return $true
    }
    catch {
        Write-Host "Failed to create $filename : $($_.Exception.Message)"
        return $false
    }
}

# Better designs for key GOT images
$betterImages = @{
    "winterfell.png" = @{ 
        bg = "SlateGray"; text = "White"; title = "WINTERFELL"; subtitle = "House Stark Castle"; symbol = "🏰" 
    }
    "iron_throne.png" = @{ 
        bg = "DimGray"; text = "Gold"; title = "IRON THRONE"; subtitle = "Seat of Power"; symbol = "👑" 
    }
    "dragons.png" = @{ 
        bg = "DarkRed"; text = "Gold"; title = "DRAGONS"; subtitle = "Fire and Blood"; symbol = "🐉" 
    }
    "night_king.png" = @{ 
        bg = "MidnightBlue"; text = "LightBlue"; title = "NIGHT KING"; subtitle = "Lord of the Dead"; symbol = "❄️" 
    }
    "stark_wolf.png" = @{ 
        bg = "DarkGray"; text = "White"; title = "DIREWOLF"; subtitle = "Winter is Coming"; symbol = "🐺" 
    }
    "lannister_lion.png" = @{ 
        bg = "Gold"; text = "DarkRed"; title = "HOUSE LANNISTER"; subtitle = "Hear Me Roar"; symbol = "🦁" 
    }
    "the_wall.png" = @{ 
        bg = "LightSteelBlue"; text = "DarkBlue"; title = "THE WALL"; subtitle = "Shield of the Realm"; symbol = "🧱" 
    }
    "kings_landing.png" = @{ 
        bg = "Goldenrod"; text = "DarkRed"; title = "KING'S LANDING"; subtitle = "Capital City"; symbol = "🏛️" 
    }
    "cersei.png" = @{ 
        bg = "Gold"; text = "DarkRed"; title = "CERSEI"; subtitle = "Queen Regent"; symbol = "👸" 
    }
    "baratheon.png" = @{ 
        bg = "Gold"; text = "Black"; title = "HOUSE BARATHEON"; subtitle = "Ours is the Fury"; symbol = "🦌" 
    }
}

$successCount = 0
$failedCount = 0

foreach ($filename in $betterImages.Keys) {
    $imageInfo = $betterImages[$filename]
    
    # Only create if current image is small (placeholder)
    $currentPath = Join-Path $gotDir $filename
    $shouldCreate = $true
    
    if (Test-Path $currentPath) {
        $currentSize = (Get-Item $currentPath).Length
        if ($currentSize -gt 15000) {
            Write-Host "Skipping $filename - already have good image"
            $shouldCreate = $false
        }
    }
    
    if ($shouldCreate) {
        if (Create-BetterGOTImage $filename $imageInfo.bg $imageInfo.text $imageInfo.title $imageInfo.subtitle $imageInfo.symbol) {
            $successCount++
        } else {
            $failedCount++
        }
    }
}

Write-Host "`n=== Creation Summary ==="
Write-Host "Successfully created: $successCount better images"
Write-Host "Failed: $failedCount images"

# Verify final results
$allImages = Get-ChildItem "$gotDir\*.png"
$goodImages = $allImages | Where-Object {$_.Length -gt 15000}
$realImages = $allImages | Where-Object {$_.Length -gt 10000 -and $_.Length -lt 15000}
$smallImages = $allImages | Where-Object {$_.Length -le 10000}

Write-Host "`nFinal image status:"
Write-Host "High quality custom images: $($goodImages.Count)"
Write-Host "Real downloaded images: $($realImages.Count)"  
Write-Host "Small placeholder images: $($smallImages.Count)"

Write-Host "`nBest images available:"
$allImages | Where-Object {$_.Length -gt 10000} | Sort-Object Length -Descending | ForEach-Object { 
    Write-Host "  $($_.Name) - $([math]::Round($_.Length/1KB, 1))KB" 
}
