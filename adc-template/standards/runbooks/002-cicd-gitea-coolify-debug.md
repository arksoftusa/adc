# Runbook: Full CI/CD Setup + Debug Playbook (Gitea + Coolify)

## 1. Objective
Use this runbook to ensure:
- Push to target branch triggers deployment automatically.
- Deployment pipeline is observable and auditable.
- Failures can be isolated quickly (target: within 10 minutes).

## 2. Required Baseline Inputs
Define before setup:
- Gitea repository URL and owner/name.
- Coolify application identity (app name + app UUID).
- Deployment branch (production default: `main`).
- Trigger mode:
  - webhook-driven auto deploy (preferred)
  - API/manual deploy fallback
- Environment policy:
  - `main -> production`
  - `dev/* -> non-prod/staging`

## 3. Required Secrets and Environment Variables
Store in secure runtime configuration and never commit to Git:
- `GITEA_URL`
- `GITEA_TOKEN` (permission to manage repo hooks)
- `GITEA_WEBHOOK_SECRET`
- `COOLIFY_URL`
- `COOLIFY_API_TOKEN`

## 3.1 Preflight Gate (Mandatory Order)
Before any webhook/app configuration steps:
1. Confirm admin tokens exist: `GITEA_TOKEN` and `COOLIFY_API_TOKEN`.
2. Confirm CI/CD mode is enabled: `CICD=enabled` (legacy `CICD_Enabled=true` accepted).
3. Validate token health before proceeding:
  - Validate Gitea token with `GET /api/v1/user`.
  - Validate Coolify token with `GET /api/v1/applications`.
4. Only if all checks pass, continue with branch alignment and webhook setup.

## 4. Canonical Trigger Flow
Expected deployment chain:
1. Developer pushes to target branch.
2. Gitea emits push event.
3. Gitea webhook calls Coolify webhook endpoint.
4. Coolify queues deployment.
5. Coolify pulls target branch commit.
6. Build and startup run.
7. Health checks pass.
8. Deployment is considered successful.

## 5. One-Time Setup Procedure
Execute once per app:
1. Create/import app in Coolify and bind correct repository.
2. Set Coolify app branch to deployment branch.
3. In Gitea repo, create webhook:
   - event: push only
   - URL: Coolify app webhook endpoint
   - content type: `json`
   - secret: same value used by Coolify
4. Run webhook test delivery from Gitea and require HTTP 2xx.
5. Confirm deployment appears in Coolify deployment list.
6. Run one API-triggered deployment as fallback validation.

## 6. Common Root Causes (Priority Order)
1. Coolify app branch does not match pushed branch.
2. Webhook secret mismatch between Gitea and Coolify.
3. Wrong webhook URL/path.
4. Gitea -> Coolify network/TLS/firewall issue.
5. Tokens exist in local `.env` but no setup process actually uses them.
6. Webhook disabled or filtered by wrong branch.

## 7. Fast Debug Sequence (Follow In Order)
### Step A: Verify Git state
- Confirm latest commit exists on remote target branch.
- Confirm push branch matches deployment branch policy.

### Step B: Verify Coolify app config
- Correct repo is bound.
- `git_branch` equals deployment branch.
- App is active and not paused.

### Step C: Verify Gitea webhook config
- `active = true`
- events = push only
- `branch_filter` matches target branch
- webhook URL and secret are correct

### Step D: Verify event delivery
- Run "Test Delivery" in Gitea.
- Require HTTP 2xx.
- If not 2xx, inspect response body and fix URL/secret/network.

### Step E: Verify Coolify queue
- A new deployment record appears.
- Commit SHA matches pushed SHA.
- Locate failure stage: pull/build/runtime/health-check.

### Step F: Fallback API deploy test
- Trigger deployment via Coolify API.
- If API deploy works but webhook deploy does not: issue is webhook path/config.
- If API deploy also fails: issue is app config, build runtime, or health checks.

## 8. Security Concerns and Required Mitigations
- Do not use broad admin tokens unless absolutely required; prefer scoped service tokens.
- Never print secrets in logs or terminal output.
- Rotate `GITEA_TOKEN`, `COOLIFY_API_TOKEN`, and `WEBHOOK_SECRET` on schedule and after exposure risk.
- Restrict webhook to push event and production branch filter.
- Ensure webhook endpoint uses HTTPS with valid TLS.
- Keep `.env` and CI secret stores access-limited by least privilege.
- Maintain immutable deployment and webhook delivery audit logs.
- Verify rollback path before production go-live.

## 9. Production Readiness Gate
Before go-live:
1. Push a test commit to deployment branch.
2. Confirm auto-deploy triggers without manual action.
3. Confirm deployed commit SHA matches pushed SHA.
4. Confirm health checks pass.
5. Confirm rollback path has been tested.
6. Document branch policy, webhook URL, and secret ownership in operations docs.
