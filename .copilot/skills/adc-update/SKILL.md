---
name: adc-update
description: "Use when updating ADC's canonical constitution, templates, prompt rules, standards, skills, README version, amendments, or template quality tests. Keywords: ADC update, update ADC rules, constitution amendment, template update, prompt-rules, standards, conventions, amendments, README version, generate-adc-template, template quality tests."
argument-hint: "policy/rule to add or change"
user-invocable: true
disable-model-invocation: false
---

# ADC Standards Update

Use this skill when changing ADC itself: canonical rules, reusable templates, generated project skeletons, Copilot skills, prompt rules, standards, checklists, runbooks, README version metadata, or tests that protect ADC policy coverage.

This skill is for governance changes in the ADC repository. For applying ADC to another project, use `adc-onboard`. For RD project keys/MCP/indexing, use `rd-onboard`.

## Scope

In scope:

1. Update ADC canonical documentation and templates.
2. Propagate a rule into every generated downstream project surface.
3. Update skill files that encode the workflow.
4. Assess current workspace project impact when the change is workspace-wide.
5. Add or update amendment history.
6. Bump README version/date for template or constitution changes.
7. Add tests that prevent the rule from silently disappearing.
8. Validate no stale contradictory wording remains.

Out of scope:

1. Applying ADC structure to an external project. Use `adc-onboard`.
2. Running RD project onboarding. Use `rd-onboard`.
3. Deploying applications. Use CPMD or deployment skills.
4. Editing unrelated application code.

## Use When

- The user asks to update ADC standards, rules, constitution, or templates.
- The user asks to add a policy across ADC-managed projects.
- The user asks to update `.copilot/skills/*/SKILL.md` for an ADC workflow.
- The user asks whether ADC guidance is sufficient and then wants it fixed.
- A rule must appear in README, `.templates/`, generator output, prompt rules, amendments, checklists, and tests.
- The user asks to align all current workspace projects through ADC governance.

## Do Not Use When

- The request is project-specific and does not change reusable ADC governance.
- The user only wants a local code change or deployment.
- The requested rule conflicts with existing ADC policy and the user has not approved an amendment.

## Required Inputs

Required:

- The rule or policy change requested.
- Whether the change affects templates, skills, generated skeletons, current ADC repo behavior, or all of them.

Helpful optional inputs:

- Target version bump type.
- Exact wording required by the user.
- Backward compatibility expectations.

## Governance Rules

- Never commit directly to `main`; use a source branch such as `dev/<scope>`.
- For every template or constitution update, increment README version and update README date in the same change.
- Add an amendment entry in `.templates/knowledge/amendments.md` for rule changes.
- When a rule affects generated projects, update `src/scripts/generate-adc-template.ps1` as well as `.templates/` files.
- Add or update `src/tests/test_template_quality.py` so the rule is protected by tests.
- Keep ADC files in English.
- Do not invent policy exceptions; document unknowns or conflicts.
- Do not commit secrets, tokens, private keys, or real `.env` values.

## Common Propagation Targets

For most ADC rule changes, inspect and update the relevant subset of:

- `README.md`
- `.templates/index.md`
- `.templates/prompt-rules.md`
- `.templates/knowledge/terminology.md`
- `.templates/knowledge/amendments.md`
- `.templates/standards/conventions/*.md`
- `.templates/standards/checklists/pr-review.md`
- `.templates/standards/runbooks/*.md`
- `.templates/.github/pull_request_template.md`
- `.github/pull_request_template.md`
- `.copilot/skills/*/SKILL.md`
- `src/scripts/generate-adc-template.ps1`
- `src/tests/test_template_quality.py`

Do not update every file mechanically. Propagate only to surfaces where the rule must be visible or generated.

## Update Procedure

### 1. Resolve The Rule And Blast Radius

- Restate the requested policy in concrete terms.
- Identify whether it affects onboarding, updates, RD use, CPMD, CI/CD, frontend, testing, security, devops, or all projects.
- Search for existing wording and contradictions before editing.
- Preserve user-authored changes and unrelated dirty files.

### 1a. Workspace Alignment Pass

- If the user asks to align current workspace projects, inventory active workspace project roots first.
- Read safe project entry points such as `.adc/index.md`, `.adc/prompt-rules.md`, and `.github/copilot-instructions.md` for each included project.
- Preserve project-local hard rules such as language, TDD, security, runtime, deployment, ownership, and no-touch policies.
- Propagate only reusable cross-project policy into ADC canonical surfaces; do not edit individual project ADC files unless the user explicitly requests per-project onboarding or update work.
- Report included/excluded projects and project-specific exceptions.

### 2. Update Canonical Surfaces

- Update the most specific standard first, such as `.templates/standards/conventions/devops.md` or `.templates/standards/conventions/frontend.md`.
- Update `.templates/prompt-rules.md` if the rule must guide AI behavior during tasks.
- Update `.templates/knowledge/terminology.md` if the rule changes a term or abbreviation.
- Update checklists or PR templates if humans or agents must confirm the rule before merge.
- Update relevant `.copilot/skills/*/SKILL.md` if the rule changes workflow execution.

### 3. Update Generated Template Output

- Update `src/scripts/generate-adc-template.ps1` when downstream project scaffolds must include the new rule.
- Keep embedded template wording aligned with `.templates/`.
- Avoid adding root-level scripts or generated status files unless the repository already expects them.

### 4. Version And Amendment

- Bump `README.md` version for template or constitution changes.
- Keep the README date current for the change.
- Add a concise entry to `.templates/knowledge/amendments.md` with the date and policy summary.
- If the change impacts README policy examples, update those examples too.

### 5. Add Or Update Tests

- Update `src/tests/test_template_quality.py` for durable policy coverage.
- Test the specific strings that must appear across templates/generator/skills.
- Prefer focused assertions over broad snapshot tests.

### 6. Validate

Run the smallest meaningful checks:

```powershell
Set-Location 'D:\Repos\ARKSOFT\ADC'
.\.venv\Scripts\python.exe -m pytest src/tests/test_template_quality.py
```

Also run targeted searches for stale wording. Examples:

```powershell
rg -n "old phrase|deprecated wording" . -g '!**/.venv/**' -g '!**/.git/**'
```

If the requested change is only a skill file, perform frontmatter/structure validation at minimum.

## Protected ADC Policies To Preserve

- Source code belongs in `src/`; application docs belong in `docs/`; governance context belongs in `.adc/`.
- Secrets must never be written to tracked files.
- RD MCP is for retrieval/indexing and external context operations, not a substitute for local tests/builds.
- RD project operations require project-scoped keys after onboarding.
- Ports must be registered or verified in RD before new/changed port use.
- CPMD requires source branch merge into `main` and remote/local source branch deletion afterward.
- Frontend visualization defaults: `d3-tube-map` for dynamic metro-style state-machine indicators, AntV or ECharts for ordinary node/edge graphs, and `sigma` for 2.5D graph/network views.
- Webpage testing defaults to VS Code built-in browser tooling; external Browser Agent usage requires an explicit exception reason.

## Safe Output Format

Final output should include:

- Policy updated.
- Files changed.
- Version/amendment changes.
- Tests or validation run.
- Stale wording scan result.
- Workspace projects inspected, included/excluded, and project-specific exceptions when alignment was requested.
- Any unrelated dirty files intentionally ignored.

Do not include token values, raw `.env` lines, private keys, or credential-bearing URLs.

## Failure Handling

- Ambiguous policy: ask one concise clarification before editing.
- Existing conflicting rule: identify the conflict and update all affected surfaces together.
- Test failure unrelated to the change: report it and do not patch unrelated code unless it blocks ADC validation.
- Missing virtual environment: use the project-approved Python command or report validation limitation.
- Dirty unrelated files: leave them unstaged and mention them in the final report.

## Success Criteria

An ADC update is complete when:

1. The requested rule is present in the canonical ADC surface.
2. Generated templates and workflow skills are updated where applicable.
3. README version/date and amendments reflect the change when required.
4. Template quality tests cover the rule when practical.
5. Targeted validation passes or any blocker is clearly reported.
6. No contradictory stale wording remains in relevant ADC files.
