---
name: ares-ci
description: "Use for Ares Continuous Integration setup and staging validation: create or verify Gitea project repositories with Gitea admin token, configure repository SSH deploy key, create/verify Coolify webhook for later CD, then run staging tests on remote Docker host 192.168.1.240. Keywords: Ares, CI, Gitea admin token, create repo, SSH key, Coolify webhook, staging, remote docker, RepoDepot .env."
argument-hint: "project path, target repo, branch, Coolify app/webhook, staging test command"
user-invocable: true
disable-model-invocation: false
---

# Ares CI (Continuous Integration)

Use this skill for Ares CI preparation and staging validation. The focus is integration readiness, not production release.

Primary scope:

1. Create or verify the target Gitea repository using the Gitea admin token.
2. Configure the repository SSH deploy/public key.
3. Create or verify the webhook path used by Coolify for future CD.
4. Run CI staging validation on remote Docker host `192.168.1.240`.

RepoDepot `.env` is the source of truth for Gitea, Coolify, and Ares host settings.

## Goal

Complete CI setup and staging verification without exposing secrets:

1. Validate local project readiness for CI.
2. Load required admin credentials from `current_workspace\RepoDepot\.env` without printing values.
3. Ensure the Gitea repository exists and is reachable by SSH.
4. Configure repository deploy key and webhook for Coolify integration.
5. Push integration changes to the CI branch.
6. Execute staging tests on remote Docker `192.168.1.240` and report non-secret results.

## Use When

- The user asks to set up or update Continuous Integration for an ArkSoft project on Ares.
- The user asks to create a repo with Gitea admin token or wire SSH key access.
- The user asks to pre-create webhook wiring for Coolify, but not necessarily perform full production deploy.
- The user asks to run staging tests on the remote Docker host `192.168.1.240`.

## Do Not Use When

- The user only wants local lint/unit checks with no Ares/Gitea/Coolify integration.
- The user asks for full production rollout; use `ares-cd` for release/deployment execution.
- The user asks for non-Ares CI platforms such as GitHub Actions, Azure DevOps, or Bitbucket pipelines.

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
- `ARES_COOLIFY_API_TOKEN` (preferred)
- `COOLIFY_API_TOKEN` (fallback)
- `ARES_COOLIFY_SERVER_HOST`
- Coolify app UUID or webhook URL keys when available

Gitea:
- `RD_GITEA_BASE_URL`
- `RD_GITEA_ADMIN_TOKEN` (preferred)
- `RD_GITEA_TOKEN` or `GITEA_TOKEN` (fallback)
- `RD_GITEA_DEFAULT_BRANCH`
- `RD_GITEA_PROJECT_REPO_MAP`, when project-to-repository routing is needed
- Optional organization/owner key if used in your environment

SSH/Ares:
- `ARES_SSH_TARGET` and `ARES_SSH_USER` when SSH validation is required
- Docker staging host is fixed to `192.168.1.240` unless user explicitly overrides

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
@("ARES_COOLIFY_API_TOKEN", "COOLIFY_API_TOKEN", "RD_GITEA_BASE_URL", "RD_GITEA_ADMIN_TOKEN", "RD_GITEA_TOKEN", "GITEA_TOKEN") | ForEach-Object {
	[pscustomobject]@{ Key = $_; Configured = [bool]$rdEnv[$_] }
}
```

## CI Procedure

### 1. Identify CI Target

- Confirm the local project path, Gitea owner/repository, CI branch, and Coolify app or webhook target.
- Prefer existing project mappings from `RD_GITEA_PROJECT_REPO_MAP` when available.
- If there are multiple plausible targets, ask one concise question before deploying.

### 2. Validate Local Readiness

- Inspect the project README or local deployment docs for test/build commands.
- Run minimal integration prerequisites locally, then proceed to remote staging checks.
- Do not fix unrelated failures unless they block CI flow.

### 3. Check Git State Safely

- Use `git status --short` and targeted diffs to review changes.
- Avoid `git remote -v` because remotes can contain credentials.
- If the remote URL must be inspected, redact credentials before showing it.
- Never overwrite user changes. Work with existing changes unless the user explicitly asks for a reset or revert.

### 4. Create or Verify Gitea Repository

- Use `RD_GITEA_BASE_URL` and `RD_GITEA_ADMIN_TOKEN` when available (`RD_GITEA_TOKEN`/`GITEA_TOKEN` as fallback).
- If the repository does not exist, create it with the admin token.
- Confirm repository owner, default branch, and push permissions.
- Use an SSH or credential-safe remote. Do not embed admin tokens in remote URLs.

### 5. Configure Repository SSH Key

- Add or verify the repository deploy/public key in Gitea.
- Ensure the key has only required permissions for CI flow.
- Validate SSH connectivity with non-secret checks.

### 6. Create or Verify Coolify Webhook

- Configure webhook integration so pushes can trigger Coolify later.
- Prefer one webhook path to avoid duplicate triggers.
- Record webhook presence and target app as readiness evidence.

### 7. Check In and Push

- Stage only intended project files.
- Commit with a clear CI wiring message.
- Push to the configured Gitea branch.
- Capture the commit hash after push.

### 8. Run Staging Tests on Remote Docker

- Execute integration/staging checks on `tcp://192.168.1.240:2375`.
- Use low-risk commands first, such as image pull/build, container start, and health/smoke endpoint checks.
- If compose is used, include explicit project name to avoid wrong stack targeting.
- Summarize logs safely; avoid raw output that may contain secrets.

### 9. Final Report

Report only safe CI facts:

- Local project path
- Gitea repository and branch
- Repository creation status
- SSH key configuration status
- Coolify webhook readiness status
- Commit hash
- Staging runtime host (`192.168.1.240`) and test result
- Any non-secret warnings or follow-up actions

Do not include token values, full `.env` lines, raw deployment logs, or credential-bearing URLs.

## First-Time CI Wiring Checklist

Use this checklist when a project is being integrated into the Ares path for the first time.

- RepoDepot `.env` contains Coolify admin token, Gitea admin token, Gitea base URL, and Ares SSH target details.
- Gitea repository is created or verified with admin token.
- Repository deploy/public SSH key is configured and validated.
- Coolify webhook is created or verified for future automated deploy triggers.
- Remote staging Docker checks run on `192.168.1.240` and pass smoke validation.

## Failure Handling

- Missing env key: report the key name only and ask the user to add it to RepoDepot `.env`.
- Gitea auth failure: verify token presence, scope, and base URL without printing values.
- Repo creation failure: verify owner/org target and duplicate-name conflict.
- SSH key failure: verify key format and whether key is already attached to another target.
- Push rejected: inspect branch protection, remote configuration, and local branch state.
- Webhook failure: verify target app/resource and webhook registration.
- Remote staging failure: summarize failing test phase and container health evidence.

## Success Criteria

CI setup is complete when the target repository exists in Gitea, SSH key and webhook wiring are verified, the intended commit is pushed to the correct branch, and staging tests on `192.168.1.240` pass basic health checks.
