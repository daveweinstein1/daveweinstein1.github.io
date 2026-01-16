
$htmlPath = "c:\Antigravity\daveweinstein1\index.html"
$content = Get-Content $htmlPath -Raw -Encoding UTF8

# 1. Define the missing CSS and the Adjusted Header CSS
$cssCorrection = @"
        .header {
            border-bottom: 1px solid #e9ecef;
            padding: 60px 50px 45px 50px;
            background: white;
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
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
            margin-top: 5px;
            margin-right: 20px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            flex-shrink: 0;
        }

        .tagline {
            font-size: 1.05em;
            color: #6c757d;
            margin-bottom: 12px;
        }

        .contact {
            font-size: 0.9em;
            color: #6c757d;
        }

        .contact a {
            color: #495057;
            text-decoration: none;
        }

        .contact a:hover {
            text-decoration: underline;
        }

        .content {
            padding: 45px 50px 60px 50px;
        }

        .prose {
            margin-bottom: 28px;
            color: #495057;
            font-size: 1.02em;
        }

        .prose:last-child {
            margin-bottom: 0;
        }

        .section-break {
            height: 32px;
        }

        .footer {
            margin-top: 40px;
            padding-top: 28px;
            border-top: 1px solid #e9ecef;
            font-size: 0.92em;
            color: #6c757d;
        }
"@

# 2. Replace the broken CSS block
# The broken block starts at .header and ends at .profile-photo { ... }
# We will match from .header down to the closing brace of .profile-photo
$regex = '(?ms)\s*\.header \{.*\}\s*\.header-text \{.*\}\s*\.name \{.*\}\s*\.profile-photo \{.*?\}'

# Check if we can match it.
if ($content -match $regex) {
    $content = $content -replace $regex, $cssCorrection
    Set-Content -Path $htmlPath -Value $content -Encoding UTF8
    Write-Host "CSS restored and layout adjusted."
} else {
    Write-Host "Error: Could not match the broken CSS block for replacement."
    # Fallback: Just insert it into the style tag if regex fails (though it shouldn't)
}
