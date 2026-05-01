# DevOps Workflow Policy

## Branching and Check-In Rules
- **No Direct Check-In to `main`**: Direct commits or direct pushes to the `main` branch are forbidden.
- **Required Development Branch**: All code check-ins MUST be performed on a dedicated development branch named `dev/<scope>` (or `dev/<scope>-<ticket>`).
- **Merge Path**: Changes MUST be merged into `main` only through a reviewed Pull Request.
- **Pre-Merge Gates**: Required CI checks and policy checklist validation MUST pass before merge.
- **Hotfix Exception**: Emergency hotfixes may use `hotfix/<scope>` branches, but direct commits to `main` are still forbidden.

## Deploy Key Handling Policy
- **Documentation Location**: The active public deploy key MUST be recorded in `docs/deploy_key.md`.
- **Preferred Source**: Reuse an existing approved public deploy key when available.
- **Fallback Generation**: If no approved deploy key exists, generate a new SSH key pair without passphrase and record the public key in `docs/deploy_key.md`.
- **No Private Key in Repo**: Private keys MUST NEVER be committed to the repository.
- **Rotation Update**: When deploy keys rotate, `docs/deploy_key.md` MUST be updated in the same change set.

## RepoDepot Integration Policy
- **Authoritative Onboarding URL**: Integration with RepoDepot MUST follow `http://192.168.1.240:18080/getstarted` as the single source of setup instructions.
- **No Unreviewed Deviation**: Agents and developers MUST NOT use alternate RepoDepot onboarding flows unless explicitly approved in the same PR description.
- **Traceability Requirement**: Any PR that introduces or changes RepoDepot integration MUST include a short "RepoDepot integration notes" section describing what step(s) from the onboarding URL were applied.
- **MCP Alignment**: If RepoDepot integration adds or changes external service endpoints or credentials, `mcp-servers.json` MUST be updated in the same change set.

## RD Edge Agent and RD MCP Use Policy
- **Responsibility Split**: `rd-edge-agent/` is for local orchestration artifacts (task queues, scratchpad notes, MCP wiring). RD MCP is for programmatic integration/retrieval against RepoDepot services.
- **Execution Policy**: RD MCP MUST NOT be used to replace local compile, lint, unit test, or integration test execution. Build/test must run through project-native tooling.
- **Authority Policy**: Outputs from RD Edge Agent scratchpad/tasks are operational context, not product truth. Canonical product rules remain in constitution/convention/planning files.
- **Network Policy**: Local RD services are expected on localhost endpoints; upstream RepoDepot access MUST use the configured upstream URL and approved credentials only.
- **Secret Policy**: Tokens and project identifiers (`RD_MCP_TOKEN`, `RD_EDGE_AGENT_TOKEN`, `RD_PROJECT_ID`) MUST be injected via environment variables and never committed to repository files.
- **Change Policy**: Any PR changing RD integration behavior MUST update both `bootstrap.md` and `mcp-servers.json`, and include validation notes.

## CI/CD Policy (Gitea + Coolify)

### Conditional Initialization Rule
- If `.env` includes `CICD=enabled` (or legacy `CICD_Enabled=true`), `GITEA_TOKEN`, and `COOLIFY_API_TOKEN`, the automation workflow MUST ask the user to confirm initialization before making CI/CD changes.
- Confirmation text MUST clearly state target repo, app name/UUID, deployment branch, and whether deployment test trigger is enabled.

### Baseline Inputs
- Git provider and repository URL MUST be defined using Gitea.
- Deployment target MUST include Coolify app name and app UUID.
- Production deployment branch is `main` unless explicitly overridden.
- Branch policy: `main -> production`, `dev/* -> staging/non-prod`.

### Trigger and Fallback Model
- Preferred mode is **Webhook-driven auto deploy** on push events for target branch.
- Fallback mode is Coolify API/manual deployment trigger.
- Canonical trigger chain: push -> Gitea push event -> webhook delivery -> Coolify queue -> build/startup -> health check pass.

### Secret and Security Controls
- Required environment variables: `GITEA_URL`, `GITEA_TOKEN`, `COOLIFY_URL`, `COOLIFY_API_TOKEN`.
- Recommended variable: `WEBHOOK_SECRET` for explicit secret ownership and rotation.
- Admin tokens MUST NOT be logged, echoed, or written to tracked files.
- Tokens MUST use least privilege and be scoped to repo-hook management (Gitea) and deployment operations (Coolify).
- CI/CD setup jobs MUST fail closed if webhook secret synchronization fails.
- Webhook events MUST be restricted to push events and branch-filtered to target branch.
- CI/CD setup output MUST provide an auditable summary without exposing sensitive values.

### Required Validation Sequence
- Validate Gitea token with `GET /api/v1/user`.
- Validate Coolify token with `GET /api/v1/applications`.
- Ensure Coolify app branch equals deployment branch.
- Create or update Gitea webhook with push-only events and matching secret.
- Execute webhook test delivery and require HTTP 2xx.
- Verify deployment appears in Coolify queue and commit SHA matches pushed SHA.

## Docker Compose Health Check Policy
- Every service in every `docker-compose.yml` / `docker-compose.yaml` file MUST include the following health check block (unless a stricter service-specific endpoint is explicitly approved):

```yaml
healthcheck:
	test:
		- CMD
		- curl
		- '-f'
		- 'http://localhost:8000/health'
	interval: 30s
	timeout: 10s
	retries: 3
	start_period: 40s
```
