# PowerShell script to download real Game of Thrones images
$gotDir = "C:\Users\Admin\Desktop\sen-gem\sinjeem-game\public\media\questions\got"

Write-Host "Downloading real Game of Thrones images..."

# Function to download image with retries
function Download-GOTImage($filename, $urls, $description) {
    $filepath = Join-Path $gotDir $filename
    
    foreach ($url in $urls) {
        try {
            Write-Host "Downloading $description from $url..."
            Invoke-WebRequest -Uri $url -OutFile $filepath -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
            
            # Check if file was downloaded and is valid
            if (Test-Path $filepath) {
                $fileSize = (Get-Item $filepath).Length
                if ($fileSize -gt 1000) {
                    Write-Host "✅ Successfully downloaded $filename ($fileSize bytes)"
                    return $true
                }
            }
        }
        catch {
            Write-Host "❌ Failed to download from $url : $($_.Exception.Message)"
        }
    }
    
    Write-Host "⚠️ All download attempts failed for $filename"
    return $false
}

# Real GOT image URLs from multiple sources
$gotImages = @{
    "tyrion.png" = @{
        desc = "Tyrion Lannister"
        urls = @(
            "https://static.wikia.nocookie.net/gameofthrones/images/5/58/Tyrion_Lannister_S8.jpg",
            "https://upload.wikimedia.org/wikipedia/en/5/50/Tyrion_Lannister-Peter_Dinklage.jpg",
            "https://hips.hearstapps.com/hmg-prod.s3.amazonaws.com/images/tyrion-lannister-1554903467.jpg"
        )
    }
    "ned_stark.png" = @{
        desc = "Ned Stark"
        urls = @(
            "https://static.wikia.nocookie.net/gameofthrones/images/d/d6/EddardStark.jpg",
            "https://upload.wikimedia.org/wikipedia/en/5/52/Ned_Stark-Sean_Bean.jpg",
            "https://hips.hearstapps.com/digitalspyuk.cdnds.net/16/20/1463741892-ned-stark-game-of-thrones.jpg"
        )
    }
    "cersei.png" = @{
        desc = "Cersei Lannister"
        urls = @(
            "https://static.wikia.nocookie.net/gameofthrones/images/c/c3/CerseiLannister.jpg",
            "https://upload.wikimedia.org/wikipedia/en/2/22/Cersei_Lannister-Lena_Headey.jpg",
            "https://hips.hearstapps.com/hmg-prod.s3.amazonaws.com/images/cersei-lannister-1554903396.jpg"
        )
    }
    "iron_throne.png" = @{
        desc = "Iron Throne"
        urls = @(
            "https://static.wikia.nocookie.net/gameofthrones/images/3/35/Iron_Throne_HBO.jpg",
            "https://upload.wikimedia.org/wikipedia/en/2/2f/Iron_Throne.jpg",
            "https://hbo-static-assets.s3.amazonaws.com/GOT/iron-throne.jpg"
        )
    }
    "dragons.png" = @{
        desc = "Daenerys Dragons"
        urls = @(
            "https://static.wikia.nocookie.net/gameofthrones/images/e/e0/Daenerys_Targaryen_with_dragon_Season_8.jpg",
            "https://upload.wikimedia.org/wikipedia/en/3/39/Daenerys_Targaryen_with_Dragon.jpg",
            "https://hips.hearstapps.com/hmg-prod.s3.amazonaws.com/images/daenerys-dragons-1554903299.jpg"
        )
    }
    "stark_wolf.png" = @{
        desc = "Stark Direwolf"
        urls = @(
            "https://static.wikia.nocookie.net/gameofthrones/images/2/2c/Direwolf_pup.jpg",
            "https://upload.wikimedia.org/wikipedia/en/a/a0/Direwolf_Game_of_Thrones.jpg",
            "https://hbo-static-assets.s3.amazonaws.com/GOT/direwolf.jpg"
        )
    }
    "night_king.png" = @{
        desc = "Night King"
        urls = @(
            "https://static.wikia.nocookie.net/gameofthrones/images/f/f5/Night_King_HBO.jpg",
            "https://upload.wikimedia.org/wikipedia/en/3/37/Night_King_Game_of_Thrones.jpg",
            "https://hips.hearstapps.com/hmg-prod.s3.amazonaws.com/images/night-king-1554903445.jpg"
        )
    }
    "winterfell.png" = @{
        desc = "Winterfell Castle"
        urls = @(
            "https://static.wikia.nocookie.net/gameofthrones/images/1/10/Winterfell_Season_8.jpg",
            "https://upload.wikimedia.org/wikipedia/en/4/47/Winterfell_Castle.jpg",
            "https://hbo-static-assets.s3.amazonaws.com/GOT/winterfell.jpg"
        )
    }
    "kings_landing.png" = @{
        desc = "King's Landing"
        urls = @(
            "https://static.wikia.nocookie.net/gameofthrones/images/d/dc/Kings_Landing_HBO.jpg",
            "https://upload.wikimedia.org/wikipedia/en/6/65/Kings_Landing_Game_of_Thrones.jpg",
            "https://hbo-static-assets.s3.amazonaws.com/GOT/kings-landing.jpg"
        )
    }
    "the_wall.png" = @{
        desc = "The Wall"
        urls = @(
            "https://static.wikia.nocookie.net/gameofthrones/images/a/a9/The_Wall_HBO.jpg",
            "https://upload.wikimedia.org/wikipedia/en/8/8c/The_Wall_Game_of_Thrones.jpg",
            "https://hbo-static-assets.s3.amazonaws.com/GOT/the-wall.jpg"
        )
    }
}

$successCount = 0
$failedCount = 0

foreach ($filename in $gotImages.Keys) {
    $imageInfo = $gotImages[$filename]
    
    if (Download-GOTImage $filename $imageInfo.urls $imageInfo.desc) {
        $successCount++
    } else {
        $failedCount++
    }
    
    Start-Sleep -Milliseconds 500  # Small delay between downloads
}

Write-Host "`n=== Download Summary ==="
Write-Host "Successfully downloaded: $successCount images"
Write-Host "Failed downloads: $failedCount images"
Write-Host "Images saved to: $gotDir"

# Verify downloaded images
$downloadedImages = Get-ChildItem "$gotDir\*.png" | Where-Object {$_.Length -gt 5000}
$smallImages = Get-ChildItem "$gotDir\*.png" | Where-Object {$_.Length -le 5000}

Write-Host "`nImage Verification:"
Write-Host "Large images (>5KB): $($downloadedImages.Count)"
Write-Host "Small/placeholder images (≤5KB): $($smallImages.Count)"

if ($downloadedImages.Count -gt 0) {
    Write-Host "`nSuccessfully downloaded:"
    $downloadedImages | ForEach-Object { Write-Host "  ✅ $($_.Name) - $([math]::Round($_.Length/1KB, 1))KB" }
}
