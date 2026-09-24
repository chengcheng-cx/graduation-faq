param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('setup', 'check', 'preview', 'update', 'sync')]
    [string]$Action
)

$ErrorActionPreference = 'Stop'
$projectDir = Split-Path -Parent $PSScriptRoot
$localDir = Join-Path $env:USERPROFILE '.graduation-faq'
$venvDir = Join-Path $localDir 'venv'
$pythonExe = Join-Path $venvDir 'Scripts\python.exe'
$siteDir = Join-Path $localDir 'site'
# This project pins MkDocs 1.6.1; suppress Material's MkDocs 2.0 notice.
$env:NO_MKDOCS_2_WARNING = '1'
Set-Location -LiteralPath $projectDir

function Invoke-Checked {
    param([string]$Command, [string[]]$Arguments)
    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$Command failed with exit code $LASTEXITCODE."
    }
}

function Initialize-Environment {
    New-Item -ItemType Directory -Path $localDir -Force | Out-Null

    if (-not (Test-Path -LiteralPath $pythonExe)) {
        $candidates = @(
            @{ Command = 'py'; Arguments = @('-3.12') },
            @{ Command = 'py'; Arguments = @('-3') },
            @{ Command = 'python'; Arguments = @() }
        )
        $created = $false
        foreach ($candidate in $candidates) {
            if (-not (Get-Command $candidate.Command -ErrorAction SilentlyContinue)) { continue }
            # Windows PowerShell treats a missing py version's stderr as a terminating error.
            # Try the next installed Python candidate instead.
            try {
                & $candidate.Command @($candidate.Arguments) -c 'import sys; sys.exit(sys.version_info < (3, 12))' *> $null
            }
            catch { continue }
            if ($LASTEXITCODE -ne 0) { continue }
            Invoke-Checked $candidate.Command (@($candidate.Arguments) + @('-m', 'venv', $venvDir))
            $created = $true
            break
        }
        if (-not $created) { throw 'Python was not found. Install Python 3.12 or newer.' }
    }

    Write-Host 'Installing or checking website dependencies...'
    Invoke-Checked $pythonExe @('-m', 'pip', 'install', '--quiet', '--disable-pip-version-check', '-r', 'requirements.txt')
    Invoke-Checked 'git' @('config', '--local', 'core.hooksPath', '.githooks')
    Write-Host "Python environment: $venvDir"
}

function Test-Website {
    Initialize-Environment
    Invoke-Checked $pythonExe @('-m', 'pip', 'check')
    Invoke-Checked $pythonExe @('-m', 'mkdocs', 'build', '--strict', '--site-dir', $siteDir)
    Write-Host "Website build passed: $siteDir"
}

try {
    switch ($Action) {
        'setup' {
            Initialize-Environment
        }
        'check' {
            Test-Website
        }
        'preview' {
            Initialize-Environment
            Write-Host 'Local preview: http://127.0.0.1:8000/'
            Invoke-Checked $pythonExe @('-m', 'mkdocs', 'serve', '--dev-addr', '127.0.0.1:8000')
        }
        'update' {
            Test-Website
            Invoke-Checked 'git' @('diff', '--check')
            Invoke-Checked 'git' @('fetch', 'origin', 'main')

            $branch = (& git branch --show-current).Trim()
            if ($LASTEXITCODE -ne 0 -or -not $branch) { throw 'Check out a branch before updating.' }
            if ($branch -eq 'main') {
                $localHead = (& git rev-parse HEAD).Trim()
                $remoteHead = (& git rev-parse origin/main).Trim()
                if ($localHead -ne $remoteHead) {
                    throw 'Local main differs from GitHub. Run sync.cmd before updating.'
                }
            }

            Invoke-Checked 'git' @('add', '-A')
            Invoke-Checked 'git' @('diff', '--cached', '--check')
            $staged = @(& git diff --cached --name-only)
            if ($LASTEXITCODE -ne 0) { throw 'Cannot inspect staged changes.' }
            if ($staged.Count -eq 0) {
                Write-Host 'No changes to upload.'
                break
            }

            Write-Host 'Files to upload:'
            $staged | ForEach-Object { Write-Host "  $_" }
            if ($branch -eq 'main') {
                $branch = 'draft-' + (Get-Date -Format 'yyyyMMdd-HHmmss')
                Invoke-Checked 'git' @('switch', '-c', $branch)
            }

            Invoke-Checked 'git' @('commit', '-m', 'Update graduation FAQ')
            Invoke-Checked 'git' @('push', '--set-upstream', 'origin', $branch)
            Write-Host "Draft uploaded: $branch"
            Write-Host "Review and open a pull request: https://github.com/chengcheng-cx/graduation-faq/compare/main...${branch}?expand=1"
            Write-Host 'Merge the pull request only after the validation check passes.'
        }
        'sync' {
            $changes = @(& git status --porcelain)
            if ($LASTEXITCODE -ne 0) { throw 'Cannot inspect Git status.' }
            if ($changes.Count -gt 0) { throw 'Save or commit local changes before syncing.' }
            Invoke-Checked 'git' @('fetch', 'origin', 'main')
            Invoke-Checked 'git' @('switch', 'main')
            Invoke-Checked 'git' @('pull', '--ff-only', 'origin', 'main')
            Write-Host 'Local main is up to date. The next update will create a fresh draft branch.'
        }
    }
}
catch {
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
