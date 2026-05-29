---
name: rd-reindex
description: "Use when refreshing an already onboarded RepoDepot/RD project index after source, docs, ADC context, config templates, or metadata changed: verify project-scoped auth, select changed files safely, run bounded incremental indexing, and validate affected graph/search coverage. Keywords: RD reindex, RD incremental index, rd_index_incremental, changed files, refresh index, project-scoped key, actual workspace path."
argument-hint: "project id, workspace path, and changed file scope"
user-invocable: true
disable-model-invocation: false
---

# RD Incremental Reindex

Use this skill to refresh an existing RD index for an already onboarded ADC-managed project. The default path is incremental or bounded changed-file indexing, not a full project rebuild.

For first-time RD project/key/MCP setup, use `rd-onboard`. For a complete graph/content rebuild, use `rd-full-index` only when the user explicitly asks for a full index or the existing graph is empty/corrupt.

## Scope

In scope:

1. Resolve project identity, workspace path, and changed-file scope.
2. Verify project-scoped RD authorization without printing key values.
3. Verify RD MCP health and expected incremental indexing tools when MCP is used.
4. Select changed files safely from the actual workspace path.
5. Run `rd_index_incremental` or the approved bounded reindex path.
6. Validate affected graph/search coverage with safe sample evidence.
7. Report stale/missing coverage and escalate to `rd-full-index` only when justified.

Out of scope:

1. Creating RD project records or project-scoped keys. Use `rd-onboard`.
2. Full graph rebuilds unless explicitly requested. Use `rd-full-index`.
3. Application code edits or deployments.
4. Indexing unrelated repositories or Docker-only paths.
5. Printing raw graph dumps, `.env` contents, tokens, or secret-bearing source excerpts.

## Use When

- The user asks to refresh, reindex, or update RD context for an existing project.
- Source, tests, docs, ADC files, or configuration templates changed after the last index.
- RD retrieval misses recently changed files or symbols.
- A CPMD or substantial edit needs RD graph/search refreshed without rebuilding the whole project.
- The RD-first workflow needs `rd_index_incremental` before impact graph and minimal context retrieval.

## Do Not Use When

- The project has not completed `rd-onboard`.
- The user explicitly requested a full project index or graph rebuild.
- Existing graph state is empty/corrupt and incremental indexing cannot repair it.
- The target path is missing or only a Docker/container substitute is visible.
- The request is only a single-line edit with exact file/line and no RD refresh is needed.

## Required Inputs

Required:

- `project_id` as stored by RD.
- Absolute development-machine workspace path, for example `D:\Repos\ARKSOFT\ADC`.
- Project `.env` path that contains RD project identity and key names.
- Changed-file scope or permission to derive it from git.

Optional:

- Base ref or comparison ref for changed files.
- Explicit include/exclude paths.
- Expected symbols or files for validation.
- MCP server config path.

## RD Project Information Sources

Use these sources in this order:

1. The user's explicit project ID, workspace path, and changed-file scope.
2. Target project `.adc/index.md` and `.adc/prompt-rules.md`.
3. Target project ignored `.env` key names, never values.
4. RD project record and existing index status.
5. Project-local MCP config such as `.adc/rd-edge-agent/mcp/mcp-servers.json`.
6. Git tracked-file changes or explicitly provided path list.

Do not infer project identity from RepoDepot's `.env` unless RepoDepot itself is the target project.

## Strict Key Policy

- Reindexing an existing project must use `RD_PROJECT_API_KEY_<PROJECT_ID_SUFFIX>` for the requested `project_id`.
- `RD_API_KEY` is a shared/bootstrap key only and must not authorize project reindex operations.
- A `403` from the bootstrap key against an existing project is expected in strict mode.
- Never use a generic `RD_PROJECT_API_KEY` as a cross-project shortcut.
- Never pass project API keys as command-line arguments; use `.env`, process environment, headers, stdin, or MCP transport.

## Secret Handling Rules

- Never print token values from `.env`, API responses, logs, browser snapshots, or terminal output.
- Never echo full `.env` lines.
- Report only key names and configured flags.
- Exclude `.env`, private keys, secret stores, token dumps, credential screenshots, and secret-bearing logs from changed-file indexing.
- Keep evidence to safe paths, counts, statuses, and non-secret metadata.

## Changed-File Selection Rules

Prefer precise changed-file scopes:

1. User-provided path list.
2. Git tracked-file changes from the working branch against the agreed base.
3. Recently modified ADC/source/docs/config template paths when git state is unavailable.
4. A bounded include list approved by the user.

Avoid these patterns:

- Broad `git status --untracked-files=all` on large Windows workspaces when it may hang.
- Whole-repository reindex for routine edits.
- Indexing generated output, dependency folders, caches, logs, binaries, or secret files.
- Indexing files outside the actual workspace path.

For deleted or renamed files, use the RD-supported delete/tombstone/update path when available. If no delete path exists, report potential stale graph entries and validate search behavior.

## Incremental Reindex Procedure

### 1. Resolve Target Project

- Confirm `project_id`, workspace path, project `.env`, and changed-file scope.
- Confirm the workspace path exists on the development machine.
- Read target `.adc/index.md` and `.adc/prompt-rules.md` when present.
- If the requested paths are ambiguous, ask one concise clarification before indexing.

### 2. Verify RD Project Access

- Load the target project `.env` into memory without printing values.
- Confirm `RD_PROJECT_ID` matches the requested `project_id`.
- Confirm the matching `RD_PROJECT_API_KEY_<PROJECT_ID_SUFFIX>` exists by key name only.
- Check RD health and project status with the project-scoped key.
- If MCP is used, verify `initialize`, `tools/list`, `health_check`, and `rd_index_progress` for the target project.

### 3. Build A Safe Change Set

- Resolve changed files relative to the actual workspace path.
- Drop files excluded by `.gitignore`, `.adcignore`, or secret/noisy path policy.
- Normalize path separators and keep paths project-relative in reports.
- If the change set is too large for incremental indexing, summarize the count and ask whether to continue bounded reindexing or switch to `rd-full-index`.

### 4. Run Incremental Index

Use the approved RD path for the project environment:

- `rd_index_incremental` through RD MCP when available.
- RepoDepot CLI or local edge-agent path when it reads the actual workspace directory.
- Direct RD API only if project-scoped auth and payloads are safe.

Send file contents or file paths only through safe channels. Keep project keys out of argv and logs. Record the run ID, project ID, workspace path, and safe changed-file count.

### 5. Refresh Impact Context When Needed

For non-trivial coding tasks that will continue after reindexing, follow the RD retrieval sequence:

1. `rd_index_incremental`
2. `rd_query_impact_graph`
3. `get_optimized_context`
4. `rd_fetch_minimal_code`

Use symbol-scoped or change-scoped queries and explicit token budgets. Do not use full repository prompts when minimal graph context is enough.

### 6. Validate Affected Coverage

Validate with project-scoped authorization:

- Reindex operation terminal state or safe final status.
- Updated graph/search evidence for changed files.
- Symbol/path lookups for changed source, tests, docs, and ADC files.
- Existing graph stats if needed to distinguish stale progress counters from real missing content.

If `rd_index_progress` reports idle or zero indexed but graph/search has the changed files, report both facts and use graph/search evidence as the coverage proof.

### 7. Record Safe Evidence

When the target project policy expects it, append a short operational note to `.adc/rd-edge-agent/scratchpad/session.md` with:

- Date/time.
- Project ID.
- Workspace path.
- Changed-file count and safe sample paths.
- Reindex status and validation result.
- Blockers or follow-up actions.

Do not write secrets or raw logs.

## Safe Output Format

Final output should include:

- Project ID and workspace path.
- Changed-file scope and safe count.
- Project key-name presence flags only.
- MCP health status if MCP was used.
- Reindex operation status and run ID if available.
- Validation evidence: safe sample paths, graph/search result status, and affected symbol checks.
- Any paths skipped by policy.
- Any blocked step and exact human action needed.

Do not include raw tokens, raw `.env`, private keys, credential-bearing URLs, full logs, or raw graph dumps.

## Failure Handling

- Missing RD project or project key: stop and use `rd-onboard`.
- `403` with project key: verify the MCP process loaded the target project `.env`, the key belongs to the requested project, and the control-plane project secret is current.
- `403` with bootstrap key: treat as expected strict-mode behavior for an existing project.
- Path visibility failure: fix the real workspace path, mount, or local edge-agent indexing path; do not index a substitute repository.
- Change set too broad: ask whether to narrow paths or switch to `rd-full-index`.
- Deleted files still appear in graph/search: use the RD-supported delete/tombstone path or report stale entries clearly.
- Empty graph/search result after incremental indexing: compare progress counters, graph stats, and sample lookups before declaring failure.
- Resource pressure: stop the reindexer and report the last safe progress state.

## Success Criteria

RD reindexing is complete when:

1. The target project uses project-scoped RD authorization.
2. The changed files come from the actual development-machine workspace directory.
3. Incremental indexing reaches success or a clearly reported terminal state.
4. Graph/search evidence includes safe references to changed files or affected symbols.
5. Secret/noisy paths are excluded.
6. The final report includes safe counts, sample evidence, skipped paths, and follow-up actions.