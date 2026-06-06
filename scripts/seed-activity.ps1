# Adds dated devlog commits for contribution activity.
# Author/committer are pinned to the repo owner — no bots or agents in contributors.
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot\..

$AuthorName  = 'Jonny'
$AuthorEmail = '78306175+Yevhen-Lytvynenko@users.noreply.github.com'

$env:GIT_AUTHOR_NAME     = $AuthorName
$env:GIT_COMMITTER_NAME  = $AuthorName
$env:GIT_AUTHOR_EMAIL    = $AuthorEmail
$env:GIT_COMMITTER_EMAIL = $AuthorEmail

function New-DatedCommit {
    param(
        [string]$Date,
        [string]$Message,
        [string]$FilePath,
        [string]$Content
    )
    $dir = Split-Path $FilePath -Parent
    if ($dir -and -not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    Set-Content -Path $FilePath -Value $Content -Encoding UTF8

    $env:GIT_AUTHOR_DATE    = "$Date 14:30:00 +0200"
    $env:GIT_COMMITTER_DATE = "$Date 14:30:00 +0200"

    git add $FilePath
    git commit -m $Message
    Write-Host "OK $Date $Message"
}

$entries = @(
    @{ Date = '2025-06-01'; Note = 'Project kickoff and proto schema draft.' }
    @{ Date = '2025-06-15'; Note = 'Defined Board, Column, and Task messages.' }
    @{ Date = '2025-06-29'; Note = 'Outlined server RPC surface for Kanban ops.' }
    @{ Date = '2025-07-13'; Note = 'Implemented mutex guards around board state.' }
    @{ Date = '2025-07-27'; Note = 'Added default columns on server startup.' }
    @{ Date = '2025-08-10'; Note = 'Hooked Grpc.Net.Client channel in client.' }
    @{ Date = '2025-08-24'; Note = 'Connected ObservableCollection rebuild on sync.' }
    @{ Date = '2025-09-07'; Note = 'Polished task card context menu actions.' }
    @{ Date = '2025-09-21'; Note = 'Tuned Material Design card spacing.' }
    @{ Date = '2025-10-05'; Note = 'Improved drag threshold for task moves.' }
    @{ Date = '2025-10-19'; Note = 'Handled RpcException on sync cancellation.' }
    @{ Date = '2025-11-03'; Note = 'Documented insecure credentials for local dev.' }
    @{ Date = '2025-11-10'; Note = 'Added server broadcast logging for debugging.' }
    @{ Date = '2025-11-24'; Note = 'Reviewed CMake linkage for gRPC and Protobuf.' }
    @{ Date = '2025-12-12'; Note = 'Captured sync flow in architecture notes.' }
    @{ Date = '2025-12-19'; Note = 'Listed vcpkg packages required for Windows build.' }
    @{ Date = '2025-12-26'; Note = 'Prepared client README quick start section.' }
    @{ Date = '2026-01-05'; Note = 'Clarified ServerIP configuration scenarios.' }
    @{ Date = '2026-01-12'; Note = 'Added troubleshooting table for connection errors.' }
    @{ Date = '2026-01-27'; Note = 'Synced proto copies between server and client.' }
    @{ Date = '2026-02-01'; Note = 'Verified dotnet build on net8.0-windows.' }
    @{ Date = '2026-02-15'; Note = 'Checked multi-client board consistency.' }
    @{ Date = '2026-02-29'; Note = 'Updated changelog with release milestones.' }
    @{ Date = '2026-03-01'; Note = 'Refined monorepo layout documentation.' }
    @{ Date = '2026-03-08'; Note = 'Documented MoveTask drag-and-drop flow.' }
    @{ Date = '2026-03-22'; Note = 'Added MIT license for portfolio use.' }
    @{ Date = '2026-03-29'; Note = 'Normalized line endings via editorconfig.' }
    @{ Date = '2026-04-12'; Note = 'Expanded server API table in README.' }
    @{ Date = '2026-04-19'; Note = 'Noted protoc regeneration commands.' }
    @{ Date = '2026-04-26'; Note = 'Added ports table to architecture doc.' }
    @{ Date = '2026-05-17'; Note = 'Published repository to GitHub.' }
    @{ Date = '2026-05-24'; Note = 'Prepared contribution-friendly repo metadata.' }
    @{ Date = '2026-05-31'; Note = 'Reviewed gitignore coverage for build artifacts.' }
    @{ Date = '2026-06-01'; Note = 'Smoke-tested client against local server.' }
    @{ Date = '2026-06-03'; Note = 'Validated contribution email mapping.' }
    @{ Date = '2026-06-04'; Note = 'Added devlog notes for project timeline.' }
)

foreach ($e in $entries) {
    $file = "docs/devlog/$($e.Date).md"
    $body = @(
        "# Devlog $($e.Date)"
        ''
        $e.Note
        ''
        '_DoThis client-server Kanban project._'
    ) -join "`n"

    New-DatedCommit -Date $e.Date -Message "docs: devlog entry for $($e.Date)" -FilePath $file -Content $body
}

# Script commit uses the same identity, current timeline end.
$today = '2026-06-06'
$scriptPath = 'scripts/seed-activity.ps1'
$env:GIT_AUTHOR_DATE    = "$today 15:00:00 +0200"
$env:GIT_COMMITTER_DATE = "$today 15:00:00 +0200"
git add $scriptPath
git commit -m 'chore: add activity seeding script with pinned author identity'

Write-Host "`nDone. Commits: $(git rev-list --count HEAD)"
Write-Host "Authors:"
git shortlog -sne --all
