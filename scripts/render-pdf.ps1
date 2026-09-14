<#
.SYNOPSIS
    Exports the rendered reveal.js deck to a PDF handout.

.DESCRIPTION
    reveal.js has no LaTeX path - the deck's layout, callout cards and green
    dividers are CSS, so the only export that looks like the talk is the one the
    browser itself prints. Opening the deck with ?print-pdf switches reveal into
    a one-slide-per-page layout; this script drives headless Chrome over that
    page and writes the result to docs/PhD-interview-presentation.pdf.

    Run it directly, or let `quarto render` run it through the post-render hook
    in _quarto.yml.

.PARAMETER Deck
    The rendered HTML deck. Defaults to docs/index.html.

.PARAMETER Output
    Destination PDF. Defaults to docs/PhD-interview-presentation.pdf.

.PARAMETER Notes
    Print the speaker notes underneath each slide - useful for rehearsal, not
    for the copy you hand out.

.EXAMPLE
    .\scripts\render-pdf.ps1
.EXAMPLE
    .\scripts\render-pdf.ps1 -Notes -Output docs/rehearsal-notes.pdf
#>
[CmdletBinding()]
param(
    [string] $Deck   = "docs/index.html",
    [string] $Output = "docs/PhD-interview-presentation.pdf",
    [switch] $Notes,

    # Export even when Quarto is only re-rendering part of the project
    [switch] $Force
)

$ErrorActionPreference = "Stop"

# Quarto runs this hook after every project render, a live preview included.
# Re-exporting the PDF on each save would spawn a browser every few seconds, so
# when Quarto is the caller the export is limited to a full `quarto render`.
# Run the script directly (or pass -Force) to export at any other time.
if (-not $Force -and $env:QUARTO_PROJECT_OUTPUT_DIR -and $env:QUARTO_PROJECT_RENDER_ALL -ne "1") {
    Write-Host "Skipping PDF export (partial render) - run scripts/render-pdf.ps1 for the PDF."
    return
}

# Paths are resolved against the project root, not the caller's location, so the
# script behaves the same from the repo root, from scripts/, or from Quarto.
$root = Split-Path -Parent $PSScriptRoot
# An absolute path is taken as given; a relative one hangs off the project root.
function Resolve-ProjectPath([string] $path) {
    if ([System.IO.Path]::IsPathRooted($path)) { return $path }
    return (Join-Path $root $path)
}

$deckPath = Resolve-ProjectPath $Deck
$outPath  = Resolve-ProjectPath $Output

if (-not (Test-Path $deckPath)) {
    throw "Deck not found: $deckPath`nRender the HTML first: quarto render"
}

# --- Locate a Chromium browser -------------------------------------------
# $env:CHROME wins, so an unusual install can be pointed at without editing this.
$candidates = @(
    $env:CHROME,
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe",
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { $_ -and (Test-Path $_) }

if (-not $candidates) {
    throw "No Chrome or Edge found. Install one, or set `$env:CHROME to its .exe."
}
$browser = $candidates[0]

# --- Build the file:// URL -----------------------------------------------
# ?print-pdf is what puts reveal into its paged layout; showNotes adds the
# speaker notes below each slide.
$url = "file:///" + (Resolve-Path $deckPath).Path.Replace('\', '/') + "?print-pdf"
if ($Notes) { $url += "&showNotes=separate-page" }

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $outPath) | Out-Null
if (Test-Path $outPath) { Remove-Item $outPath -Force }

# A throwaway profile keeps this from colliding with a Chrome the user already
# has open, which otherwise makes the headless run exit without printing.
$profileDir = Join-Path ([System.IO.Path]::GetTempPath()) ("quarto-pdf-" + [guid]::NewGuid().ToString("N"))

$arguments = @(
    "--headless=new"
    "--disable-gpu"
    "--no-sandbox"
    "--no-first-run"
    "--disable-extensions"
    "--hide-scrollbars"
    "--log-level=3"
    "--user-data-dir=`"$profileDir`""
    # Let fonts, images and reveal's own layout pass settle before the snapshot.
    "--run-all-compositor-stages-before-draw"
    "--virtual-time-budget=20000"
    "--no-pdf-header-footer"
    "--print-to-pdf=`"$outPath`""
    "`"$url`""
)

Write-Verbose "Browser: $browser"
Write-Verbose "URL:     $url"

# Chrome reports progress on stderr, which PowerShell would otherwise surface as
# a NativeCommandError even on a clean run - capture it and only show it if the
# export actually failed.
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName               = $browser
$psi.Arguments              = ($arguments -join " ")
$psi.UseShellExecute         = $false
$psi.RedirectStandardError   = $true
$psi.CreateNoWindow          = $true

try {
    $process = [System.Diagnostics.Process]::Start($psi)
    $stderr  = $process.StandardError.ReadToEnd()
    $process.WaitForExit()
    $exitCode = $process.ExitCode
}
finally {
    if (Test-Path $profileDir) {
        try { Remove-Item $profileDir -Recurse -Force -ErrorAction Stop } catch {}
    }
}

if (-not (Test-Path $outPath)) {
    Write-Host $stderr
    throw "PDF export failed (browser exit code $exitCode)."
}

$size = "{0:N0} KB" -f ((Get-Item $outPath).Length / 1KB)
Write-Host "Output created: $Output ($size)"
