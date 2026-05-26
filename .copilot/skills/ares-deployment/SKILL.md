---
name: ares-deployment
description: "Use when deploying ArkSoft local websites or services through the Ares CI/CD path: read Coolify admin token, SSH target details, and Gitea admin token from the RepoDepot .env file; check in local changes to Gitea; trigger the Coolify webhook/API; monitor the container deployment on Ares. Keywords: Ares, Coolify, Gitea, webhook, CI/CD, container deploy, RD .env, RepoDepot .env, SSH deploy."
argument-hint: "path to your site or service, Gitea repo, Coolify app/webhook, branch"
user-invocable: true
disable-model-invocation: false
---

# Ares Deployment

Use this skill for the Ares deployment workflow where a local ArkSoft website or service is checked into Gitea and then deployed by Coolify as a container. RepoDepot's `.env` file is the source of truth for Coolify admin access, Gitea admin access, and SSH target details.

## Goal

Complete the CI/CD handoff without exposing secrets:

1. Validate the local project and deployment target.
2. Load required admin credentials from `current_workspace\RepoDepot\.env` without printing values.
3. Check in local changes to the target Gitea repository.
4. Trigger the Coolify deploy webhook or Coolify API deployment.
5. Monitor Coolify and, when needed, verify the running container on Ares over SSH.
6. Report only non-secret deployment evidence: commit hash, branch, target app, status, URL, and health result.

## Use When

- The user asks to deploy a local ArkSoft site or service to Ares.
- The user mentions Coolify, Gitea, Ares, webhook deployment, CI/CD, container deployment, or RepoDepot `.env` deployment credentials.
- The desired flow is: local check-in -> push to Gitea -> Coolify webhook/API trigger -> container deploy.
- A local site needs to be connected to the Ares deployment path for the first time.

## Do Not Use When

- The user only wants local preview, static editing, or frontend polish with no deployment.
- The user asks for Azure, GitHub Actions, Bitbucket, or non-Ares hosting.
- Required credentials are missing and cannot be supplied through the runtime environment.

## Secret Handling Rules

- Never print, summarize, log, paste, or commit token values from `.env`.
- Never read `current_workspace\RepoDepot\.env` with a tool or command that will echo full lines containing values.
- If variable discovery is required, output key names only, never values.
- Use PowerShell variables and header objects for API calls. Avoid external commands that place expanded tokens in process arguments.
- Do not pass tokens in URLs, command arguments, git remotes, commit messages, issue text, or final responses.
- Before staging or committing, verify that `.env`, token dumps, generated secret logs, and temporary credential files are not included.
- If a command output includes a secret, stop using that output and do not repeat it to the user.

## Expected RepoDepot Env Keys

Load these from `current_workspace\RepoDepot\.env` when present. Treat aliases as acceptable because older projects may use different names.

Coolify:
- `COOLIFY_API_TOKEN`
- Project-specific Coolify server metadata such as `ARES_COOLIFY_SERVER_HOST`, `ARES_COOLIFY_API_TOKEN`, `ARES_COOLIFY_SERVER_NAME`, or `ARES_COOLIFY_SERVER_UUID`
- A project-specific Coolify webhook URL or deployment URL, if present

Gitea:
- `RD_GITEA_BASE_URL`
- `RD_GITEA_TOKEN` or `GITEA_TOKEN`
- `RD_GITEA_DEFAULT_BRANCH`
- `RD_GITEA_PROJECT_REPO_MAP`, when project-to-repository routing is needed

SSH/Ares:
- Project-specific SSH target keys such as `ARES_SSH_TARGET`
- Project-specific SSH user keys such as `ARES_SSH_USER`
- SSH verification metadata such as `ARES_SSH_VERIFIED_AT`

If a required key is missing, ask for the missing non-secret configuration name or have the user add it to RepoDepot `.env`. Do not invent endpoints, tokens, repository names, or application UUIDs.

## Safe Env Loading Pattern

Use a parser that reads key/value pairs into memory without printing values. Keep the loaded object local to the deployment step.

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

When checking for availability, print booleans or key names only:

```powershell
@("COOLIFY_API_TOKEN", "RD_GITEA_BASE_URL", "RD_GITEA_TOKEN", "GITEA_TOKEN") | ForEach-Object {
	[pscustomobject]@{ Key = $_; Configured = [bool]$rdEnv[$_] }
}
```

## Deployment Procedure

### 1. Identify the Target

- Confirm the local project path, public URL, Gitea repository, branch, and Coolify application/resource.
- Prefer existing project mappings from `RD_GITEA_PROJECT_REPO_MAP` when available.
- If there are multiple plausible targets, ask one concise question before deploying.

### 2. Validate Local Readiness

- Inspect the project README or local deployment docs for test/build commands.
- Run the smallest meaningful verification first, then the project build if available.
- Confirm generated release artifacts are expected before staging them.
- Do not fix unrelated failures unless they block the deployment.

### 3. Check Git State Safely

- Use `git status --short` and targeted diffs to review changes.
- Avoid `git remote -v` because remotes can contain credentials.
- If the remote URL must be inspected, redact credentials before showing it.
- Never overwrite user changes. Work with existing changes unless the user explicitly asks for a reset or revert.

### 4. Ensure Gitea Repository Connectivity

- Use `RD_GITEA_BASE_URL` and `RD_GITEA_TOKEN` or `GITEA_TOKEN` for Gitea API checks.
- Confirm the target repository exists and the target branch is correct.
- If bootstrapping a new deployment path, create or verify the repository through Gitea using the admin token.
- Use an SSH or credential-safe remote. Do not embed admin tokens in remote URLs.

### 5. Check In and Push

- Stage only intended project files.
- Commit with a clear deployment-oriented message.
- Push to the configured Gitea branch.
- Capture the commit hash after push.

### 6. Trigger Coolify

Choose the trigger that matches the project configuration:

- Preferred steady-state path: the Gitea push triggers the configured Coolify webhook automatically.
- Manual trigger path: call the project-specific Coolify webhook after the push.
- API trigger path: use `ARES_COOLIFY_API_TOKEN` against the Coolify API for the target application/resource.

Do not call a webhook until the commit has been pushed successfully. If both a push webhook and a manual trigger are configured, avoid duplicate deployment unless the user explicitly wants a forced redeploy.

### 7. Monitor Deployment

- Poll Coolify status at low frequency and stop when the deployment reaches success or failure.
- If Coolify logs are needed, summarize status fields only. Do not paste full logs because build logs may contain hidden secrets.
- Verify the deployed public URL or health endpoint when available.
- Use SSH to Ares only for non-secret operational checks such as container status, service health, timestamps, and image/container identifiers.

### 8. Final Report

Report only safe deployment facts:

- Local project path
- Gitea repository and branch
- Commit hash
- Coolify app/resource name or UUID
- Deployment status
- Public URL or health-check result
- Any non-secret warnings or follow-up actions

Do not include token values, full `.env` lines, raw deployment logs, or credential-bearing URLs.

## First-Time Wiring Checklist

Use this checklist when the project is not yet wired into the Ares CI/CD path.

- RepoDepot `.env` contains Coolify admin token, Gitea admin token, Gitea base URL, and Ares SSH target details.
- Gitea repository exists and accepts pushes from the local project.
- Coolify application/resource points to the Gitea repository and branch.
- Coolify build settings match the project type, such as Dockerfile, static build output, compose file, or container port.
- Gitea webhook or Coolify deploy webhook is configured for push-based deployment.
- A test commit can trigger Coolify and produce a running container.
- Public URL or internal health endpoint returns the expected response.

## Failure Handling

- Missing env key: report the key name only and ask the user to add it to RepoDepot `.env`.
- Gitea auth failure: verify token presence and base URL without printing either value.
- Push rejected: inspect branch protection, remote configuration, and local branch state.
- Coolify trigger failure: verify target app/resource, webhook registration, and token presence.
- Build failure: summarize the failing phase and safe error text; avoid raw secret-bearing logs.
- Runtime failure: check container status, exposed port, environment variable presence flags, and health endpoint response.

## Success Criteria

The deployment is complete when the intended local commit is present in Gitea, Coolify has completed the corresponding deployment, and the deployed container or public URL passes a basic health check.
