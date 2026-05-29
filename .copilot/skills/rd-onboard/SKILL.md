---
name: rd-onboard
description: "Use when onboarding or validating an ADC-managed project for RepoDepot/RD: workspace project folder, RD project record, project-scoped API key, RD MCP server config, MCP health, and actual workspace-path indexing. Keywords: RD onboard, RepoDepot onboarding, RD MCP, project API key, RD_PROJECT_API_KEY, rd_index_progress, index project, strict auth, actual workspace path."
argument-hint: "project id/name and workspace project path"
user-invocable: true
disable-model-invocation: false
---

# RD Project Onboarding

Use this skill when a project needs RepoDepot (RD) context, indexing, project secrets, or RD MCP access. The workflow makes sure the project is represented in RD, uses a project-scoped key, has an RD MCP server wired through the project's ignored `.env`, and indexes the real workspace project directory instead of a Docker/container substitute.

This is not a deployment workflow. For Gitea repository creation, Ares CI/CD, Coolify deployment, or CPMD, use the matching workflow skill.

## Scope

This skill starts before any RD-backed retrieval, indexing, or MCP operation for a project and ends when project-scoped RD access is verified.

In scope:

1. Confirm the workspace contains the target project folder.
2. Confirm or create the RD control-plane project record.
3. Confirm or create the project-scoped RD API key.
4. Write required non-secret identifiers and secret key values to the project's ignored `.env` only.
5. Configure the project's RD MCP server entry to use RepoDepot's launcher and the project `.env`.
6. Verify MCP startup and project-scoped authorization.
7. Run a bounded indexing/status check against the actual workspace project path.

Out of scope:

1. Gitea/Coolify CI/CD setup or production deployment.
2. Application code edits unrelated to RD onboarding.
3. Indexing a different repository or Docker-only path as a substitute for the target project.
4. Printing, copying, or committing API keys or `.env` secret values.

## Use When

- The user asks to onboard a project to RD or RepoDepot.
- The user asks to test, fix, or validate an RD MCP server for a project.
- The user asks about RD project API keys, strict auth, `RD_PROJECT_API_KEY_<PROJECT_ID_SUFFIX>`, or missing project-scoped authorization.
- The user asks to index a project, inspect RD indexing state, or verify graph/search coverage.
- A new ADC-managed project is introduced and needs RD project/MCP wiring before retrieval or indexing.

## Do Not Use When

- The request is only for Gitea repository creation or deploy key setup; use the create-repo skill.
- The request is only for Ares CI/CD, Coolify deployment, or CPMD; use the matching workflow skill.
- The target project folder is not present in the current workspace and no approved path is provided.
- The user asks to bypass strict project auth or reuse a key from another project.

## Required Inputs

Required:

- Project ID/name as RD should store it.
- Absolute workspace path to the actual project directory on the development machine.
- Location of the RepoDepot checkout, usually `D:\Repos\ARKSOFT\RepoDepot`.
- The project's ignored `.env` path.

Optional:

- Existing RD project record identifier.
- Existing RD MCP config path.
- Approved project display name, repo URL, or owner metadata.

## Strict Key Policy

- `RD_API_KEY` is a shared/bootstrap key only.
- Use `RD_API_KEY` only for first contact when a project record or project-scoped key does not already exist.
- Once a project has an RD project key, `RD_API_KEY` must not read, reuse, rotate, revoke, or authorize operations for that project.
- Project operations must use the matching `RD_PROJECT_API_KEY_<PROJECT_ID_SUFFIX>` value for the requested `project_id`.
- Do not use a generic `RD_PROJECT_API_KEY` as a cross-project shortcut.
- Do not copy one project's key into another project's `.env`.
- A `403` from the bootstrap key against an existing project is expected in strict mode and confirms isolation.

## Secret Handling Rules

- Never print token values from `.env`, API responses, browser snapshots, deployment logs, or shell output.
- Never echo full `.env` lines.
- Only report key names and configured flags (`Configured=true/false`).
- Keep tokens in local variables, process environment, request headers, or ignored `.env` files only.
- Never put API keys in command arguments when process lists may expose them.
- Never commit `.env`, key dumps, secret-bearing logs, or screenshots containing credentials.

## Required Project `.env` Values

Every onboarded project should have these values in its ignored `.env`:

```dotenv
RD_API_BASE=http://192.168.1.240:18080
RD_REQUIRE_PROJECT_KEY_FOR_OPERATIONS=true
RD_PROJECT_ID=<PROJECT_ID>
RD_PROJECT_API_KEY_<PROJECT_ID_SUFFIX>=<project-scoped-key>
```

The suffix must be derived from the project ID in the convention used by RD. Examples: project `ADC` uses `RD_PROJECT_API_KEY_ADC`; project `SysRelay` uses `RD_PROJECT_API_KEY_SYSRELAY`.

## MCP Server Requirement

Each onboarded project should have an RD MCP server entry under a project-local ADC path such as `.adc/rd-edge-agent/mcp/mcp-servers.json`. Use RepoDepot's launcher so project identity and key come from the project's ignored `.env`:

```json
{
  "servers": [
    {
      "name": "rd-mcp",
      "transport": "stdio",
      "command": "D:\\Repos\\ARKSOFT\\RepoDepot\\.venv\\Scripts\\python.exe",
      "args": [
        "D:\\Repos\\ARKSOFT\\RepoDepot\\scripts\\repodepot\\rd-mcp-launch.py",
        "--repo-root",
        "D:\\Repos\\ARKSOFT\\RepoDepot",
        "--env-path",
        "D:\\Repos\\ARKSOFT\\<PROJECT>\\.env",
        "--project-id-from-env"
      ],
      "cwd": "D:\\Repos\\ARKSOFT\\RepoDepot",
      "autoStart": true,
      "enabled": true
    }
  ]
}
```

## Onboarding Procedure

### 1. Resolve Target Project

- Confirm the workspace contains the target project folder.
- Resolve the project ID from approved ADC metadata, the user's explicit request, or existing RD project records.
- Confirm the actual development-machine project path, for example `D:\Repos\ARKSOFT\SysRelay`.
- Do not treat Docker-internal paths such as `/app`, `/workspace/repo`, or `/host/repos/...` as authoritative unless they are verified mounts of the same workspace directory.

### 2. Check RD Project Record

- Query RD control-plane/API for the project record using the project ID.
- If the project is missing, create or register it through the approved RD control-plane path.
- Record only safe metadata: project ID, display name, status, and public/non-secret URLs.
- Do not assume a shared/global key can operate on an existing project.

### 3. Establish Project Key

- Check the project's ignored `.env` for `RD_PROJECT_ID` and `RD_PROJECT_API_KEY_<PROJECT_ID_SUFFIX>` by key name only.
- If the project has no key, use the bootstrap path once to create the missing project-scoped key.
- Store the returned key only in the project's ignored `.env` or an approved secret store.
- After the project key exists, validate that project operations use that key and not `RD_API_KEY`.

### 4. Wire MCP Server

- Confirm or create `.adc/rd-edge-agent/mcp/mcp-servers.json` for the project.
- Configure the RepoDepot launcher with `--env-path <project>\.env` and `--project-id-from-env`.
- Ensure the MCP process inherits the project `.env`, not RepoDepot's generic `.env`, unless RepoDepot itself is the target project.
- If there is a legacy compatibility mirror such as `.adc/agent-workspace/mcp/mcp-servers.json`, keep it aligned when the project expects it.

### 5. Verify MCP Health

Start the RD MCP server and verify, in order:

1. `initialize` returns server information.
2. `tools/list` includes expected RD tools.
3. `health_check` returns `ok` or equivalent healthy state.
4. A project-scoped status call such as `rd_index_progress` succeeds for the target `project_id`.
5. In strict mode, the same project-scoped operation does not succeed with only the shared/bootstrap key.

### 6. Index the Real Workspace Path

Indexing must target the current development machine's actual project directory content.

- Correct example: `D:\Repos\ARKSOFT\SysRelay` for the SysRelay project.
- Incorrect substitute: indexing RepoDepot, a Docker container checkout, `/app`, `/workspace/repo`, or any unrelated path because the RD API container cannot see the Windows path.
- If Docker-hosted RD cannot see the requested path, use a local content/edge-agent indexing path that reads the real workspace directory, or verify a host mount that maps to the same directory.
- Treat `repo_path visibility check failed` as a path visibility problem, not as permission to index the wrong repository.
- For large Windows workspaces, avoid workflows that run broad `git status --untracked-files=all` if they are known to hang; prefer explicit tracked-file or bounded incremental payloads when validating linkage.

### 7. Validate Index Coverage

- Check `rd_index_progress` and graph/chunk/search summaries with the project-scoped key.
- Use durable evidence such as total node/edge counts, sample expected files, and project graph name.
- If progress says `idle` and `indexed=0` but graph stats show content, report both facts; some local direct indexing paths do not update in-memory API progress counters.
- Verify a few known files or symbols from the target project are discoverable.
- Do not print raw graph dumps if they contain secrets or large source excerpts.

## Safe PowerShell Env Loading Pattern

Use key-name checks or in-memory maps without echoing secret values:

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

- Target project ID and workspace path.
- RD project record status.
- Project `.env` key-name presence flags only.
- MCP server config path and health status.
- Project-scoped authorization result.
- Indexing target path and validation result.
- Graph/index evidence such as counts and safe sample file paths.
- Any blocked step and exact human action needed.

Do not include raw tokens, raw `.env`, credential-bearing URLs, private keys, or full logs.

## Failure Handling

- Workspace folder missing: ask for the correct local project path or stop.
- RD project missing: create/register it through the approved RD control-plane path, or report the missing record if creation is not available.
- Missing project key: use the bootstrap path once, then store only in the project `.env`.
- `403` with project key: verify the MCP process is using the correct project `.env`, the key belongs to the requested project, and the control-plane project secret is current.
- `403` with bootstrap key on an existing project: treat as expected strict-mode behavior.
- MCP starts as the wrong project: fix `--env-path`, `RD_PROJECT_ID`, and `--project-id-from-env` wiring.
- Visibility failure during indexing: fix the real workspace path or local edge-agent indexing path; do not index a substitute repository.
- Empty search/index result: check graph stats and sample expected files before concluding the project is unindexed.

## Success Criteria

RD onboarding is complete when:

1. The target workspace folder is confirmed.
2. The RD project record exists for the approved project ID.
3. The project ignored `.env` contains `RD_PROJECT_ID` and the matching `RD_PROJECT_API_KEY_<PROJECT_ID_SUFFIX>`.
4. RD MCP starts with the project `.env` and passes `initialize`, `tools/list`, `health_check`, and a project-scoped status call.
5. Strict auth uses the project key for project operations and does not rely on the shared/bootstrap key.
6. Indexing or status validation targets the actual workspace project path and produces safe, project-specific evidence.
