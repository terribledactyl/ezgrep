# PowerShell script to search for multiple keywords within files with options for recursion, case sensitivity, and whole word match

# Function to prompt user input
function Get-UserInput {
    param (
        [string]$Prompt
    )
    Write-Host $Prompt -ForegroundColor Cyan
    return Read-Host
}

# Function to prompt for a yes/no response
function Get-YesNoInput {
    param (
        [string]$Prompt
    )
    while ($true) {
        $response = Get-UserInput $Prompt
        if ($response -eq 'Y' -or $response -eq 'N') {
            return $response
        }
        Write-Host "Invalid input. Please enter 'Y' or 'N'." -ForegroundColor Red
    }
}

# Get user inputs
$directory = Get-UserInput "Enter the directory to search in:"
$keywords = (Get-UserInput "Enter the keywords to search for, separated by commas:") -split ',' | ForEach-Object { $_.Trim() }
$recursionOption = Get-YesNoInput "Do you want to search recursively through subdirectories? (Y/N):"
$caseSensitiveOption = Get-YesNoInput "Do you want the search to be case-sensitive? (Y/N):"
$wholeWordOption = Get-YesNoInput "Do you want to match whole words only? (Y/N):"

# Check if the directory exists
if (-Not (Test-Path $directory)) {
    Write-Host "The directory '$directory' does not exist." -ForegroundColor Red
    exit
}

# Determine if recursion is needed
$searchOption = if ($recursionOption -eq 'Y') { '-Recurse' } else { '-File' }

# Determine if case sensitivity is needed
$caseSensitive = if ($caseSensitiveOption -eq 'Y') { $true } else { $false }

# Determine if whole word match is needed
$wholeWord = if ($wholeWordOption -eq 'Y') { $true } else { $false }

# Search for files and keywords
Write-Host "Searching for keywords '$($keywords -join ', ')' in directory '$directory'..." -ForegroundColor Green

# Get files based on the recursion option
$files = Get-ChildItem -Path $directory $searchOption

# Initialize an empty array to hold results
$results = @()

foreach ($file in $files) {
    try {
        # Read the file content
        $content = Get-Content -Path $file.FullName -Raw -ErrorAction Stop

        foreach ($keyword in $keywords) {
            # Prepare the search pattern
            $escapedKeyword = [regex]::Escape($keyword)
            $searchPattern = if ($caseSensitive) { $escapedKeyword } else { "(?i)$escapedKeyword" }
            if ($wholeWord) {
                $searchPattern = "\b$searchPattern\b"
            }

            # Check if the keyword is in the content
            if ($content -match $searchPattern) {
                $matches = $content | Select-String -Pattern $keyword -CaseSensitive:$caseSensitive
                foreach ($match in $matches) {
                    $results += [PSCustomObject]@{
                        FileName = $file.FullName
                        LineNumber = $match.LineNumber
                        LineText = $match.Line
                        Keyword = $keyword
                    }
                }
            }
        }
    } catch {
        Write-Host "Could not read file '$($file.FullName)': $_" -ForegroundColor Yellow
    }
}

# Display results
if ($results.Count -gt 0) {
    Write-Host "Search complete. Found matches for the following keywords:" -ForegroundColor Green
    $results | Format-Table -AutoSize
} else {
    Write-Host "No matches found for keywords '$($keywords -join ', ')'." -ForegroundColor Yellow
}
