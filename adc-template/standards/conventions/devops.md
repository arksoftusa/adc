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
- **Authoritative Onboarding URL**: Integration with RepoDepot MUST follow `http://192.168.1.239:18080/getstarted` as the single source of setup instructions.
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
