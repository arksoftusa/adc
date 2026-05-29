# DevOps Workflow Policy

## Branching and Check-In Rules
- **No Direct Check-In to `main`**: Direct commits or direct pushes to the `main` branch are forbidden.
- **Required Development Branch**: All code check-ins MUST be performed on a dedicated development branch named `dev/<scope>` (or `dev/<scope>-<ticket>`).
- **Merge Path**: Changes MUST be merged into `main` only through a reviewed Pull Request.
- **CPMD Main Merge Requirement**: Every CPMD source branch MUST be merged into `main`; deployment from an unmerged `dev/*`, `hotfix/*`, or feature branch does not satisfy CPMD.
- **CPMD Branch Cleanup Requirement**: After successful merge into `main`, the CPMD source branch MUST be deleted from the remote and local repository. If deletion is blocked, the CPMD result MUST report cleanup as blocked with the exact source branch and required human action.
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

## RD Port Registry Policy
- **Mandatory Registration**: Every ADC-managed project MUST register every owned, exposed, or reserved port in RepoDepot before the port is used.
- **Scope**: Register development, test, staging, production, CI, and local-remote ports, including web servers, APIs, WebSocket endpoints, reverse proxies, health, metrics, admin endpoints, Docker Compose published ports, project-owned databases, caches, message brokers, and reserved dynamic ranges.
- **Required Fields**: Each RD record MUST include `project_id`, service name, environment, protocol, bind host/interface, host port, container port or internal port, purpose, exposure scope (`local`, `LAN`, `public`, or `container-only`), source config path, owner, and last verified date.
- **Conflict Gate**: No new or changed port may be introduced until RD confirms that the port is available for the target environment. Conflicts MUST be resolved in RD before code or configuration merge.
- **Lifecycle**: Retire or update RD port records in the same change that removes, repurposes, or moves a port.
- **Exception Handling**: If RD is unavailable, do not merge or deploy the port change. A temporary exception requires explicit human approval and MUST be captured in the PR notes.

## RD Edge Agent and RD MCP Use Policy
- **Responsibility Split**: `rd-edge-agent/` is for local orchestration artifacts (task queues, scratchpad notes, MCP wiring). RD MCP is for programmatic integration/retrieval against RepoDepot services.
- **Execution Policy**: RD MCP MUST NOT be used to replace local compile, lint, unit test, or integration test execution. Build/test must run through project-native tooling.
- **Authority Policy**: Outputs from RD Edge Agent scratchpad/tasks are operational context, not product truth. Canonical product rules remain in constitution/convention/planning files.
- **Network Policy**: Local RD services are expected on localhost endpoints; upstream RepoDepot access MUST use the configured upstream URL and approved credentials only.
- **Secret Policy**: Tokens and project identifiers (`RD_MCP_TOKEN`, `RD_EDGE_AGENT_TOKEN`, `RD_PROJECT_ID`) MUST be injected via environment variables and never committed to repository files.
- **Change Policy**: Any PR changing RD integration behavior MUST update both `bootstrap.md` and `mcp-servers.json`, and include validation notes.

## Toolchain Verification Policy
- **Install Or Activate Missing Tools**: If a required validation tool is missing from `PATH`, agents MUST first try to locate and activate an existing installation before skipping the validation. On Windows, use Visual Studio discovery such as `vswhere` to locate tools like `dumpbin.exe`.
- **Install When Absent**: If the tool is not installed and the environment permits installation, install the required toolchain, such as Visual Studio Build Tools with the C++ build tools workload for `dumpbin`, then rerun the validation.
- **No Premature Validation Waiver**: Do not report validation as unavailable merely because the current shell lacks the command. A waiver is allowed only after locate/activation and install attempts fail, and the final report MUST include what was attempted and why it remained blocked.
- **Binary Release Evidence**: For portable or compiled release artifacts, dependency inspection tools such as `dumpbin /dependents` on Windows or the platform equivalent SHOULD be run when they are needed to prove runtime dependency claims.

## CI/CD Policy (Gitea + Coolify)

### Conditional Initialization Rule
- If `.env` includes `CICD=enabled` (or legacy `CICD_Enabled=true`), `GITEA_TOKEN`, and `COOLIFY_API_TOKEN`, the automation workflow MUST ask the user to confirm initialization before making CI/CD changes.
- Confirmation text MUST clearly state target repo, app name/UUID, deployment branch, and whether deployment test trigger is enabled.

### Baseline Inputs
- Git provider and repository URL MUST be defined using Gitea.
- Deployment target MUST include Coolify app name and app UUID.
- Production deployment branch is `main` unless explicitly overridden.
- Branch policy: `main -> production`, `dev/* -> staging/non-prod`.
- CPMD policy: source branches merge into `main`, then the merged source branch is deleted before CPMD is considered complete.

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
