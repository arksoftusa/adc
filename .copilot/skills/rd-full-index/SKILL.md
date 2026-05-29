---
name: rd-full-index
description: "Use when running a full RepoDepot/RD index for an already onboarded project: verify RD project record, project-scoped API key, MCP health, actual workspace path visibility, full graph/content indexing, progress monitoring, and safe coverage validation. Keywords: RD full index, RepoDepot full index, index project, rd_index_full, rebuild graph, project-scoped key, actual workspace path."
argument-hint: "project id and absolute workspace path"
user-invocable: true
disable-model-invocation: false
---

# RD Full Project Index

Use this skill when an ADC-managed project already has RD identity and needs a complete RepoDepot/RD index from the real development-machine workspace directory.

For first-time RD project creation, project key setup, MCP wiring, or initial strict-auth validation, use `rd-onboard` first. For routine refresh after changed files, use `rd-reindex` instead of a full rebuild.

## Scope

In scope:

1. Resolve RD project identity and real workspace path.
2. Verify project-scoped RD authorization without printing secret values.
3. Verify RD MCP health and expected indexing tools when MCP is used.
4. Verify the indexer reads the actual workspace directory, not a Docker/container substitute.
5. Run the approved full content/graph index path for the target project.
6. Monitor progress with bounded, low-frequency checks.
7. Validate graph/search coverage with safe project-specific evidence.
8. Record safe operational notes when the target project policy expects scratchpad updates.

Out of scope:

1. Creating the RD project record or project API key. Use `rd-onboard`.
2. Routine changed-file incremental indexing. Use `rd-reindex`.
3. Application code edits, deployments, Gitea repository creation, or Coolify setup.
4. Indexing another checkout because the requested path is not visible.
5. Printing raw graph dumps, `.env` contents, API keys, or secret-bearing source excerpts.

## Use When

- The user explicitly asks for full RD indexing, full project indexing, graph rebuild, or first complete index after onboarding.
- Existing graph/search coverage is empty or clearly corrupt and a full rebuild is approved.
- A project moved paths and RD needs a complete rebuild from the current workspace folder.
- A project has completed `rd-onboard` but still needs durable graph/search coverage.

## Do Not Use When

- The project has no RD project record or project-scoped key yet.
- The request is only to refresh changed files or run RD retrieval before a code edit.
- The target workspace folder is missing.
- The only visible path is a Docker-internal path such as `/app` or `/workspace/repo` that has not been verified as the same host directory.
- The user asks to reuse a shared/bootstrap key for an existing project.

## Required Inputs

Required:

- `project_id` as stored by RD.
- Absolute development-machine workspace path, for example `D:\Repos\ARKSOFT\SysRelay`.
- Project `.env` path that contains RD project identity and key names.
- RepoDepot checkout path, usually `D:\Repos\ARKSOFT\RepoDepot`.

Optional:

- Existing graph name or prior graph stats.
- Expected files or symbols for validation.
- MCP server config path.
- Whether the full index should replace existing graph state or append/update it.

## RD Project Information Sources

Use these sources in this order:

1. The user's explicit project ID and workspace path.
2. Target project ADC files such as `.adc/index.md` and `.adc/prompt-rules.md`.
3. Target project ignored `.env` key names, never values.
4. RD project record from the RD API/control plane.
5. Project-local MCP config such as `.adc/rd-edge-agent/mcp/mcp-servers.json`.
6. Existing RD graph/index status such as `rd_index_progress`, graph stats, and safe sample file lookups.

Do not use RepoDepot's own `.env` as the target project's identity source unless RepoDepot itself is the target project.

## Strict Key Policy

- Full indexing for an existing project must use `RD_PROJECT_API_KEY_<PROJECT_ID_SUFFIX>` for the requested `project_id`.
- `RD_API_KEY` is a shared/bootstrap key only and must not authorize full indexing for an existing project.
- A `403` from the bootstrap key against an existing project is expected in strict mode.
- Never use a generic `RD_PROJECT_API_KEY` as a cross-project shortcut.
- Never copy a project key between projects.
- Never pass project API keys as command-line arguments; use `.env`, process environment, stdin, headers, or MCP transport.

## Secret Handling Rules

- Never print token values from `.env`, API responses, browser snapshots, logs, or terminal output.
- Never echo full `.env` lines.
- Only report key names and configured flags.
- Redact credential-bearing URLs and headers.
- Do not index `.env`, private keys, secret dumps, credential screenshots, or deployment logs that may contain secrets.
- Keep output limited to safe status, counts, paths, and non-secret metadata.

## Index Target Rules

Full indexing must read the actual workspace project directory content.

Correct examples:

- `D:\Repos\ARKSOFT\SysRelay` for the SysRelay project.
- `D:\Repos\ARKSOFT\ADC` for the ADC project.

Incorrect substitutes:

- RepoDepot when the target project is not RepoDepot.
- Docker-only paths such as `/app`, `/workspace`, `/workspace/repo`, or `/host/repos/...` unless verified as mounts of the same workspace directory.
- Temporary copies that do not match the working project.
- A different branch or checkout chosen only because it is easier for the container to see.

If Docker-hosted RD cannot see the Windows path, use a local edge-agent/content indexing path that reads the real workspace directory, or verify a host mount that maps to that same directory. Treat `repo_path visibility check failed` as a path visibility problem, not permission to index the wrong repository.

## File Selection Rules

- Respect `.gitignore`, `.adcignore`, and known secret/noisy path exclusions.
- Exclude `.env`, secret stores, private keys, virtual environments, dependency folders, build output, caches, logs, binary artifacts, and generated evidence unless explicitly approved and safe.
- Include source, tests, docs, ADC context, configuration templates, and project metadata needed for graph/search retrieval.
- For large Windows workspaces, avoid broad `git status --untracked-files=all` workflows when they are known to hang. Prefer tracked file lists, explicit include rules, or bounded content streaming.

## Full Index Procedure

### 1. Resolve Target Project

- Confirm `project_id`, display name, workspace path, and target `.env` path.
- Confirm the workspace path exists on the development machine.
- Read target `.adc/index.md` and `.adc/prompt-rules.md` when present.
- If project identity or path is ambiguous, ask one concise clarification before indexing.

### 2. Verify RD Project Access

- Load the target project `.env` into memory without printing values.
- Confirm `RD_PROJECT_ID` matches the requested `project_id`.
- Confirm the matching `RD_PROJECT_API_KEY_<PROJECT_ID_SUFFIX>` exists by key name only.
- Check RD health and the project record with the project-scoped key.
- If MCP is used, verify `initialize`, `tools/list`, `health_check`, and `rd_index_progress` for the target project.

### 3. Preflight Existing Index State

- Capture safe prior state: graph name, node count, edge count, chunk count, and last progress state if available.
- If the full index will delete or replace existing graph state and the user did not explicitly request that destructive operation, ask for confirmation.
- Confirm resource expectations for large repositories and stop if the system is under abnormal pressure.

### 4. Verify Workspace Visibility

- Check that the indexer can read the actual workspace path.
- If using remote Docker or an RD container, verify the mounted path maps to the same host directory.
- Do not proceed with a substitute repository.

### 5. Run Full Index

Use the approved RD path for the project environment:

- RD MCP tool if the project MCP server is healthy and exposes the full indexing operation.
- RepoDepot CLI or local edge-agent script when it reads from the real workspace directory.
- Direct RD API only if the project-scoped auth and path/content payloads are safe.

Keep keys out of argv and logs. Prefer env vars, request headers, or MCP stdio. Record the run ID, project ID, workspace path, and safe start timestamp.

### 6. Monitor Progress

- Poll progress at low frequency; avoid tight loops.
- Track status, indexed file count, skipped count, error count, graph stats, and last safe message.
- Stop on repeated auth failures, path visibility failures, resource pressure, or runaway retries.
- For long runs, rely on durable run artifacts/log summaries instead of assuming terminal completion means indexing succeeded.

### 7. Validate Coverage

Validate with project-scoped authorization:

- `rd_index_progress` terminal state or safe final status.
- Graph stats such as total nodes and edges.
- Search/query results for expected project files.
- Symbol or path lookups from source, tests, docs, and ADC files.
- If progress says idle or indexed zero while graph stats show content, report both facts and validate using graph/search evidence before declaring failure.

### 8. Record Safe Evidence

When the target project policy expects it, append a short operational note to `.adc/rd-edge-agent/scratchpad/session.md` with:

- Date/time.
- Project ID.
- Indexed workspace path.
- Run ID if available.
- Safe counts and validation sample paths.
- Blockers or follow-up actions.

Do not write secrets or raw logs.

## Safe PowerShell Env Loading Pattern

```powershell
$projectEnvPath = "D:\Repos\ARKSOFT\<PROJECT>\.env"
$rdEnv = @{}
Get-Content $projectEnvPath | ForEach-Object {
    if ($_ -match '^\s*#' -or $_ -notmatch '=') { return }
    $parts = $_ -split '=', 2
    $key = $parts[0].Trim()
    $value = $parts[1].Trim().Trim('"').Trim("'")
    if ($key) { $rdEnv[$key] = $value }
}
$rdEnv.Keys | Where-Object { $_ -like 'RD_*' } | ForEach-Object {
    [pscustomobject]@{ Key = $_; Configured = $true }
}
```

## Safe Output Format

Final output should include:

- Project ID and workspace path.
- RD project record status.
- Project key-name presence flags only.
- MCP health status if MCP was used.
- Full index start/end status and run ID if available.
- Graph/index evidence: safe node/edge/chunk counts and sample file paths.
- Skipped categories such as secrets, dependencies, caches, and generated output.
- Any blocked step and exact human action needed.

Do not include raw tokens, raw `.env`, private keys, credential-bearing URLs, full logs, or raw graph dumps.

## Failure Handling

- Missing RD project or project key: stop and use `rd-onboard`.
- `403` with project key: verify the MCP process loaded the target project `.env`, the key belongs to the requested project, and the control-plane project secret is current.
- `403` with bootstrap key: treat as expected strict-mode behavior for an existing project.
- Path visibility failure: fix the real workspace path, mount, or local edge-agent indexing path; do not index a substitute repository.
- Slow or hanging git scans: switch to tracked-file or bounded content indexing.
- Empty graph/search result: compare progress counters, graph stats, and sample file lookups before concluding the index is missing.
- Resource pressure: stop the indexer and report the last safe progress state.

## Success Criteria

Full RD indexing is complete when:

1. The target project uses project-scoped RD authorization.
2. The indexed path is the actual development-machine workspace directory.
3. The full index reaches a terminal success state or a clearly reported terminal state.
4. Graph/search evidence includes safe, project-specific files or symbols.
5. Secret/noisy paths are excluded.
6. The final report contains safe counts, sample evidence, and any follow-up actions.
