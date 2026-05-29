---
name: adc-onboard
description: "Use when onboarding an existing or new project into ADC governance: create or repair .adc structure, project context files, prompt rules, standards, planning, knowledge, MCP wiring, IDE trigger files, and validation. Keywords: ADC onboard, initialize ADC, create .adc, project governance, ADC structure, ADC template, copilot instructions, adcignore."
argument-hint: "project path and project name"
user-invocable: true
disable-model-invocation: false
---

# ADC Project Onboarding

Use this skill to bring a project under the Autonomous Development Constitution (ADC). The goal is to create or repair the project's `.adc/` governance layer so future AI and human work starts from stable, project-local context.

This skill applies to target application repositories. For changing ADC itself, use `adc-update`. For RepoDepot project key/MCP/indexing setup, use `rd-onboard` as a sub-workflow after the basic ADC structure is present.

## Scope

In scope:

1. Confirm the target repository root in a multi-root workspace.
2. Inspect existing project facts from source, manifests, docs, and current ADC files.
3. Create or repair the required `.adc/` directory structure.
4. Populate project context, prompt rules, planning, standards, knowledge, runbooks, and MCP placeholders.
5. Add or update IDE trigger files and `.github/copilot-instructions.md` pointers.
6. Add `.adcignore` when needed to protect secrets, build output, caches, and generated files.
7. Validate that generated ADC context is factual, project-specific, and secret-free.

Out of scope:

1. Changing ADC's canonical templates or constitution rules. Use `adc-update`.
2. Creating RD project keys or indexing. Use `rd-onboard` after the ADC shell exists.
3. Running production deployment. Use CPMD or deployment skills.
4. Inventing architecture decisions, credentials, service URLs, or project status.

## Use When

- The user asks to onboard a project to ADC.
- A repository is missing `.adc/`, `.adc/index.md`, `.adc/prompt-rules.md`, or `.github/copilot-instructions.md`.
- A project has scattered planning/docs and needs normalized ADC context.
- A new project needs AI-readable governance before feature work begins.
- A project has stale CCS/context docs that should be represented through ADC.

## Do Not Use When

- The request is to update ADC's own reusable rules or templates.
- The request is only RD MCP/project-key setup.
- The user only wants a code change, bug fix, or deployment.
- The target path is ambiguous and cannot be resolved safely.

## Required Inputs

Required:

- Target repository path.
- Project name.
- Current project type or stack, if not discoverable from manifests.

Helpful optional inputs:

- Product purpose and audience.
- Active phase or current goal.
- Known no-touch areas.
- Existing deployment/runtime constraints.

## Canonical ADC Structure

Create or repair this structure at the project root:

```text
.adc/
+-- index.md
+-- prompt-rules.md
+-- bootstrap.md
+-- planning/
|   +-- status.md
|   +-- project-roadmap.md
|   +-- development-phases.md
+-- standards/
|   +-- conventions/
|   |   +-- structure.md
|   |   +-- frontend.md
|   |   +-- backend.md
|   |   +-- data-engineering.md
|   |   +-- performance.md
|   |   +-- observability.md
|   |   +-- security.md
|   |   +-- devops.md
|   |   +-- testing.md
|   +-- checklists/
|   |   +-- pr-review.md
|   +-- runbooks/
|       +-- 001-common-errors.md
+-- knowledge/
|   +-- glossary.md
|   +-- known-issues.md
|   +-- amendments.md
|   +-- diagrams/
|       +-- architecture.mmd
|       +-- data-flow.mmd
|       +-- schema.mmd
+-- rd-edge-agent/
    +-- mcp/
    |   +-- mcp-servers.json
    +-- scratchpad/
    |   +-- session.md
    +-- tasks/
    |   +-- todo/
    |   +-- in-progress/
    |   +-- done/
    +-- skills/
```

Root-level support files should include the applicable trigger pointers:

- `.adcignore`
- `.cursorrules`
- `.windsurfrules`
- `.clinerules`
- `.roomadesrules`
- `.aider.rules`
- `.codexrules`
- `.antigravityrules`
- `.codeiumrules`
- `.codyrules`
- `.github/copilot-instructions.md`

## Onboarding Procedure

### 1. Resolve Repository Root

- In multi-root workspaces, identify the exact target repository before reading or writing files.
- Confirm whether the repository already has `.adc/`, `.github/copilot-instructions.md`, `AGENTS.md`, CCS `.context/`, or other governance files.
- Do not overwrite user-authored governance files blindly; preserve useful project-specific facts.

### 2. Gather Existing Facts

Read only enough context to write accurate ADC files:

- README and product docs.
- Package manifests such as `package.json`, `pyproject.toml`, `Cargo.toml`, `requirements.txt`, `docker-compose.yml`, and Dockerfiles.
- Existing `.env.example`, config files, and deployment docs.
- Test folders and build scripts.
- Existing architecture docs, ADRs, diagrams, and known issues.

Do not read or print real `.env` values, private keys, token dumps, or secret logs.

### 3. Generate The ADC Shell

- Prefer the canonical ADC template/generator when working inside the ADC repository.
- For a target project, create only missing folders/files or carefully merge into existing ones.
- Keep `src/`, `docs/`, `tests/`, and application files as root-level siblings of `.adc/`; do not place application source under `.adc/`.
- Keep `rd-edge-agent/scratchpad/` and `rd-edge-agent/tasks/` as operational context only, not canonical product truth.

### 4. Populate Required Files

Minimum content requirements:

- `.adc/index.md`: YAML frontmatter with project name, version, description, tech stack, architecture style, and entry points; body with project overview, core modules, environment requirements, knowledge references, and ADC alignment notes.
- `.adc/bootstrap.md`: exact setup, install, test, and local run commands. Mark unknown commands as unknown instead of inventing them.
- `.adc/prompt-rules.md`: project-specific mandatory AI rules, workflow rules, security rules, RD use policy, and retrieval policy if applicable.
- `.adc/planning/status.md`: current phase, active goals, recent changes, and blockers.
- `.adc/planning/project-roadmap.md`: near-term and long-term milestones.
- `.adc/planning/development-phases.md`: actionable implementation phases.
- `.adc/knowledge/glossary.md`: project vocabulary and acronyms.
- `.adc/knowledge/known-issues.md`: technical debt and no-touch zones.
- `.adc/knowledge/amendments.md`: governance change log.
- `.adc/standards/conventions/*.md`: domain-specific rules only where relevant.
- `.adc/standards/checklists/pr-review.md`: pre-merge checklist.
- `.adc/standards/runbooks/001-common-errors.md`: known local/CI recovery steps.

### 5. Apply Core ADC Policies

Carry these defaults into the target project's ADC files unless project-local policy explicitly supersedes them:

- Keep source logic in `src/`, scripts in `src/scripts/` or the project's established scripts folder, tests in `tests/` or the established test root, and user-facing docs in `docs/`.
- Do not commit secrets, tokens, private keys, or real `.env` values.
- Declare new environment variables in `.env.example` with safe placeholder values.
- Prefer TDD for new features and run project-native tests before completion.
- Before adding or changing ports, verify or register project ports in RD.
- For CPMD, source branches must merge into `main` and then be deleted remotely and locally.
- For webpage testing, default to VS Code built-in browser tooling; use external Browser Agent only for explicit exceptions.
- For frontend visualization, use `d3-tube-map` for dynamic metro-style state-machine indicators, AntV or ECharts for normal node/edge graphs, and `sigma` for 2.5D graph/network views.
- RD MCP is for retrieval/indexing and external context operations; it must not replace local build, lint, unit test, or integration test execution.

### 6. Wire Tooling And Triggers

- Add or update `.github/copilot-instructions.md` to point agents to `.adc/index.md` first.
- Add IDE trigger files that instruct tools to load `.adc/index.md`, `.adc/prompt-rules.md`, and relevant standards.
- Add `.adcignore` to exclude `.env`, secrets, build output, dependency folders, logs, caches, and large generated assets.
- Add placeholder `.adc/rd-edge-agent/mcp/mcp-servers.json` when RD MCP is expected, but defer project key creation and indexing to `rd-onboard`.

### 7. Validate

- Confirm required files exist.
- Confirm `.adc/index.md` frontmatter is valid and factual.
- Confirm `.adc/prompt-rules.md` includes mandatory core rules and RD policy when applicable.
- Confirm no real secrets or credential-bearing URLs were added.
- Run project-native formatting/tests only if onboarding changed executable config or scripts.
- Record onboarding notes in `.adc/planning/status.md` or `.adc/knowledge/amendments.md` as appropriate.

## Failure Handling

- Missing project facts: write `Unknown` or ask one concise question; do not fabricate.
- Existing conflicting ADC files: preserve them and merge conservatively.
- Secret discovered in a tracked file: do not print it; report the file path and ask for rotation/remediation.
- RD unavailable: create ADC structure and note that RD onboarding remains blocked.
- Test/build command missing: report that validation was structural only.

## Safe Output Format

Final output should include:

- Target repository path.
- ADC files created or updated.
- Project facts used and any unknowns left unresolved.
- Validation performed.
- RD onboarding status or next step.
- Any blockers requiring human input.

## Success Criteria

ADC onboarding is complete when:

1. The target repository has the required `.adc/` structure and trigger files.
2. Required ADC files contain project-specific, factual content.
3. Secrets are excluded and `.adcignore` protects sensitive/noisy paths.
4. Local AI instructions point to `.adc/index.md` and `.adc/prompt-rules.md`.
5. RD/MCP placeholders are present when applicable, with project-key setup deferred to `rd-onboard`.
6. Validation confirms structure, frontmatter, and no obvious secret leakage.
