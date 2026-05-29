---
name: cpmd
description: "Use when the user requests CPMD, CPMP, or checkin/push/merge/deploy for an ADC-managed project: validate changes, check in intended files, push the source branch, merge it into main, delete the source branch, then deploy through the configured CI/CD pipeline. Keywords: CPMD, CPMP, checkin, check-in, commit, push, merge, branch cleanup, deploy, CI/CD, Gitea, Coolify, Ares."
argument-hint: "project path, commit message, branch, deploy target"
user-invocable: true
disable-model-invocation: false
---

# CPMD

Use this skill for the ADC workflow abbreviation **CPMD**: **Checkin/Push/Merge/Deploy**. ADC terminology defines CPMD as the release workflow that checks in changes on a source branch, pushes that source branch, merges it into `main`, deletes the source branch, then deploys through the configured CI/CD pipeline.

This skill is a workflow coordinator. For Ares deployments, use the deployment phase rules from the `ares-deployment` skill, especially the Gitea, Coolify, RepoDepot `.env`, SSH, monitoring, and secret-handling requirements.

## Goal

Move an intended local change set from working tree to deployed environment with traceability and without bypassing repository policy:

1. Validate the target repository, current branch, change set, and deployment target.
2. Run the smallest meaningful verification required for the change.
3. Check in only intended files with a clear commit.
4. Push the commit to the configured remote source branch.
5. Merge the source branch into `main` through the project-approved path.
6. Delete the merged source branch from the remote and local repository.
7. Deploy through the configured CI/CD pipeline and verify the result.
8. Report safe evidence: commit hash, source branch, merge target, branch deletion status, deployment status, URL or health result, and any blocked step.

## Use When

- The user says `CPMD`, `CPMP`, or `checkin/push/merge/deploy`.
- The user asks to check in work, push it, merge it, and deploy it as one workflow.
- The user asks to ship a completed change and the project has an established CI/CD path.
- The user asks for an Ares/Gitea/Coolify deployment after local work is complete.

## Do Not Use When

- The user only wants a local preview, local edit, code review, or plan.
- The user asks for commit-only, push-only, or deploy-only work; use only the requested subset.
- The working tree contains unrelated changes that cannot be separated safely.
- Required deployment configuration or credentials are missing and the user has not approved a fallback.

## ADC Definition and Policy

ADC's template terminology defines CPMD as `Checkin/Push/Merge/Deploy`: stage and commit intended changes on a source branch, push that source branch, merge it into `main`, delete the merged source branch, then deploy via CI/CD.

Apply that definition through the active repository policy:

- In ADC-managed repositories, direct commits or direct pushes to `main` are forbidden unless the local project's own instructions explicitly say otherwise.
- Work should normally start on `dev/<scope>` or `hotfix/<scope>`.
- CPMD merge target is always `main` for ADC-managed projects.
- Merge into `main` must happen through the reviewed PR or approved merge path.
- After successful merge into `main`, delete the merged source branch from the remote and local checkout. Do not delete `main` or protected long-lived branches.
- If branch deletion is blocked by permissions, branch protection, or hosting policy, CPMD cleanup is incomplete; report the exact blocker and required human action.
- Production deployment is normally triggered by changes reaching `main`; `dev/*` branches are staging or non-production unless configured differently.
- If a non-ADC repository explicitly uses direct `origin/main` pushes, confirm the target before using the glossary shorthand literally.

## Preflight Checklist

Before modifying git state or triggering deployment:

- Identify the exact repository root in multi-root workspaces.
- Read project-local instructions such as `.github/copilot-instructions.md`, `AGENTS.md`, `.adc/index.md`, `.adc/prompt-rules.md`, and deployment docs when present.
- Inspect `git status --short`, current branch, and recent commits.
- Review the diff for the intended scope.
- Do not overwrite, revert, or stage unrelated user changes.
- Confirm the deploy target, public URL, CI/CD provider, and target branch if there is any ambiguity.
- Verify that `.env`, private keys, token dumps, generated secret logs, and temporary credential files are not staged.

## Verification Rules

- Run project-native tests, lint, type checks, or builds that match the risk of the change.
- For documentation-only or customization-only edits, a syntax/readback check may be enough; state that no runtime tests were needed.
- For frontend or TypeScript changes, run the repository's build command when available.
- Do not fix unrelated failures unless they block CPMD; report them clearly instead.
- Do not use RD MCP or deployment systems as a substitute for local build/test verification.

## Execution Procedure

### 1. Checkin

- Use `git status --short` and targeted diffs to confirm the intended files.
- ADC shorthand says `git add -A`; use it only when all working-tree changes belong to the requested CPMD scope.
- If unrelated changes exist, stage only the intended paths and report that you intentionally narrowed the staging set.
- Commit with a clear message tied to the change and deployment purpose.
- Capture the commit SHA after the commit.

### 2. Push

- Push the current source branch to the configured remote.
- Avoid `git remote -v` because remote URLs can contain credentials.
- If a remote URL must be inspected, redact credentials before showing or logging it.
- If the push is rejected, inspect branch policy, local branch tracking, and remote state without rewriting history unless explicitly approved.

### 3. Merge

- Follow the repository's approved merge path into `main`.
- For ADC-managed projects, prefer a reviewed PR or the configured Gitea/GitHub merge workflow.
- Do not bypass required checks, reviews, branch protection, or policy checklists.
- If automation cannot perform the required reviewed merge, stop after push and report the exact PR/merge gate that needs human action.
- Capture the merged commit SHA or merge request/PR identifier when available.

### 4. Branch Cleanup

- After the source branch is merged into `main`, delete the remote source branch.
- Delete the local source branch after confirming the current checkout is no longer on that branch.
- Do not delete `main`, release branches, protected long-lived branches, or branches outside the CPMD source branch.
- If cleanup cannot be completed automatically, report the source branch, remote deletion status, local deletion status, and exact blocker.

### 5. Deploy

- Let the configured CI/CD pipeline deploy after the target branch update.
- For Ares deployments, follow the `ares-deployment` skill: use Gitea push events, Coolify webhook/API fallback, RepoDepot `.env` values loaded without printing secrets, and low-frequency deployment monitoring.
- Do not manually trigger a duplicate deployment if the push already queued one, unless the user explicitly requests a forced redeploy.
- Verify the deployed public URL, internal health endpoint, or container status as appropriate.
- Summarize deployment status fields only; do not paste full deployment logs if they may contain secrets.

## Secret Handling Rules

- Never print, summarize, log, paste, commit, or expose token values from `.env` or credential stores.
- If environment discovery is needed, list key names or boolean `Configured` flags only.
- Use PowerShell variables, headers, or credential-safe APIs; avoid putting expanded secrets in command arguments.
- Do not embed tokens in git remotes, URLs, commit messages, PR text, issue text, or final responses.
- If command output includes a secret, do not repeat it; stop using that output and switch to a safer check.

## Failure Handling

- Dirty tree with unrelated changes: stage only intended files or ask one concise question if separation is unclear.
- Missing tests or build command: perform the best available syntax/readback check and report the limitation.
- Commit failure: inspect staged files, hooks, and identity configuration.
- Push failure: inspect branch tracking, auth state, branch protection, and remote availability.
- Merge blocked: report the failed gate, required review, or CI failure without bypassing it.
- Branch cleanup blocked: report whether remote deletion, local deletion, or both are blocked; include the source branch name and required human action.
- Deploy blocked: report the missing non-secret configuration key, unavailable CI/CD target, or failing phase.
- Runtime health failure: check public URL, health endpoint, container status, image/container identifiers, and recent non-secret status fields.

## Final Report

Report only safe, useful facts:

- Repository path and source branch.
- Files or change summary included in the checkin.
- Verification commands and results.
- Commit SHA.
- Push remote and branch, with credentials redacted if mentioned at all.
- Merge target and PR/merge status.
- Branch deletion status for both remote source branch and local source branch.
- Deployment target, status, URL or health-check result.
- Any blocked step and the exact human action needed.

Do not include token values, raw `.env` lines, private keys, raw deployment logs, or credential-bearing URLs.

## Success Criteria

CPMD is complete when the intended change set is committed, pushed, merged into `main` through the approved path, the merged source branch is deleted remotely and locally, deployment completes through the configured CI/CD pipeline, and the deployed result is verified with a passing health check or equivalent deployment evidence.