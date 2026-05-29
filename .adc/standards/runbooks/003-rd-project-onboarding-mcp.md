# RD Project Onboarding and MCP Key Runbook

This runbook is mandatory for every ADC-managed project that uses RepoDepot (RD) context, indexing, project secrets, or MCP tools.

## Required Checks

Before using RD from a project workspace:

1. Confirm the workspace contains the target project folder.
2. Confirm RD control-plane has a matching project record for the approved project ID.
3. Confirm the project has an RD MCP server entry under `.adc/rd-edge-agent/mcp/mcp-servers.json`.
4. Confirm the project's ignored `.env` contains `RD_PROJECT_ID=<project-id>`.
5. Confirm the project's ignored `.env` contains the project-specific key variable: `RD_PROJECT_API_KEY_<PROJECT_ID_SUFFIX>`.
6. Start the RD MCP server and verify `initialize`, `tools/list`, `health_check`, and a project-scoped status call such as `rd_index_progress`.

## Key Policy

- `RD_API_KEY` is a shared/bootstrap key only.
- Use `RD_API_KEY` only for first contact when a project key does not already exist.
- Once a project key exists in RD, `RD_API_KEY` must not read, reuse, rotate, revoke, or authorize operations for that project key.
- Project tool calls must use the matching project-scoped key for the requested `project_id`.
- Do not use generic `RD_PROJECT_API_KEY` as a cross-project shortcut.
- Do not commit RD keys, admin keys, tokens, or project-specific `.env` files.

## Standard Onboarding Flow

1. Resolve the project ID from approved ADC metadata or workspace ownership.
2. Query RD control-plane for the project record.
3. If the project does not exist, create or register it through RD control-plane before indexing.
4. If the project exists but has no project key, use the bootstrap path once to create the missing key.
5. Store the returned project-scoped key in the project's ignored `.env` as `RD_PROJECT_API_KEY_<PROJECT_ID_SUFFIX>`.
6. Store `RD_PROJECT_ID=<project-id>` in the same ignored `.env`.
7. Configure the project MCP entry to launch RepoDepot's `scripts/repodepot/rd-mcp-launch.py` with `--env-path <project>/.env` and `--project-id-from-env`.
8. Verify MCP health and project-scoped authorization before any indexing or retrieval workflow.
9. Run the first bounded indexing/status check with the project key and record the result in the project's ADC scratchpad when available.

## MCP Server Template

Use the RepoDepot launcher so project identity and the project-scoped key come from the project's ignored `.env`:

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

## `.env` Template

```dotenv
RD_API_BASE=http://192.168.1.240:18080
RD_REQUIRE_PROJECT_KEY_FOR_OPERATIONS=true
RD_PROJECT_ID=<PROJECT_ID>
RD_PROJECT_API_KEY_<PROJECT_ID_SUFFIX>=<project-scoped-key>
```

For example, project `CICB` uses `RD_PROJECT_API_KEY_CICB`; project `ADC` uses `RD_PROJECT_API_KEY_ADC`.

## Validation Requirements

Use redacted checks only. Never print API key values or raw secret responses.

Minimum validation:

- MCP `initialize` returns server info.
- MCP `tools/list` returns expected RD tools.
- MCP `health_check` returns `ok`.
- Project-scoped status or indexing call succeeds with the matching project key.
- The same project-scoped operation rejects the shared/bootstrap key in strict mode.

## Failure Interpretation

- `403` with the project key usually means the MCP process is using the wrong `.env`, the key belongs to a different project, or the control-plane project secret is stale.
- `403` with `RD_API_KEY` on an existing project is expected and confirms strict isolation.
- Missing `RD_PROJECT_API_KEY_<PROJECT_ID_SUFFIX>` means onboarding is incomplete.
- `repo_path visibility check failed` means the RD API runtime cannot see the requested workspace path. Verify the container-visible path instead of disabling visibility checks by default.

## Security Notes

- Keep project keys in ignored `.env` files or a secret manager.
- Rotate only the affected project key if a project key is exposed.
- Do not copy a project key into another project's `.env`.
- Do not use browser screenshots, logs, or command output that expose RD key values as validation artifacts.
