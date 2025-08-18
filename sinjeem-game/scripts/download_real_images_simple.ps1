# PowerShell script to download more real GOT images
$gotDir = "C:\Users\Admin\Desktop\sen-gem\sinjeem-game\public\media\questions\got"

Write-Host "Downloading more real Game of Thrones images..."

# Function to download image with better error handling
function Get-RealImage($filename, $urls, $description) {
    $filepath = Join-Path $gotDir $filename
    
    # Skip if we already have a good image (>10KB)
    if (Test-Path $filepath) {
        $currentSize = (Get-Item $filepath).Length
        if ($currentSize -gt 10000) {
            Write-Host "Skip $description - already have good image ($([math]::Round($currentSize/1KB, 1))KB)"
            return $true
        }
    }
    
    foreach ($url in $urls) {
        try {
            Write-Host "Downloading $description from $url"
            
            # Better headers to avoid blocking
            $headers = @{
                'User-Agent' = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
                'Accept' = 'image/webp,image/apng,image/*,*/*;q=0.8'
            }
            
            Invoke-WebRequest -Uri $url -OutFile $filepath -Headers $headers -TimeoutSec 30
            
            # Check if file was downloaded and is valid
            if (Test-Path $filepath) {
                $fileSize = (Get-Item $filepath).Length
                if ($fileSize -gt 5000) {
                    Write-Host "SUCCESS: Downloaded $filename ($([math]::Round($fileSize/1KB, 1))KB)"
                    return $true
                } else {
                    Write-Host "File too small - may be error page"
                    Remove-Item $filepath -Force
                }
            }
        }
        catch {
            Write-Host "FAILED from $url : $($_.Exception.Message)"
        }
        
        Start-Sleep -Milliseconds 1000  # Wait between attempts
    }
    
    Write-Host "FAILED to download $filename from all sources"
    return $false
}

# Better image sources
$gotImages = @{
    "cersei.png" = @{
        desc = "Cersei Lannister"
        urls = @(
            "https://m.media-amazon.com/images/M/MV5BMTgyNzE5OTkzNV5BMl5BanBnXkFtZTgwNzM4ODI1MjE@._V1_UX214_CR0,0,214,317_AL_.jpg",
            "https://upload.wikimedia.org/wikipedia/en/2/22/Cersei_Lannister-Lena_Headey.jpg"
        )
    }
    "dragons.png" = @{
        desc = "Drogon Dragon"
        urls = @(
            "https://assets1.ignimgs.com/2019/04/29/drogon-1556510054162_1280w.jpg",
            "https://cdn.mos.cms.futurecdn.net/SdpWEvGCKp5XdEEDRMfHrG.jpg"
        )
    }
    "night_king.png" = @{
        desc = "Night King"
        urls = @(
            "https://hips.hearstapps.com/digitalspyuk.cdnds.net/18/15/1523263369-night-king-game-of-thrones.jpg",
            "https://cdn.mos.cms.futurecdn.net/pnXJnJrM2LfCq6FRJhqEsD.jpg"
        )
    }
    "iron_throne.png" = @{
        desc = "Iron Throne"
        urls = @(
            "https://cdn.mos.cms.futurecdn.net/SgqCKQLfgKFNq3cJd5KFc6.jpg",
            "https://static.independent.co.uk/2022/08/12/11/newFile-15.jpg"
        )
    }
    "winterfell.png" = @{
        desc = "Winterfell Castle"
        urls = @(
            "https://cdn.mos.cms.futurecdn.net/DzMD8pvbYa4j4x4Tj7vJjN.jpg",
            "https://static.tvmaze.com/uploads/images/original_untouched/147/369463.jpg"
        )
    }
    "the_wall.png" = @{
        desc = "The Wall"
        urls = @(
            "https://cdn.mos.cms.futurecdn.net/84U8y6kvPH7c8QSzAFnF46.jpg",
            "https://static.independent.co.uk/2022/06/15/09/Game-of-Thrones-Wall.jpg"
        )
    }
    "kings_landing.png" = @{
        desc = "Kings Landing"
        urls = @(
            "https://cdn.mos.cms.futurecdn.net/WbqrMbwPDWBXnbNUGg5M3K.jpg",
            "https://static.independent.co.uk/2022/06/15/09/Game-of-Thrones-Kings-Landing.jpg"
        )
    }
    "stark_wolf.png" = @{
        desc = "Stark Direwolf"
        urls = @(
            "https://cdn.mos.cms.futurecdn.net/JNwQGxh8H8yKckLLfnZr9F.jpg",
            "https://static.independent.co.uk/2022/06/15/09/Game-of-Thrones-Ghost.jpg"
        )
    }
}

$successCount = 0
$failedCount = 0
$skippedCount = 0

Write-Host "Starting download of $($gotImages.Keys.Count) images..."

foreach ($filename in $gotImages.Keys) {
    $imageInfo = $gotImages[$filename]
    
    $result = Get-RealImage $filename $imageInfo.urls $imageInfo.desc
    if ($result -eq $true) {
        $currentSize = (Get-Item (Join-Path $gotDir $filename)).Length
        if ($currentSize -gt 10000) {
            $successCount++
        } else {
            $skippedCount++
        }
    } else {
        $failedCount++
    }
    
    Start-Sleep -Milliseconds 500
}

Write-Host "`n=== Download Summary ==="
Write-Host "SUCCESS: $successCount images"
Write-Host "SKIPPED: $skippedCount images" 
Write-Host "FAILED: $failedCount images"
Write-Host "Directory: $gotDir"

# Verify all images
Write-Host "`nChecking all images..."
$allImages = Get-ChildItem "$gotDir\*.png"
$realImages = $allImages | Where-Object {$_.Length -gt 10000}
$placeholderImages = $allImages | Where-Object {$_.Length -le 10000}

Write-Host "Real images (>10KB): $($realImages.Count)"
Write-Host "Placeholder images (<10KB): $($placeholderImages.Count)"

if ($realImages.Count -gt 0) {
    Write-Host "`nReal images available:"
    $realImages | Sort-Object Length -Descending | ForEach-Object { 
        Write-Host "  $($_.Name) - $([math]::Round($_.Length/1KB, 1))KB" 
    }
}
