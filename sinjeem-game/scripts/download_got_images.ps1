# PowerShell script to download Game of Thrones images from the internet
$gotDir = "C:\Users\Admin\Desktop\sen-gem\sinjeem-game\public\media\questions\got"

Write-Host "Starting to download Game of Thrones images..."

# Create directory if it doesn't exist
if (!(Test-Path $gotDir)) {
    New-Item -ItemType Directory -Path $gotDir -Force
}

# Function to download image with retry
function Download-Image($url, $filename) {
    $filepath = Join-Path $gotDir $filename
    try {
        Write-Host "Downloading $filename..."
        Invoke-WebRequest -Uri $url -OutFile $filepath -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
        if ((Get-Item $filepath).Length -gt 1000) {
            Write-Host "Successfully downloaded $filename"
            return $true
        } else {
            Write-Host "Downloaded file too small, removing: $filename"
            Remove-Item $filepath -ErrorAction SilentlyContinue
            return $false
        }
    } catch {
        Write-Host "Failed to download $filename : $($_.Exception.Message)"
        return $false
    }
}

# Define image URLs for Game of Thrones content
$imageUrls = @{
    "baratheon.png" = "https://awoiaf.westeros.org/images/1/1b/House_Baratheon.svg"
    "iron_throne.png" = "https://static.wikia.nocookie.net/gameofthrones/images/8/82/Iron_Throne_HBO.jpg"
    "ned_stark.png" = "https://static.wikia.nocookie.net/gameofthrones/images/d/d6/Eddard_Stark_infobox_new.jpg"
    "dragons.png" = "https://static.wikia.nocookie.net/gameofthrones/images/e/e0/Drogon_Rhaegal_Viserion_Tyrion.jpg"
    "kings_landing.png" = "https://static.wikia.nocookie.net/gameofthrones/images/f/f4/King%27s_Landing_overview.jpg"
    "stark_wolf.png" = "https://awoiaf.westeros.org/images/7/78/House_Stark.svg"
    "winter_coming.png" = "https://static.wikia.nocookie.net/gameofthrones/images/3/3a/Winter_is_Coming.jpg"
    "cersei.png" = "https://static.wikia.nocookie.net/gameofthrones/images/8/8a/CerseiLannister.jpg"
    "the_hound.png" = "https://static.wikia.nocookie.net/gameofthrones/images/b/be/Sandor_Clegane.jpg"
    "longclaw.png" = "https://static.wikia.nocookie.net/gameofthrones/images/4/4c/Longclaw.jpg"
    "lannister_lion.png" = "https://awoiaf.westeros.org/images/8/8a/House_Lannister.svg"
    "the_wall.png" = "https://static.wikia.nocookie.net/gameofthrones/images/1/1c/The_Wall.jpg"
    "tyrion.png" = "https://static.wikia.nocookie.net/gameofthrones/images/5/58/Tyrion_main_s7_e6.jpg"
    "faceless_men.png" = "https://static.wikia.nocookie.net/gameofthrones/images/9/9a/Faceless_Man.jpg"
    "pentos.png" = "https://static.wikia.nocookie.net/gameofthrones/images/c/c4/Pentos.jpg"
    "many_faced_god.png" = "https://static.wikia.nocookie.net/gameofthrones/images/6/6c/Many-Faced_God_statue.jpg"
    "tyrell_rose.png" = "https://awoiaf.westeros.org/images/c/cc/House_Tyrell.svg"
    "night_king.png" = "https://static.wikia.nocookie.net/gameofthrones/images/f/f1/Night_King_HBO.jpg"
    "poison.png" = "https://static.wikia.nocookie.net/gameofthrones/images/8/8f/Poison.jpg"
    "ice_sword.png" = "https://static.wikia.nocookie.net/gameofthrones/images/2/2b/Ice_sword.jpg"
    "winterfell.png" = "https://static.wikia.nocookie.net/gameofthrones/images/6/60/Winterfell.jpg"
}

# Alternative URLs using placeholder service with Game of Thrones styling
$placeholderUrls = @{
    "baratheon.png" = "https://via.placeholder.com/400x300/FFD700/000000?text=Baratheon+Stag"
    "iron_throne.png" = "https://via.placeholder.com/400x300/2F2F2F/C0C0C0?text=Iron+Throne"
    "ned_stark.png" = "https://via.placeholder.com/400x300/8B4513/FFFFFF?text=Ned+Stark"
    "dragons.png" = "https://via.placeholder.com/400x300/DC143C/FFD700?text=Three+Dragons"
    "kings_landing.png" = "https://via.placeholder.com/400x300/DAA520/8B0000?text=Kings+Landing"
    "stark_wolf.png" = "https://via.placeholder.com/400x300/696969/FFFFFF?text=Stark+Direwolf"
    "winter_coming.png" = "https://via.placeholder.com/400x300/4682B4/FFFFFF?text=Winter+is+Coming"
    "cersei.png" = "https://via.placeholder.com/400x300/FFD700/8B0000?text=Cersei+Lannister"
    "the_hound.png" = "https://via.placeholder.com/400x300/2F4F4F/FFFFFF?text=The+Hound"
    "longclaw.png" = "https://via.placeholder.com/400x300/C0C0C0/000000?text=Longclaw+Sword"
    "lannister_lion.png" = "https://via.placeholder.com/400x300/FFD700/8B0000?text=Lannister+Lion"
    "the_wall.png" = "https://via.placeholder.com/400x300/F0F8FF/4682B4?text=The+Wall"
    "tyrion.png" = "https://via.placeholder.com/400x300/FFD700/8B0000?text=Tyrion+Lannister"
    "faceless_men.png" = "https://via.placeholder.com/400x300/2F2F2F/FFFFFF?text=Faceless+Men"
    "pentos.png" = "https://via.placeholder.com/400x300/DDA0DD/8B008B?text=Pentos"
    "many_faced_god.png" = "https://via.placeholder.com/400x300/000000/FFFFFF?text=Many+Faced+God"
    "tyrell_rose.png" = "https://via.placeholder.com/400x300/32CD32/FFFFFF?text=Tyrell+Rose"
    "night_king.png" = "https://via.placeholder.com/400x300/4169E1/E6E6FA?text=Night+King"
    "poison.png" = "https://via.placeholder.com/400x300/8B008B/FFFFFF?text=Poison"
    "ice_sword.png" = "https://via.placeholder.com/400x300/4682B4/FFFFFF?text=Ice+Sword"
    "winterfell.png" = "https://via.placeholder.com/400x300/708090/FFFFFF?text=Winterfell"
}

$successCount = 0
$failedCount = 0

# Try to download from official sources first, fallback to placeholders
foreach ($filename in $imageUrls.Keys) {
    $success = $false
    
    # Try official URL first
    if ($imageUrls[$filename]) {
        $success = Download-Image $imageUrls[$filename] $filename
    }
    
    # If failed, try placeholder
    if (-not $success -and $placeholderUrls[$filename]) {
        Write-Host "Trying placeholder for $filename..."
        $success = Download-Image $placeholderUrls[$filename] $filename
    }
    
    if ($success) {
        $successCount++
    } else {
        $failedCount++
    }
    
    Start-Sleep -Milliseconds 500  # Be nice to servers
}

# Download remaining images that weren't in the main list
$remainingImages = @(
    "essos_map.png", "rhllorr.png", "unsullied.png", "iron_bank.png", "dothraki_horse.png",
    "valyrian_steel.png", "old_valyria.png", "oathkeeper.png", "white_book.png", 
    "roberts_rebellion.png", "whispering_woods.png", "targaryen_tree.png", "azor_ahai.png",
    "aegon_conqueror.png", "maester_aemon.png", "riverrun.png", "balerion.png", 
    "iron_islands.png", "drowned_god.png", "lys.png", "great_chain.png"
)

foreach ($filename in $remainingImages) {
    $placeholderText = ($filename -replace "\.png$", "") -replace "_", "+"
    $url = "https://via.placeholder.com/400x300/8B4513/FFFFFF?text=$placeholderText"
    
    if (Download-Image $url $filename) {
        $successCount++
    } else {
        $failedCount++
    }
    
    Start-Sleep -Milliseconds 300
}

Write-Host "`n=== Download Summary ==="
Write-Host "Successfully downloaded: $successCount images"
Write-Host "Failed downloads: $failedCount images"
Write-Host "Images saved to: $gotDir"

# Verify all images exist and have content
$finalImageCount = (Get-ChildItem $gotDir -Name "*.png" | Where-Object { (Get-Item (Join-Path $gotDir $_)).Length -gt 1000 }).Count
Write-Host "Valid images ready: $finalImageCount"
