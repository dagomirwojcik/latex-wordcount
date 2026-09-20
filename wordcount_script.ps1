$content = Get-Content "main.tex" -Raw -Encoding UTF8

# Truncate content to exclude chapters 9 and beyond
$chapterMatches = [regex]::Matches($content, '\\chapter\{[^}]+\}')
if ($chapterMatches.Count > 8) {
    $startOfChapter9 = $chapterMatches[8].Index
    $content = $content.Substring(0, $startOfChapter9)
}

# Count figures and tables in the truncated content
$figureCount = ([regex]::Matches($content, '\\begin\{figure\}')).Count
$tableCount = ([regex]::Matches($content, '\\begin\{table\}')).Count

# Remove title page
$content = $content -replace '(?s)\\begin\{titlepage\}.*?\\end\{titlepage\}', ''

# Remove acknowledgements
$content = $content -replace '(?s)\\begin\{acknowledgementspage\}.*?\\end\{acknowledgementspage\}', ''

# Remove abstract
$content = $content -replace '(?s)\\begin\{abstractpage\}.*?\\end\{abstractpage\}', ''

# Remove glossary
$content = $content -replace '\\printglossary(\[[^\]]*\])?', ''

# Remove table of contents
$content = $content -replace '\\tableofcontents', ''

# Remove bibliography
$content = $content -replace '(?s)\\printbibliography.*', ''

# Remove headings
$content = $content -replace '\\(chapter|section|subsection)\{[^}]+\}', ''

# Remove citations
$content = $content -replace '\\cite\{[^}]+\}', ''

# Remove captions
$content = $content -replace '\\caption\{[^}]+\}', ''

# Remove labels
$content = $content -replace '\\label\{[^}]+\}', ''

# Remove figure and table environments
$content = $content -replace '(?s)\\begin\{figure\}.*?\\end\{figure\}', ''
$content = $content -replace '(?s)\\begin\{table\}.*?\\end\{table\}', ''

# Remove other environments
$content = $content -replace '(?s)\\begin\{tikzpicture\}.*?\\end\{tikzpicture\}', ''
$content = $content -replace '(?s)\\begin\{ganttchart\}.*?\\end\{ganttchart\}', ''

# Extract enumerate items
if ($content -match '(?s)\\begin\{enumerate\}.*?\\end\{enumerate\}') {
    $enumerateBlocks = [regex]::Matches($content, '(?s)\\begin\{enumerate\}.*?\\end\{enumerate\}')
    $enumerateText = ''
    foreach ($block in $enumerateBlocks) {
        $blockText = $block.Value
        $items = [regex]::Matches($blockText, '\\item\s+(.+?)(?=\\item|\\end\{enumerate\})', [System.Text.RegularExpressions.RegexOptions]::Singleline)
        foreach ($item in $items) {
            $enumerateText += $item.Groups[1].Value + ' '
        }
    }
    $content = $content -replace '(?s)\\begin\{enumerate\}.*?\\end\{enumerate\}', $enumerateText
}

# Remove LaTeX formatting commands but keep text
$content = $content -replace '\\(textbf|textit|emph)\{([^}]+)\}', '$2'
$content = $content -replace '\\(textsc|text|small|large|Large|LARGE|scriptsize|footnotesize)\{([^}]+)\}', '$2'

# Remove remaining LaTeX commands
$content = $content -replace '\\[a-zA-Z@]+(\[[^\]]*\])?(\{[^}]*\})*', ''
$content = $content -replace '(?s)\\begin\{[^}]+\}.*?\\end\{[^}]+\}', ''
$content = $content -replace '\\[a-zA-Z@]+', ''

# Remove LaTeX-specific commands
$content = $content -replace '\\newline', ' '
$content = $content -replace '\\newpage', ' '
$content = $content -replace '\\\\', ' '
$content = $content -replace '&', ' '

# Remove comments
$lines = $content -split "`n"
$cleanedLines = @()
foreach ($line in $lines) {
    if ($line -match '^\s*%') { continue }
    if ($line -match '([^\\])%') {
        $line = $line -replace '(?<!\\\\)%.*', ''
    }
    $cleanedLines += $line
}
$content = $cleanedLines -join "`n"

# Normalize whitespace
$content = $content -replace '\s+', ' '

# Extract words (must contain at least one letter)
$words = $content -split '\s+' | Where-Object { $_ -match '[a-zA-Z]' }
$wordCount = ($words | Where-Object { $_ -match '\b\w+\b' }).Count

# Count individual words more accurately
$wordCount = 0
$words | ForEach-Object {
    $word = $_
    # Extract word boundaries
    $wordMatches = [regex]::Matches($word, '\b\w+\b')
    foreach ($match in $wordMatches) {
        if ($match.Value -match '[a-zA-Z]') {
            $wordCount++
        }
    }
}

$totalCount = $wordCount + $figureCount + $tableCount

Write-Host "Regular words: $wordCount"
Write-Host "Figures: $figureCount"
Write-Host "Tables: $tableCount"
Write-Host "Total word count: $totalCount"

