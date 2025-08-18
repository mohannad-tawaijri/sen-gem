# PowerShell script to create better custom images for GOT
Add-Type -AssemblyName System.Drawing

$gotDir = "C:\Users\Admin\Desktop\sen-gem\sinjeem-game\public\media\questions\got"

Write-Host "Creating better custom Game of Thrones images..."

function New-GOTImage($filename, $bgColor, $textColor, $title, $subtitle) {
    $filepath = Join-Path $gotDir $filename
    
    try {
        # Create high quality bitmap
        $bitmap = New-Object System.Drawing.Bitmap(400, 300)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        
        # High quality rendering
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
        
        # Create gradient background
        $rect = New-Object System.Drawing.Rectangle(0, 0, 400, 300)
        $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, [System.Drawing.Color]::FromName($bgColor), [System.Drawing.Color]::Black, 45)
        $graphics.FillRectangle($brush, $rect)
        
        # Add border
        $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromName($textColor), 3)
        $graphics.DrawRectangle($borderPen, 5, 5, 390, 290)
        
        # Text setup
        $textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromName($textColor))
        $font1 = New-Object System.Drawing.Font("Arial", 26, [System.Drawing.FontStyle]::Bold)
        $font2 = New-Object System.Drawing.Font("Arial", 18)
        $font3 = New-Object System.Drawing.Font("Arial", 14)
        
        # Draw text
        $graphics.DrawString($title, $font1, $textBrush, 30, 120)
        $graphics.DrawString($subtitle, $font2, $textBrush, 30, 160)
        $graphics.DrawString("Game of Thrones", $font3, $textBrush, 30, 250)
        
        # Save
        $bitmap.Save($filepath, [System.Drawing.Imaging.ImageFormat]::Png)
        
        # Cleanup
        $graphics.Dispose()
        $bitmap.Dispose()
        $brush.Dispose()
        $textBrush.Dispose()
        $font1.Dispose()
        $font2.Dispose()
        $font3.Dispose()
        $borderPen.Dispose()
        
        Write-Host "Created $filename"
        return $true
    }
    catch {
        Write-Host "Failed $filename : $($_.Exception.Message)"
        return $false
    }
}

# Key images to improve
$images = @{
    "winterfell.png" = @{ 
        bg = "SlateGray"; text = "White"; title = "WINTERFELL"; subtitle = "Castle of House Stark" 
    }
    "iron_throne.png" = @{ 
        bg = "DimGray"; text = "Gold"; title = "IRON THRONE"; subtitle = "Seat of the Seven Kingdoms" 
    }
    "dragons.png" = @{ 
        bg = "DarkRed"; text = "Gold"; title = "DRAGONS"; subtitle = "Fire and Blood" 
    }
    "night_king.png" = @{ 
        bg = "MidnightBlue"; text = "LightBlue"; title = "NIGHT KING"; subtitle = "Lord of the Dead" 
    }
    "stark_wolf.png" = @{ 
        bg = "DarkGray"; text = "White"; title = "DIREWOLF"; subtitle = "Winter is Coming" 
    }
    "the_wall.png" = @{ 
        bg = "LightSteelBlue"; text = "DarkBlue"; title = "THE WALL"; subtitle = "Shield of the Realm" 
    }
    "kings_landing.png" = @{ 
        bg = "Goldenrod"; text = "DarkRed"; title = "KINGS LANDING"; subtitle = "Capital of Westeros" 
    }
    "cersei.png" = @{ 
        bg = "Gold"; text = "DarkRed"; title = "CERSEI LANNISTER"; subtitle = "Queen of the Seven Kingdoms" 
    }
}

$count = 0

foreach ($filename in $images.Keys) {
    $imageInfo = $images[$filename]
    
    if (New-GOTImage $filename $imageInfo.bg $imageInfo.text $imageInfo.title $imageInfo.subtitle) {
        $count++
    }
}

Write-Host "`nCreated $count high-quality images"

# Check results
$allImages = Get-ChildItem "$gotDir\*.png"
$highQuality = $allImages | Where-Object {$_.Length -gt 20000}
$realPhotos = $allImages | Where-Object {$_.Length -gt 10000 -and $_.Length -lt 20000}

Write-Host "High quality custom: $($highQuality.Count)"
Write-Host "Real photos: $($realPhotos.Count)"

Write-Host "`nBest images:"
$allImages | Where-Object {$_.Length -gt 10000} | Sort-Object Length -Descending | ForEach-Object { 
    Write-Host "  $($_.Name) - $([math]::Round($_.Length/1KB, 1))KB" 
}
