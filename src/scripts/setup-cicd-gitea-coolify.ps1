[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RepoOwner,

    [Parameter(Mandatory = $true)]
    [string]$RepoName,

    [Parameter(Mandatory = $true)]
    [string]$CoolifyAppName,

    [string]$TargetBranch = "main",

    [switch]$TriggerDeployTest,

    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-EnvMap {
    param([string]$Path)

    $map = @{}
    if (-not (Test-Path -LiteralPath $Path)) {
        return $map
    }

    Get-Content -LiteralPath $Path | ForEach-Object {
        $line = $_.Trim()
        if (-not $line -or $line.StartsWith("#")) {
            return
        }

        $idx = $line.IndexOf("=")
        if ($idx -lt 1) {
            return
        }

        $key = $line.Substring(0, $idx).Trim()
        $value = $line.Substring($idx + 1).Trim().Trim('"').Trim("'")
        if ($key) {
            $map[$key] = $value
        }
    }

    return $map
}

function Get-ConfigValue {
    param(
        [hashtable]$EnvMap,
        [string]$Key
    )

    if ($EnvMap.ContainsKey($Key) -and $EnvMap[$Key]) {
        return $EnvMap[$Key]
    }

    $runtime = [Environment]::GetEnvironmentVariable($Key)
    if ($runtime) {
        return $runtime
    }

    return $null
}

function Normalize-BaseUrl {
    param([string]$Url)

    if (-not $Url) {
        return $null
    }

    return $Url.Trim().TrimEnd('/')
}

function Invoke-GiteaApi {
    param(
        [string]$Method,
        [string]$BaseUrl,
        [string]$Token,
        [string]$Path,
        [object]$Body = $null
    )

    $uri = "$BaseUrl$Path"
    $headers = @{
        Authorization = "token $Token"
        Accept        = "application/json"
    }

    if ($null -ne $Body) {
        return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -ContentType "application/json" -Body ($Body | ConvertTo-Json -Depth 8)
    }

    return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers
}

function Invoke-CoolifyApi {
    param(
        [string]$Method,
        [string]$BaseUrl,
        [string]$Token,
        [string]$Path,
        [object]$Body = $null
    )

    $uri = "$BaseUrl$Path"
    $headers = @{
        Authorization = "Bearer $Token"
        Accept        = "application/json"
    }

    if ($null -ne $Body) {
        return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -ContentType "application/json" -Body ($Body | ConvertTo-Json -Depth 8)
    }

    return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers
}

function ConvertTo-Bool {
    param([string]$Value)

    if (-not $Value) {
        return $false
    }

    return $Value.Trim().ToLowerInvariant() -in @("1", "true", "yes", "on")
}

$envPath = Join-Path (Get-Location) ".env"
$envMap = Get-EnvMap -Path $envPath

$giteaUrl = Normalize-BaseUrl (Get-ConfigValue -EnvMap $envMap -Key "GITEA_URL")
$giteaToken = Get-ConfigValue -EnvMap $envMap -Key "GITEA_TOKEN"
$coolifyUrl = Normalize-BaseUrl (Get-ConfigValue -EnvMap $envMap -Key "COOLIFY_URL")
$coolifyToken = Get-ConfigValue -EnvMap $envMap -Key "COOLIFY_API_TOKEN"
$webhookSecret = Get-ConfigValue -EnvMap $envMap -Key "WEBHOOK_SECRET"
$cicdMode = Get-ConfigValue -EnvMap $envMap -Key "CICD"
$legacyCicdEnabled = ConvertTo-Bool (Get-ConfigValue -EnvMap $envMap -Key "CICD_Enabled")
$cicdEnabled = (($cicdMode -and $cicdMode.Trim().ToLowerInvariant() -eq "enabled") -or $legacyCicdEnabled)

if (-not $giteaToken) {
    throw "Missing GITEA_TOKEN in .env or process environment."
}
if (-not $coolifyToken) {
    throw "Missing COOLIFY_API_TOKEN in .env or process environment."
}

if (-not $cicdEnabled) {
    Write-Host "CI/CD setup is disabled (expected CICD=enabled, legacy CICD_Enabled=true also supported)."
    Write-Host "Skipping CI/CD initialization preflight and setup steps."
    exit 0
}

if (-not $giteaUrl) {
    throw "Missing GITEA_URL in .env or process environment."
}
if (-not $coolifyUrl) {
    throw "Missing COOLIFY_URL in .env or process environment."
}

if (-not $Force) {
    Write-Host "Detected CI/CD enabled mode in .env (CICD=enabled or CICD_Enabled=true) and both required API tokens."
    Write-Host "Repo: $RepoOwner/$RepoName"
    Write-Host "Coolify app name: $CoolifyAppName"
    Write-Host "Target branch: $TargetBranch"
    Write-Host "Trigger deploy test: $($TriggerDeployTest.IsPresent)"

    $answer = Read-Host "Confirm CI/CD initialization now? Type 'yes' to continue"
    if ($answer.Trim().ToLowerInvariant() -ne "yes") {
        Write-Host "Initialization cancelled by user."
        exit 0
    }
}

Write-Host "Validating Gitea token against /api/v1/user ..."
$giteaUser = Invoke-GiteaApi -Method "GET" -BaseUrl $giteaUrl -Token $giteaToken -Path "/api/v1/user"
if (-not $giteaUser) {
    throw "Unable to validate Gitea token."
}

Write-Host "Validating Coolify token against /api/v1/applications ..."
$apps = Invoke-CoolifyApi -Method "GET" -BaseUrl $coolifyUrl -Token $coolifyToken -Path "/api/v1/applications"
if (-not $apps) {
    throw "Unable to validate Coolify token or fetch applications."
}

$targetApp = $apps | Where-Object { $_.name -eq $CoolifyAppName } | Select-Object -First 1
if (-not $targetApp) {
    throw "Coolify application '$CoolifyAppName' not found."
}

$appId = if ($targetApp.uuid) { $targetApp.uuid } elseif ($targetApp.id) { $targetApp.id } else { $null }
if (-not $appId) {
    throw "Could not determine Coolify app identifier (uuid/id)."
}

Write-Host "Reading Coolify app details for branch and webhook metadata ..."
$appDetails = Invoke-CoolifyApi -Method "GET" -BaseUrl $coolifyUrl -Token $coolifyToken -Path "/api/v1/applications/$appId"

$currentBranch = $appDetails.git_branch
if ($currentBranch -ne $TargetBranch) {
    Write-Host "Updating Coolify app branch from '$currentBranch' to '$TargetBranch' ..."
    [void](Invoke-CoolifyApi -Method "PATCH" -BaseUrl $coolifyUrl -Token $coolifyToken -Path "/api/v1/applications/$appId" -Body @{ git_branch = $TargetBranch })
}

$coolifyWebhookUrl = $null
if ($appDetails.webhook_url) {
    $coolifyWebhookUrl = $appDetails.webhook_url
} elseif ($appDetails.webhook -and $appDetails.webhook.url) {
    $coolifyWebhookUrl = $appDetails.webhook.url
} else {
    $coolifyWebhookUrl = "$coolifyUrl/api/v1/deploy?uuid=$appId"
}

if (-not $webhookSecret) {
    if ($appDetails.webhook_secret) {
        $webhookSecret = $appDetails.webhook_secret
    } elseif ($appDetails.webhook -and $appDetails.webhook.secret) {
        $webhookSecret = $appDetails.webhook.secret
    }
}

if (-not $webhookSecret) {
    throw "WEBHOOK_SECRET is missing and no webhook secret could be discovered from Coolify. Set WEBHOOK_SECRET securely before proceeding."
}

Write-Host "Loading Gitea webhook list ..."
$hooks = Invoke-GiteaApi -Method "GET" -BaseUrl $giteaUrl -Token $giteaToken -Path "/api/v1/repos/$RepoOwner/$RepoName/hooks"
$existingHook = $hooks | Where-Object { $_.config.url -eq $coolifyWebhookUrl } | Select-Object -First 1

$hookPayload = @{
    type          = "gitea"
    active        = $true
    branch_filter = $TargetBranch
    events        = @("push")
    config        = @{
        url          = $coolifyWebhookUrl
        content_type = "json"
        secret       = $webhookSecret
    }
}

$hookAction = "none"
$hookId = $null
if ($existingHook) {
    $hookId = $existingHook.id
    Write-Host "Updating existing Gitea webhook id=$hookId ..."
    [void](Invoke-GiteaApi -Method "PATCH" -BaseUrl $giteaUrl -Token $giteaToken -Path "/api/v1/repos/$RepoOwner/$RepoName/hooks/$hookId" -Body $hookPayload)
    $hookAction = "updated"
} else {
    Write-Host "Creating new Gitea webhook ..."
    $created = Invoke-GiteaApi -Method "POST" -BaseUrl $giteaUrl -Token $giteaToken -Path "/api/v1/repos/$RepoOwner/$RepoName/hooks" -Body $hookPayload
    $hookId = $created.id
    $hookAction = "created"
}

$webhookTestStatus = "not-run"
try {
    Write-Host "Triggering Gitea webhook test delivery ..."
    [void](Invoke-GiteaApi -Method "POST" -BaseUrl $giteaUrl -Token $giteaToken -Path "/api/v1/repos/$RepoOwner/$RepoName/hooks/$hookId/tests")
    $webhookTestStatus = "triggered"
} catch {
    $webhookTestStatus = "failed"
    Write-Warning "Webhook test call failed. Inspect Gitea delivery logs for HTTP response and response body."
}

$deployTestStatus = "not-requested"
if ($TriggerDeployTest) {
    $deployTestStatus = "requested"
    try {
        Write-Host "Triggering Coolify deployment test via API ..."
        [void](Invoke-CoolifyApi -Method "POST" -BaseUrl $coolifyUrl -Token $coolifyToken -Path "/api/v1/deployments" -Body @{ application_uuid = $appId })
        $deployTestStatus = "queued"
    } catch {
        $deployTestStatus = "failed"
        Write-Warning "Direct deployment API trigger failed. Verify Coolify deployment endpoint for your version."
    }
}

$report = [pscustomobject]@{
    repository             = "$RepoOwner/$RepoName"
    app_name               = $CoolifyAppName
    app_id                 = $appId
    target_branch          = $TargetBranch
    gitea_identity         = $giteaUser.login
    coolify_app_found      = $true
    coolify_branch_aligned = $true
    webhook_url_configured = $coolifyWebhookUrl
    webhook_action         = $hookAction
    webhook_test_status    = $webhookTestStatus
    deploy_test_status     = $deployTestStatus
}

Write-Host ""
Write-Host "CI/CD setup summary (sanitized):"
$report | Format-List | Out-String | Write-Host

Write-Host "Security notes:"
Write-Host "- Tokens were read from environment only and were never printed."
Write-Host "- Webhook configured for push-only events with branch filter '$TargetBranch'."
Write-Host "- Ensure token scopes are least privilege and rotate secrets regularly."
