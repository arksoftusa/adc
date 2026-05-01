param(
    [string]$BaseBranch = "main",
    [switch]$Preview
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Test-BranchExists {
    param([string]$Name)
    git show-ref --verify --quiet "refs/heads/$Name"
    return ($LASTEXITCODE -eq 0)
}

if (-not (Test-BranchExists -Name $BaseBranch)) {
    Write-Error "Base branch '$BaseBranch' does not exist locally."
    exit 1
}

$currentBranch = (git rev-parse --abbrev-ref HEAD).Trim()
if ($currentBranch -ne $BaseBranch) {
    Write-Host "Switching to '$BaseBranch'..."
    git checkout $BaseBranch | Out-Null
}

Write-Host "Fetching latest remote refs..."
git fetch --all --prune | Out-Null

$devBranches = git for-each-ref --format='%(refname:short)' refs/heads/dev |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -ne "" }

if (-not $devBranches) {
    Write-Host "No local dev/* branches found."
    exit 0
}

$mergedBranches = @()
foreach ($branch in $devBranches) {
    git merge-base --is-ancestor $branch $BaseBranch | Out-Null
    if ($LASTEXITCODE -eq 0) {
        $mergedBranches += $branch
    }
}

if (-not $mergedBranches) {
    Write-Host "No merged local dev/* branches to delete."
    exit 0
}

if ($Preview) {
    Write-Host "Preview mode. Branches that would be deleted:"
    $mergedBranches | ForEach-Object { Write-Host " - $_" }
    exit 0
}

Write-Host "Deleting merged local dev/* branches..."
foreach ($branch in $mergedBranches) {
    git branch -d $branch
}

Write-Host "Done. Deleted $($mergedBranches.Count) branch(es)."