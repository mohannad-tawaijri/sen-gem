# PowerShell script to download more real GOT images like Tyrion
$gotDir = "C:\Users\Admin\Desktop\sen-gem\sinjeem-game\public\media\questions\got"

Write-Host "تنزيل المزيد من الصور الحقيقية لصراع العروش..."

# Function to download image with better error handling
function Get-RealGOTImage($filename, $urls, $description) {
    $filepath = Join-Path $gotDir $filename
    
    # Skip if we already have a good image (>10KB)
    if (Test-Path $filepath) {
        $currentSize = (Get-Item $filepath).Length
        if ($currentSize -gt 10000) {
            Write-Host "⏭️ تخطي $description - الصورة موجودة بالفعل ($([math]::Round($currentSize/1KB, 1))KB)"
            return $true
        }
    }
    
    foreach ($url in $urls) {
        try {
            Write-Host "📥 تنزيل $description من $url"
            
            # Better headers to avoid blocking
            $headers = @{
                'User-Agent' = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
                'Accept' = 'image/webp,image/apng,image/*,*/*;q=0.8'
                'Accept-Language' = 'en-US,en;q=0.9'
                'Accept-Encoding' = 'gzip, deflate, br'
                'Connection' = 'keep-alive'
                'Upgrade-Insecure-Requests' = '1'
            }
            
            Invoke-WebRequest -Uri $url -OutFile $filepath -Headers $headers -TimeoutSec 30
            
            # Check if file was downloaded and is valid
            if (Test-Path $filepath) {
                $fileSize = (Get-Item $filepath).Length
                if ($fileSize -gt 5000) {
                    Write-Host "✅ نجح تنزيل $filename ($([math]::Round($fileSize/1KB, 1))KB)"
                    return $true
                } else {
                    Write-Host "⚠️ الملف صغير جداً - قد يكون خطأ"
                    Remove-Item $filepath -Force
                }
            }
        }
        catch {
            Write-Host "❌ فشل من $url : $($_.Exception.Message)"
        }
        
        Start-Sleep -Milliseconds 1000  # Wait between attempts
    }
    
    Write-Host "⚠️ فشل في تنزيل $filename من جميع المصادر"
    return $false
}

# Better image sources - using direct GitHub, IMDB, and other reliable sources
$gotImages = @{
    "cersei.png" = @{
        desc = "سيرسي لانيستر"
        urls = @(
            "https://m.media-amazon.com/images/M/MV5BMTgyNzE5OTkzNV5BMl5BanBnXkFtZTgwNzM4ODI1MjE@._V1_UX214_CR0,0,214,317_AL_.jpg",
            "https://static.tvmaze.com/uploads/images/medium_portrait/1/4338.jpg",
            "https://images.amcnetworks.com/amc.com/wp-content/uploads/2016/02/GOT-Cersei-800x600.jpg"
        )
    }
    "dragons.png" = @{
        desc = "دراجون التنين"
        urls = @(
            "https://static.wikia.nocookie.net/gameofthrones/images/4/45/Drogon_8x06.jpg/revision/latest?cb=20190520174026",
            "https://assets.gameofthrones.com/drupal/sites/default/files/styles/full_1920/public/2019-04/drogon-daenerys-8x04-helen-sloan-hbo_0.jpg",
            "https://images.squarespace-cdn.com/content/v1/52fc05c9e4b08fc45bd99090/1556546309013-8P9SZ1XZQV9K1ZAZBKZV/drogon-1.jpg"
        )
    }
    "night_king.png" = @{
        desc = "ملك الليل"
        urls = @(
            "https://hips.hearstapps.com/digitalspyuk.cdnds.net/18/15/1523263369-night-king-game-of-thrones.jpg",
            "https://assets.gameofthrones.com/drupal/sites/default/files/styles/full_1920/public/2019-04/night-king-8x03-helen-sloan-hbo.jpg",
            "https://cdn.vox-cdn.com/thumbor/ZTtJqz7k2fDPUPMNKmtMQvGjBks=/0x0:1920x1080/1200x675/filters:focal(807x387:1113x693)/cdn.vox-cdn.com/uploads/chorus_image/image/63788598/Game_of_Thrones_Night_King.0.jpg"
        )
    }
    "iron_throne.png" = @{
        desc = "العرش الحديدي"
        urls = @(
            "https://assets.gameofthrones.com/drupal/sites/default/files/styles/full_1920/public/2019-05/iron-throne-8x06-helen-sloan-hbo.jpg",
            "https://cdn.vox-cdn.com/thumbor/5Qp8-HJYCaH4c8XZiEG39h5C_hE=/0x0:1920x1080/1200x675/filters:focal(807x387:1113x693)/cdn.vox-cdn.com/uploads/chorus_image/image/63794531/got_iron_throne.0.jpg",
            "https://static.independent.co.uk/2022/08/12/11/newFile-15.jpg"
        )
    }
    "winterfell.png" = @{
        desc = "وينترفيل"
        urls = @(
            "https://assets.gameofthrones.com/drupal/sites/default/files/styles/full_1920/public/2019-04/winterfell-8x01-helen-sloan-hbo.jpg",
            "https://cdn.vox-cdn.com/thumbor/JGwNKWxhP0PfXLJ4cF6V5Qp1cog=/0x0:1920x1080/1200x675/filters:focal(807x387:1113x693)/cdn.vox-cdn.com/uploads/chorus_image/image/63755134/winterfell_got.0.jpg",
            "https://static.tvmaze.com/uploads/images/original_untouched/147/369463.jpg"
        )
    }
    "the_wall.png" = @{
        desc = "الجدار"
        urls = @(
            "https://assets.gameofthrones.com/drupal/sites/default/files/styles/full_1920/public/2017-08/the-wall-7x07-helen-sloan-hbo.jpg",
            "https://cdn.vox-cdn.com/thumbor/YjQ_x3qUjKn7L9vB3k9B0Zj8tpU=/0x0:1920x1080/1200x675/filters:focal(807x387:1113x693)/cdn.vox-cdn.com/uploads/chorus_image/image/55972229/the_wall_game_of_thrones.0.jpg",
            "https://static.independent.co.uk/2022/06/15/09/Game-of-Thrones-Wall.jpg"
        )
    }
    "kings_landing.png" = @{
        desc = "الهبوط الملكي"
        urls = @(
            "https://assets.gameofthrones.com/drupal/sites/default/files/styles/full_1920/public/2019-05/kings-landing-8x05-helen-sloan-hbo.jpg",
            "https://cdn.vox-cdn.com/thumbor/J9h8g7jHjT3qSBOY9lJ8y5Bz0_g=/0x0:1920x1080/1200x675/filters:focal(807x387:1113x693)/cdn.vox-cdn.com/uploads/chorus_image/image/63771046/kings_landing_destruction.0.jpg",
            "https://static.wikia.nocookie.net/gameofthrones/images/6/67/King%27s_Landing_7x07.png"
        )
    }
    "stark_wolf.png" = @{
        desc = "ذئب ستارك"
        urls = @(
            "https://assets.gameofthrones.com/drupal/sites/default/files/styles/full_1920/public/2017-08/ghost-7x06-helen-sloan-hbo.jpg",
            "https://cdn.vox-cdn.com/thumbor/v4P8n8rRnGqv0Y9r4Zv5UX8y1uI=/0x0:1920x1080/1200x675/filters:focal(807x387:1113x693)/cdn.vox-cdn.com/uploads/chorus_image/image/54986891/direwolf_pup.0.jpg",
            "https://static.wikia.nocookie.net/gameofthrones/images/4/4b/Ghost_Season_8.png"
        )
    }
    "lannister_lion.png" = @{
        desc = "أسد لانيستر"
        urls = @(
            "https://awoiaf.westeros.org/images/thumb/2/2b/House_Lannister.svg/545px-House_Lannister.svg.png",
            "https://static.wikia.nocookie.net/gameofthrones/images/8/8a/House-Lannister-heraldry.jpg",
            "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/f4b0f896-c03c-49c4-a5a1-75ad5b2d7b15/dcgqtog-7e8b6b4a-8f92-42f1-8e9e-6b8f9c1d6e9a.png"
        )
    }
    "baratheon.png" = @{
        desc = "شعار باراثيون"
        urls = @(
            "https://awoiaf.westeros.org/images/thumb/4/4d/House_Baratheon.svg/545px-House_Baratheon.svg.png",
            "https://static.wikia.nocookie.net/gameofthrones/images/f/fd/House-Baratheon-heraldry.jpg",
            "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/f4b0f896-c03c-49c4-a5a1-75ad5b2d7b15/dcgqtog-8a9c6b4a-9f82-42f1-8e9e-6b8f9c1d6e9a.png"
        )
    }
}

$successCount = 0
$failedCount = 0
$skippedCount = 0

Write-Host "بدء تنزيل $(($gotImages.Keys).Count) صورة..."

foreach ($filename in $gotImages.Keys) {
    $imageInfo = $gotImages[$filename]
    
    $result = Get-RealGOTImage $filename $imageInfo.urls $imageInfo.desc
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
    
    Start-Sleep -Milliseconds 500  # Small delay between downloads
}

Write-Host "`n=== ملخص التنزيل ==="
Write-Host "✅ نجح التنزيل: $successCount صور"
Write-Host "⏭️ تم تخطيها (موجودة): $skippedCount صور" 
Write-Host "❌ فشل التنزيل: $failedCount صور"
Write-Host "📁 مجلد الصور: $gotDir"

# Verify all images
Write-Host "`nفحص جميع الصور..."
$allImages = Get-ChildItem "$gotDir\*.png"
$realImages = $allImages | Where-Object {$_.Length -gt 10000}
$placeholderImages = $allImages | Where-Object {$_.Length -le 10000}

Write-Host "🖼️ صور حقيقية (>10KB): $($realImages.Count)"
Write-Host "🎨 صور ملونة (<10KB): $($placeholderImages.Count)"

if ($realImages.Count -gt 0) {
    Write-Host "`n📸 الصور الحقيقية المتوفرة:"
    $realImages | Sort-Object Length -Descending | ForEach-Object { 
        Write-Host "  ✅ $($_.Name) - $([math]::Round($_.Length/1KB, 1))KB" 
    }
}
