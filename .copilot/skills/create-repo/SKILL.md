---
name: create-repo
description: "Use when creating or wiring an ArkSoft Gitea repository with the Gitea admin token from RepoDepot .env, including repository creation/verification and repo-level public deploy key setup. Keywords: create repo, Gitea repo, Gitea admin token, deploy key, public key, repository bootstrap, RepoDepot .env, RD .env, Ares, Coolify."
argument-hint: "project path, Gitea owner/repo, default branch, deploy public key or key env name"
user-invocable: true
disable-model-invocation: false
---

# Gitea Repository Creation And Deploy Key Setup

Use this skill when an ArkSoft project needs a Gitea repository created or verified and a repository-level public deploy key installed using the Gitea admin token stored in RepoDepot's `.env` file. The workflow may be used as the first wiring step before Coolify/Ares deployment, but it does not deploy by itself.

## Goal

Create or verify the repository and deploy-key wiring without exposing secrets:

1. Identify the local project, intended Gitea owner, repository name, default branch, and deploy key source.
2. Load required Gitea configuration from `current_workspace\RepoDepot\.env` without printing token values.
3. Use the Gitea admin token to create or verify the repository.
4. Configure repository metadata needed for CI/CD handoff, such as privacy, default branch, and optional description.
5. Add or verify the repository-level public deploy key.
6. Report only non-secret evidence: Gitea base URL hostname, owner/repo, branch, repo URL without credentials, deploy key title/fingerprint, and whether each item was created or already existed.

## Use When

- The user asks to create a Gitea repository for an ArkSoft project.
- The user asks to wire a repo using a Gitea admin token.
- The user asks to add, verify, replace, or audit a public deploy key for a Gitea repository.
- The user mentions repo bootstrap, create-repo, deploy key, public key, Gitea admin token, RepoDepot `.env`, Ares, Coolify repository setup, or CI/CD repository preparation.

## Do Not Use When

- The user only wants to deploy an already wired repo through Coolify/Ares. Use the deployment skill instead.
- The user asks for GitHub, Bitbucket, Azure DevOps, or non-Gitea repository hosting.
- The requested operation requires a private deploy key value that is not already stored securely or explicitly supplied by the user through an appropriate secure channel.
- Required Gitea configuration is missing and cannot be supplied through RepoDepot `.env` or the runtime environment.

## Secret Handling Rules

- Never print, summarize, log, paste, or commit token values from `.env`.
- Never read `current_workspace\RepoDepot\.env` with a tool or command that will echo full lines containing values.
- If variable discovery is required, output key names only, never values.
- Use PowerShell variables and header objects for API calls. Avoid external commands that place expanded tokens in process arguments.
- Do not pass tokens in URLs, command arguments, git remotes, commit messages, issue text, PR text, or final responses.
- Do not upload, print, or commit private deploy keys. Only the public deploy key is installed in Gitea.
- Public deploy keys may be shown only as a title, type, short prefix, or fingerprint. Avoid pasting the full public key unless the user explicitly asks.
- Before staging or committing, verify that `.env`, private key files, token dumps, generated secret logs, and temporary credential files are not included.
- If a command output includes a secret, stop using that output and do not repeat it to the user.

## Expected RepoDepot Env Keys

Load these from `current_workspace\RepoDepot\.env` when present. Treat aliases as acceptable because older projects may use different names.

Gitea API:
- `RD_GITEA_BASE_URL` or `GITEA_BASE_URL`
- `RD_GITEA_ADMIN_TOKEN`, `GITEA_ADMIN_TOKEN`, `RD_GITEA_TOKEN`, or `GITEA_TOKEN`
- `RD_GITEA_DEFAULT_BRANCH` or `GITEA_DEFAULT_BRANCH`
- `RD_GITEA_DEFAULT_OWNER`, `GITEA_DEFAULT_OWNER`, `RD_GITEA_ORG`, or `GITEA_ORG`
- `RD_GITEA_PROJECT_REPO_MAP`, when project-to-repository routing is needed

Deploy public key:
- `RD_GITEA_DEPLOY_PUBLIC_KEY`
- `GITEA_DEPLOY_PUBLIC_KEY`
- `COOLIFY_DEPLOY_PUBLIC_KEY`
- `ARES_DEPLOY_PUBLIC_KEY`
- Project-specific aliases such as `<PROJECT>_DEPLOY_PUBLIC_KEY`
- Optional public-key file path keys such as `RD_GITEA_DEPLOY_PUBLIC_KEY_FILE` or `<PROJECT>_DEPLOY_PUBLIC_KEY_FILE`

Repository defaults:
- `RD_GITEA_REPO_PRIVATE` or `GITEA_REPO_PRIVATE`
- `RD_GITEA_REPO_DESCRIPTION` or project-specific description keys
- `RD_GITEA_DEPLOY_KEY_READ_ONLY` or `GITEA_DEPLOY_KEY_READ_ONLY`

If a required key is missing, ask for the missing non-secret configuration name or have the user add it to RepoDepot `.env`. Do not invent endpoints, tokens, repository names, owners, or key material.

## Safe Env Loading Pattern

Use a parser that reads key/value pairs into memory without printing values. Keep the loaded object local to the repo setup step.

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
@("RD_GITEA_BASE_URL", "RD_GITEA_ADMIN_TOKEN", "GITEA_ADMIN_TOKEN", "RD_GITEA_DEPLOY_PUBLIC_KEY") | ForEach-Object {
	[pscustomobject]@{ Key = $_; Configured = [bool]$rdEnv[$_] }
}
```

## Repository Setup Procedure

### 1. Identify the Target

- Confirm the local project path, Gitea owner, repository name, default branch, repository visibility, and deploy public key source.
- Prefer existing project mappings from `RD_GITEA_PROJECT_REPO_MAP` when available.
- If there are multiple plausible owner/repo targets, ask one concise question before making API changes.

### 2. Resolve Gitea Configuration

- Load Gitea base URL and admin token from RepoDepot `.env` without printing values.
- Normalize the base URL by removing trailing slashes.
- Verify token presence with a safe `/api/v1/user` request and report only the authenticated username or configured flag, not the token.
- Determine whether the target owner is a user or organization before choosing the create endpoint.

### 3. Validate Local Git State

- Use `git status --short` and targeted diffs to review changes.
- Avoid `git remote -v` because remotes can contain credentials.
- If the remote URL must be inspected, redact credentials before showing it.
- Never overwrite user changes. Work with existing changes unless the user explicitly asks for a reset or revert.
- Do not commit or push unless the user explicitly asks for that follow-up.

### 4. Create Or Verify Repository

- Check whether `GET /api/v1/repos/{owner}/{repo}` returns the repository.
- If it exists, verify visibility, clone URLs, permissions, and default branch.
- If it does not exist, create it using the admin token:
  - For user-owned repos, prefer `POST /api/v1/admin/users/{username}/repos` when creating for a specific user.
  - For organization-owned repos, use `POST /api/v1/orgs/{org}/repos`.
  - Use `POST /api/v1/user/repos` only when the authenticated admin account itself should own the repo.
- Set only intentional fields such as `name`, `description`, `private`, `auto_init`, and `default_branch`.
- Do not create duplicate repos with similar names. Stop and ask if the intended owner/repo is ambiguous.

Example body for repository creation:

```powershell
$repoBody = @{
	name = $repoName
	description = $repoDescription
	private = $repoPrivate
	auto_init = $false
	default_branch = $defaultBranch
} | ConvertTo-Json -Depth 5
```

### 5. Configure Or Verify Deploy Public Key

- Resolve the deploy public key from an env value or a public-key file path.
- Validate that the public key starts with an accepted public key type such as `ssh-ed25519`, `ssh-rsa`, or `ecdsa-sha2-*`.
- Compute a non-secret fingerprint locally and report only the fingerprint.
- Check existing deploy keys with `GET /api/v1/repos/{owner}/{repo}/keys`.
- If a matching key already exists, report `already configured` with the key title and fingerprint.
- If no matching key exists, add it with `POST /api/v1/repos/{owner}/{repo}/keys`.
- Default to `read_only = true` for deploy keys unless the user explicitly needs a write-capable deploy key.
- If replacing a deploy key, remove only the specific old key after confirming title/fingerprint. Never delete unrelated keys.

Example deploy key body:

```powershell
$keyBody = @{
	title = $deployKeyTitle
	key = $deployPublicKey
	read_only = $readOnly
} | ConvertTo-Json -Depth 5
```

### 6. Configure Local Git Remote Safely

- Prefer SSH remotes that use the corresponding private key outside the repository.
- Do not embed admin tokens in remote URLs.
- If setting the remote, show only the sanitized remote URL.
- If the local repo has no git repository, ask before initializing it.
- If the user asks to push after setup, verify the branch and commit scope separately.

### 7. Final Report

Report only safe setup facts:

- Local project path
- Gitea owner/repo
- Default branch
- Repository created vs already existed
- Sanitized clone URL
- Deploy key title
- Deploy key read-only/write setting
- Deploy key fingerprint
- Any non-secret warnings or follow-up actions

Do not include token values, full `.env` lines, private key paths unless necessary, raw API payloads containing secrets, or credential-bearing URLs.

## First-Time Repository Wiring Checklist

Use this checklist when the project is not yet wired into Gitea/Coolify/Ares.

- RepoDepot `.env` contains Gitea base URL and a Gitea admin token.
- Target owner/repo is known and unambiguous.
- Repository exists with the expected visibility and default branch.
- Local git remote uses SSH or another credential-safe URL.
- Public deploy key is installed on the repository.
- Private deploy key is stored outside the repo and never committed.
- Coolify or other consumers know which private key corresponds to the installed public deploy key.
- Optional: Coolify application/resource points to the Gitea repository and branch.

## Failure Handling

- Missing env key: report the key name only and ask the user to add it to RepoDepot `.env`.
- Gitea auth failure: verify token presence and base URL without printing either value.
- Repo already exists under a different owner: stop and ask which owner is correct.
- Repository creation fails: report status code and safe error summary only.
- Deploy key already in use elsewhere: Gitea may reject duplicate keys. Report the safe error and ask whether to reuse the existing key, create a new key pair outside the repo, or remove the old association.
- Invalid public key: ask for the public key or public-key file path; never ask for the private key in chat.
- Remote configuration conflict: inspect sanitized remote names and ask before changing existing remotes.
- Branch mismatch: ask before changing default branch or pushing a new branch.

## Success Criteria

The setup is complete when the Gitea repository exists under the intended owner, the expected default branch and sanitized remote are known, and the repository has the intended public deploy key configured with the correct read-only/write setting.
