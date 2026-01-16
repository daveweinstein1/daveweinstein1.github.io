
$htmlPath = "c:\Antigravity\daveweinstein1\index.html"
$content = Get-Content $htmlPath -Raw -Encoding UTF8

# 1. Fix the character encoding artifact
$content = $content -replace "Â·", "&middot;"

# 2. Extract the Image Tag (safely finding the line with the class)
$lines = $content -split "`r`n"
$imgLine = $lines | Where-Object { $_ -match 'class="profile-photo"' } | Select-Object -First 1

if (-not $imgLine) {
    Write-Host "Error: Could not locate profile photo line."
    exit 1
}

# 3. Construct the new HTML structure for the header
# We need to replace the content inside <div class="header">...</div>
# Pattern: <div class="header">\s*<img...>\s*<div class="name">...</div>...<div class="contact">...</div>\s*</div>

# Using regex to grab the block is tricky with the large base64 line, 
# so let's identify the range of lines to replace.

$startHeader = $lines | Select-String -Pattern '<div class="header">' -SimpleMatch | Select-Object -First 1
$endHeader = $lines | Select-String -Pattern '<div class="content">' -SimpleMatch | Select-Object -First 1 # The header ends before content starts

if ($startHeader -and $endHeader) {
    $startIdx = $startHeader.LineNumber - 1
    # We find the closing div of the header. It's the one before <div class="content"> minus empty lines usually.
    # Actually, looking at the file structure:
    # 118: <div class="header">
    # ...
    # 125: </div>
    # 127: <div class="content">
    
    # Let's rebuild the specific lines we know are there based on previous `view_file`.
    # We know the specific tags.
    
    $nameLine = $lines | Where-Object { $_ -match '<div class="name">' } | Select-Object -First 1
    $tagLine = $lines | Where-Object { $_ -match '<div class="tagline">' } | Select-Object -First 1
    $contactLine = $lines | Where-Object { $_ -match '<div class="contact">' } # Spans multiple lines maybe? 
    # Viewing file showed contact div spans:
    # 122: <div class="contact">
    # 123:     Melbourne...
    # 124: </div>
    
    # Let's reconstruct the Header block entirely using the specific pieces we need.
    
    $newHeaderBlock = @"
        <div class="header">
            <div class="header-text">
                $nameLine
                $tagLine
                <div class="contact">
                    Melbourne, Australia &middot; <a href="https://www.linkedin.com/in/daveweinstein/">LinkedIn</a>
                </div>
            </div>
            $imgLine
        </div>
"@
    
    # Now we need to update the CSS.
    # We'll replace the existing CSS block for .header and .profile-photo and add .header-text
    
    $cssHeaderNew = @"
        .header {
            border-bottom: 1px solid #e9ecef;
            padding: 60px 50px 45px 50px;
            background: white;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header-text {
            flex: 1;
            padding-right: 30px;
        }

        .name {
            font-size: 2.4em;
            font-weight: 600;
            margin-bottom: 8px;
            color: #1a1a1a;
            letter-spacing: -0.3px;
        }

        .profile-photo {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            object-fit: cover;
            margin-bottom: 0;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            flex-shrink: 0;
        }
"@
    
    # Replace CSS: find the range from .header { to .tagline {
    # This is rough validation. A safer way is using specific regex replacement for the CSS parts.
    
    $content = $content -replace '(?ms)\.header \{.*?\}\s*\.name \{.*\}\s*\.profile-photo \{.*\}\s*', $cssHeaderNew
    
    # Replace HTML: 
    # Find the chunk from <div class="header"> to just before <div class="content">
    # and replace it with our new block.
    # Note: The original file has the img tag inside header.
    
    # Let's be very accurate with regex for the HTML body part
    $htmlBodyRegex = '(?s)<div class="header">.*?</div>\s*(?=<div class="content">)'
    $content = $content -replace $htmlBodyRegex, $newHeaderBlock
    
    # Add Media Query for mobile response
    # Look for existing @media (max-width: 768px) and replace it or append inside
    $mediaQueryNew = @"
        @media (max-width: 768px) {
            .header {
                flex-direction: column-reverse;
                text-align: center;
                padding: 40px 25px 35px 25px;
            }

             .header-text {
                padding-right: 0;
             }

            .content {
                padding: 35px 25px 45px 25px;
            }

            .name {
                font-size: 1.9em;
            }
            
            .profile-photo {
                margin-bottom: 20px;
            }
        }
"@
    $content = $content -replace '(?s)@media \(max-width: 768px\) \{.*?\}\s*(?=</style>)', $mediaQueryNew
    
    Set-Content -Path $htmlPath -Value $content -Encoding UTF8
    Write-Host "Layout updated successfully."
} else {
    Write-Host "Error: Could not find header/content boundaries."
}
