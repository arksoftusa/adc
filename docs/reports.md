# Project Update Report

Date: 2026-03-26
Repository: Template Base

## Scope
This report captures the latest repository structure and convention updates requested during the current session.

## Completed Changes
1. Renamed the workspace folder from `agent-workspace` to `rd-edge-agent` under the template.
2. Added optional integration guidance:
   - Project registration guidance
   - Edge agent integration guidance
   - MCP server integration guidance
3. Standardized build output location to `dist`.
4. Added and standardized runtime log location at `logs/`.
5. Confirmed operational scripts remain in `src/scripts/` and test suite remains in `src/tests/`.
6. Added terminology glossary file with workflow and platform terms, including CPMD.

## Current Repository Structure
- Source code package: `src/backend/`
- Test suite: `src/tests/`
- Operational scripts: `src/scripts/`
- Runtime logs directory: `logs/`
- Public/project documentation: `docs/`
- Template source: `.templates/`

## Workflow Term
- CPMD: checkin, push, merge, deploy.

## Notes
- Changes above were applied to repository files and conventions so future generated templates align with the same structure.

## Security Exception Register
- ID: `CVE-2026-4539`
- Package: `pygments` (`2.19.2`)
- Scope: Temporary CI ignore in `pip-audit` only.
- Expiry: `2026-04-15` (hard-fail enforced in CI after this date).
- Owner: Repository maintainers.
- Required action: remove ignore and upgrade to a fixed version as soon as upstream publishes a patched release.
