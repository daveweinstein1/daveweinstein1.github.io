
$imagePath = "C:/Users/dw/.gemini/antigravity/brain/87fab5cd-3670-47cd-b231-29f472a733b0/uploaded_image_1768214006491.jpg"
$htmlPath = "c:\Antigravity\daveweinstein1\index.html"

if (-not (Test-Path $imagePath)) {
    Write-Host "Error: Image not found"
    exit 1
}

$bytes = [System.IO.File]::ReadAllBytes($imagePath)
$b64 = [System.Convert]::ToBase64String($bytes)
$imgTag = '<img src="data:image/jpeg;base64,' + $b64 + '" alt="Dave Weinstein" class="profile-photo">'

$content = Get-Content $htmlPath
$newContent = @()
$replaced = $false

foreach ($line in $content) {
    if ($line -match '<img src="data:image' -and ($line -match 'class="profile-photo"' -or $line -match 'alt="Dave Weinstein"')) {
        $newContent += "            $imgTag"
        $replaced = $true
    } else {
        $newContent += $line
    }
}

if (-not $replaced) {
    # Fallback insertion
    $finalContent = @()
    foreach ($line in $newContent) {
        if ($line -match '<div class="name">Dave Weinstein</div>') {
            $finalContent += "            $imgTag"
            $finalContent += $line
        } else {
            $finalContent += $line
        }
    }
    $newContent = $finalContent
}

$newContent | Set-Content $htmlPath -Encoding UTF8
Write-Host "Successfully updated profile photo."
