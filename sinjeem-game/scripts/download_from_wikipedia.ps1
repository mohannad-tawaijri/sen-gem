# PowerShell script to download from more reliable sources
$gotDir = "C:\Users\Admin\Desktop\sen-gem\sinjeem-game\public\media\questions\got"

Write-Host "Downloading from Wikipedia and other reliable sources..."

# Function to download with different approach
function Get-ImageFromURL($filename, $url, $description) {
    $filepath = Join-Path $gotDir $filename
    
    # Skip if we already have a good image
    if (Test-Path $filepath) {
        $currentSize = (Get-Item $filepath).Length
        if ($currentSize -gt 10000) {
            Write-Host "SKIP $description - already have good image"
            return $true
        }
    }
    
    try {
        Write-Host "Downloading $description..."
        
        # Simple headers
        $headers = @{
            'User-Agent' = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0'
        }
        
        Invoke-WebRequest -Uri $url -OutFile $filepath -Headers $headers -TimeoutSec 15
        
        if (Test-Path $filepath) {
            $fileSize = (Get-Item $filepath).Length
            if ($fileSize -gt 3000) {
                Write-Host "SUCCESS: $filename ($([math]::Round($fileSize/1KB, 1))KB)"
                return $true
            } else {
                Remove-Item $filepath -Force
                Write-Host "FAILED: File too small"
            }
        }
    }
    catch {
        Write-Host "FAILED: $($_.Exception.Message)"
    }
    
    return $false
}

# Try Wikipedia and Wikimedia Commons (more reliable)
$images = @{
    "cersei.png" = @{
        desc = "Cersei Lannister"
        url = "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/Lena_Headey_2014_Comic_Con_%28cropped%29.jpg/800px-Lena_Headey_2014_Comic_Con_%28cropped%29.jpg"
    }
    "iron_throne.png" = @{
        desc = "Iron Throne"
        url = "https://upload.wikimedia.org/wikipedia/en/2/2f/Iron_Throne.jpg"
    }
    "dragons.png" = @{
        desc = "Dragon"
        url = "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/Dragon_%28Dungeons_%26_Dragons%29.jpg/800px-Dragon_%28Dungeons_%26_Dragons%29.jpg"
    }
    "night_king.png" = @{
        desc = "Night King"
        url = "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/Skull_and_crossbones.svg/800px-Skull_and_crossbones.svg.png"
    }
    "stark_wolf.png" = @{
        desc = "Wolf"
        url = "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Kolm%C3%A5rden_Wolf.jpg/800px-Kolm%C3%A5rden_Wolf.jpg"
    }
    "lannister_lion.png" = @{
        desc = "Lion"
        url = "https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Lion_waiting_in_Namibia.jpg/800px-Lion_waiting_in_Namibia.jpg"
    }
    "the_wall.png" = @{
        desc = "Great Wall"
        url = "https://upload.wikimedia.org/wikipedia/commons/thumb/2/23/The_Great_Wall_of_China_at_Jinshanling-edit.jpg/800px-The_Great_Wall_of_China_at_Jinshanling-edit.jpg"
    }
    "kings_landing.png" = @{
        desc = "Medieval Castle"
        url = "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f8/Neuschwanstein_Castle_LOC_print.jpg/800px-Neuschwanstein_Castle_LOC_print.jpg"
    }
}

$successCount = 0
$failedCount = 0

foreach ($filename in $images.Keys) {
    $imageInfo = $images[$filename]
    
    if (Get-ImageFromURL $filename $imageInfo.url $imageInfo.desc) {
        $successCount++
    } else {
        $failedCount++
    }
    
    Start-Sleep -Milliseconds 1000
}

Write-Host "`n=== Summary ==="
Write-Host "SUCCESS: $successCount images"
Write-Host "FAILED: $failedCount images"

# Final check
Write-Host "`nFinal image count:"
$allImages = Get-ChildItem "$gotDir\*.png"
$realImages = $allImages | Where-Object {$_.Length -gt 10000}

Write-Host "Real images (>10KB): $($realImages.Count)"
if ($realImages.Count -gt 0) {
    $realImages | Sort-Object Length -Descending | ForEach-Object { 
        Write-Host "  $($_.Name) - $([math]::Round($_.Length/1KB, 1))KB" 
    }
}
