
$source = "c:\Antigravity\daveweinstein1\old.resume.html"
$dest = "c:\Antigravity\daveweinstein1\index.html"
$match = Get-Content $source | Select-String 'src="data:image/png;base64,' | Select-Object -First 1

if ($match) {
    $tagLine = $match.Line.Trim()
    # Add class if missing
    if ($tagLine -notmatch 'class="profile-photo"') {
        $tagLine = $tagLine.Replace('>', ' class="profile-photo">')
    }
    
    $content = Get-Content $dest
    $newContent = @()
    $inserted = $false
    
    foreach ($line in $content) {
        if ($line -match '<div class="name">Dave Weinstein</div>' -and -not $inserted) {
            $newContent += "            $tagLine"
            $newContent += $line
            $inserted = $true
        } else {
            $newContent += $line
        }
    }
    
    $newContent | Set-Content $dest -Encoding UTF8
    Write-Host "Image successfully transferred."
} else {
    Write-Host "Error: SOURCE IMAGE TAG NOT FOUND"
}
