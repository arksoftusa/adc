---
name: ares-cd
description: "Continue deployment after CI verification: consume tested changes already pushed to Gitea, then provision or update Coolify project/app and execute production CD on Ares. Keywords: continue deployment, CD, Coolify project, Coolify domain, webhook deploy, post-CI deploy, Ares."
argument-hint: "project name, gitea repo/branch, coolify app or create-new flag, domain(optional)"
user-invocable: true
disable-model-invocation: false
---

# Ares Continue Deployment (CD)

Use this skill only for the post-CI CD phase. CI is assumed to be completed already on the staging Docker host `192.168.1.240`, and tested changes are already checked in and pushed to the target Gitea repository.

## Scope

This skill starts at CD handoff and ends at a running Coolify deployment.

In scope:
1. Confirm CI handoff inputs (repo, branch, commit, app target).
2. Load Coolify admin config from `current_workspace\RepoDepot\.env` without exposing secret values.
3. Create or verify the Coolify project/application for the repository.
4. Connect source and trigger deployment through webhook or Coolify API.
5. Monitor deployment and report safe evidence.

Out of scope:
1. Running CI tests on `192.168.1.240`.
2. Editing code or fixing unrelated test failures.
3. Mandatory DNS automation. Domain setup through Cloudflare token is optional and may be skipped.

## Assumptions

The flow is:
1. CI skill validated the service on `192.168.1.240` Docker.
2. Changes were committed and pushed to Gitea.
3. CD continues from that pushed commit.

If these assumptions are not true, stop and hand back to CI/check-in first.

## Use When

- The user asks for continue deployment, CD, Coolify deployment, or post-CI production release.
- The user needs to create a new Coolify project/app from an existing Gitea repo.
- The user needs to redeploy an existing Coolify app from the latest checked-in commit.

## Do Not Use When

- The user is still preparing/testing on staging and has not finished CI.
- The user asks only for local development, non-Ares hosting, or non-Coolify deployment.
- Required Coolify configuration is missing and cannot be supplied.

## Secret Handling Rules

- Never print token values from `.env`.
- Never echo full `.env` lines.
- Only report key presence flags (`Configured=true/false`).
- Keep tokens in memory variables and HTTP headers only.
- Never include credential-bearing URLs in output.

## Required Inputs

Required:
- Gitea repository path and branch to deploy
- Commit hash or "latest commit on branch"
- Coolify server host
- Coolify admin API token

Optional:
- Existing Coolify app UUID (if already created)
- Domain to bind in Coolify
- TLS/redirect preferences

## Expected RepoDepot Env Keys

Prefer these keys from `current_workspace\RepoDepot\.env`:

Coolify:
- `ARES_COOLIFY_SERVER_HOST`
- `ARES_COOLIFY_API_TOKEN`
- `ARES_COOLIFY_SERVER_NAME` (optional metadata)

Gitea mapping helpers:
- `RD_GITEA_BASE_URL`
- `RD_GITEA_PROJECT_REPO_MAP`
- `RD_GITEA_DEFAULT_BRANCH`

If a required key is missing, report the missing key name only.

## Continue Deployment Procedure

### 1. Validate Handoff From CI

- Confirm target repo, branch, and commit from the completed CI/check-in step.
- Confirm whether Coolify app already exists.
- If commit is not pushed yet, stop and request check-in completion first.

### 2. Load Env Safely

Load `.env` into an in-memory map without printing values:

```powershell
$rdEnvPath = "current_workspace\RepoDepot\.env"
$rdEnv = @{}
Get-Content $rdEnvPath | ForEach-Object {
	if ($_ -match '^\s*#' -or $_ -notmatch '=') { return }
	$parts = $_ -split '=', 2
	$key = $parts[0].Trim()
	$value = $parts[1].Trim().Trim('"').Trim("'")
	if ($key) { $rdEnv[$key] = $value }
}
```

### 3. Create or Resolve Coolify Project/App

- If app exists: fetch and verify source repo, branch, and deployment mode.
- If app does not exist: create Coolify project/app using admin API token.
- Attach the Gitea repository and branch as deployment source.
- Confirm application identifier (UUID) and intended URL target.

### 4. Trigger CD

Use one trigger path only:
- Auto path: push event triggers existing webhook.
- Manual webhook path: call the app webhook after push confirmation.
- API path: call Coolify deployment endpoint for the app UUID.

Avoid duplicate triggers unless user asks for forced redeploy.

### 5. Optional Domain Binding

Domain handling is optional in this skill.

- If domain is already configured in Coolify, treat as ready and continue.
- If user explicitly asks to bind domain in Coolify, configure domain + TLS route.
- Cloudflare API token automation is optional and may be unavailable; do not block CD if DNS automation is not requested.

### 6. Monitor and Verify

- Poll deployment state with low-frequency checks.
- Report only safe summaries (status, timestamps, image/tag when safe).
- Verify app health via public URL or health endpoint.

## Safe Output Format

Final output should include:
- Repo and branch
- Commit hash deployed
- Coolify app/project identifier
- Deployment result (`success` or `failed`)
- URL/health check result
- Follow-up action list if failed

Do not include raw tokens, raw `.env`, or full secret-bearing logs.

## Failure Handling

- Missing env key: report key name only.
- Coolify auth/API failure: verify host/token presence flags and endpoint path.
- App creation failure: verify project/app name conflicts and required fields.
- Source-link failure: verify repository URL/branch and Coolify source settings.
- Deployment failure: summarize failing phase only and safe error excerpt.

## Success Criteria

Continue deployment is complete when:
1. The intended pushed commit is selected for release.
2. Coolify project/app exists and points to the correct repository/branch.
3. Coolify deployment reaches success.
4. URL or health endpoint confirms service availability.
