# AI Prompt Rules

## Mandatory Core Rules
- Use absolute paths when importing modules.
- For every template or constitution update, increment README version and update README date in the same change.
- Do not bypass safety checks in `.adc/standards/conventions/security.md`.
- Follow Test-Driven Development (TDD) in `.adc/standards/conventions/testing.md`.
- Default frontend theme and layout should closely match `https://admin-demo.vuestic.dev`, with dark theme as the default.
- Do not introduce new third-party dependencies (for example, `npm install`, `pip install`) without explicit human authorization.
- Document progress, failed attempts, and environment issues in `.adc/rd-edge-agent/scratchpad/session.md` before concluding a task.
- Keep outputs deterministic for the same symbol and unchanged repository state.
- Treat the project as graph-first: before handling any task, call the `{SYSTEM_NAME}` interface to obtain global context through MCP.
- Use high-signal retrieval only: read interface definitions, upstream callers, downstream dependencies, and related configuration metadata instead of redundant code.
- Before modifying code, produce an impact analysis that identifies which modules will have cascading effects.
- Follow the current project design patterns in `{SYSTEM_NAME}` exactly, and strengthen static checks for privilege escalation or data leakage when the project is security-sensitive.

## Output Protocol
- Status header must be `[{SYSTEM_NAME} Indexing: Active]`.
- Topology feedback must briefly summarize the key dependency paths discovered through the graph.
- If a logic gap is detected, mark it prominently with `⚠️ Logic Gap`.

## Repository and Workflow Rules
- For new features, write tests first.
- For webpage-related project testing and UI validation, default to the VS Code built-in browser and its integrated tooling.
- Use the Browser Agent external browser plugin only in exceptional cases where the VS Code built-in browser cannot cover the scenario, and explicitly state the exception reason before using it.
- Keep source logic in `src/`, scripts in `src/scripts/`, tests in `src/tests/`, and docs in `docs/`.
- Web visualization library policy: dynamic state-machine indicators, including metro-style operational status views, MUST use `d3-tube-map`; ordinary node/edge graph displays MUST use AntV or ECharts; 2.5D simulated 3D graph/network views MUST use `sigma`.
- Use Python visualization stacks like PyViz/Holoviz/Panel/Bokeh only when the feature is primarily Python-driven and the application stack supports it.
- Keep visualization toolchains consistent within a feature, expose chart data through JSON APIs, and implement interactive updates on the client whenever possible.
- Explicit authorization is required before adding new charting/visualization dependencies beyond the existing approved stack.
- Do not commit secrets, tokens, or private keys.
- All Docker commands must use remote daemon `tcp://192.168.1.240:2375` via `DOCKER_HOST`.
- Never commit directly to `main`; use a `dev/*` branch and merge through review.
- For CPMD, merge the source branch into `main` and delete the merged source branch remotely and locally before considering the workflow complete.
- If `.env` contains `CICD=enabled` and both `GITEA_TOKEN` + `COOLIFY_API_TOKEN`, ask for explicit human confirmation before initializing CI/CD wiring.

## RD Use Policy
- Use `rd-edge-agent/` for local task orchestration and session context only.
- Use `mcp-servers.json` and RD MCP endpoints for indexed retrieval/integration workflows only.
- RD MCP must not replace local compile, lint, unit test, or integration test execution.
- Treat scratchpad/task outputs as operational context, not canonical product truth.
- Canonical rules must remain in `.adc/planning/`, `.adc/standards/`, and `.adc/knowledge/`.
- Before adding or changing servers, Docker Compose port mappings, reverse proxy routes, health/metrics/admin endpoints, or default environment port values, register or verify every project port in RD and resolve conflicts before merging or deploying.
- Inject `RD_MCP_TOKEN`, `RD_EDGE_AGENT_TOKEN`, and `RD_PROJECT_ID` via environment variables only.
- Never write RD credentials into tracked files.
- PRs changing RD integration behavior must update `.adc/bootstrap.md` and MCP server wiring, and include validation notes.

## RD Retrieval and Token Policy
- For non-trivial coding tasks, perform RD retrieval before editing files.
- Prefer FalkorDB Cypher traversal over Python loops for impact graph search.
- Required pre-edit sequence: `rd_index_incremental` -> `rd_query_impact_graph` -> `get_optimized_context` -> `rd_fetch_minimal_code`.
- Use incremental indexing for changed files; avoid full reindex for routine tasks.
- Retrieve context in order: impact graph -> optimized context -> minimal code.
- Use symbol-scoped or change-scoped queries; avoid whole-repository prompts.
- Start with conservative budgets (`800-1500`) and expand only when evidence is insufficient.
- Apply explicit `token_budget` limits and keep only direct dependencies, recent changes, and high-frequency call paths.
- Reuse previously selected minimal context across related follow-up questions instead of re-fetching broad context.
- If RD evidence is missing, report missing symbols/files first, then run one bounded fallback search.
- Keep answers evidence-first by citing minimal retrieved code context before proposing broad refactors.

## RD-First Trigger Conditions
- Cross-module changes.
- Noisy repository search or ambiguous ownership.
- Runtime errors where call chain/source owner is unclear.
- Requests expected to exceed a small context window.

## Allowed Exceptions
- Single-line edits with exact file and line already known.
- Pure formatting or comment-only updates.
- Emergency hotfixes where retrieval failure blocks immediate mitigation.
