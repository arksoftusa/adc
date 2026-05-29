# Project Structure & Layout Conventions

## Directory Layout

Template-based projects SHOULD follow this standard root structure:

```text
project-root/
├── .adc/                    # Hidden governance/context directory
├── src/                     # All source code
│   ├── dist/                # Compiled/bundled output (git-ignored)
│   │   ├── release/         # Final production artifacts
│   │   ├── staging/         # Pre-production build output
│   │   └── build/           # Intermediate build cache
│   ├── rd-mcp/              # Optional MCP integration implementation
│   ├── rd-edge-agent/       # Optional agent/orchestration workspace
│   ├── scripts/             # Utility scripts for building, deploying, local dev
│   └── ... (application modules)
├── docs/                    # User-facing and project documentation
├── tests/                   # Automated tests (mirrors src structure)
├── .github/                 # GitHub workflows, issue templates, PR templates
├── .gitignore              # Git exclusion rules
└── ... (config files: package.json, tsconfig.json, etc.)
```

## Compiled Assets (dist/)

**STRICT RULE**: All compiled or bundled software output MUST be directed to `dist/`.

- **Subdirectory Structure**:
  - `dist/release/` — Final production artifacts (versioned builds, executable bundles)
  - `dist/staging/` — Pre-production builds for testing and validation
  - `dist/build/` — Intermediate build cache, temporary compilation artifacts

- **Git Ignore**: `dist/` MUST be added to `.gitignore` to prevent build artifacts from being committed.

- **Rationale**: Keeping all build outputs at the project root maintains a clear separation between source code and generated assets while keeping dependencies visible and organized.

## Environment Variables

- `.env.example` — Template file with all required environment variables and dummy values (REQUIRED in git)
- `.env` — Actual environment configuration (git-ignored, never committed)

**RULE**: NO real secrets or API keys shall ever be written to `.env`. All credentials must be injected at runtime via secure secret managers (e.g., AWS Secrets Manager, HashiCorp Vault).

## Source Code Integrity

All core business logic MUST reside in `src/`. Root-level software logic (other than standard config files) is strictly forbidden.

Approved root-level files only:
- `package.json`, `package-lock.json`
- `tsconfig.json`, `.eslintrc.*`, `prettier.config.*`
- `README.md`, `LICENSE`
- `.github/`, `.gitignore`, `.gitattributes`
- `.adc/`
- Configuration for tools (`.nvmrc`, `Dockerfile`, `docker-compose.yml`)

## Utility Scripts

All supplementary bash, Python, or Node.js scripts for building, deploying, or local development MUST be placed in `src/scripts/`.

**Examples**:
- `src/scripts/build.sh` — Compilation pipeline
- `src/scripts/migrate.js` — Database migration runner
- `src/scripts/deploy.sh` — Production deployment script
- `src/scripts/seed.py` — Development data seeding

## Git Push Protocol

- Default protocol for repository check-in and push operations MUST be HTTPS.
- If HTTPS push fails due to transient auth/network issues, SSH is the required fallback.
- Teams SHOULD avoid protocol switching outside this order unless a maintainer approves an exception in the same change set.

## Workspace Project Alignment

When a user asks to align all projects in the current workspace, agents MUST treat the workspace as a set of independent project roots, not as one monorepo.

- **Workspace Inventory**: Agents must inventory active workspace project roots and report which projects were included or excluded from the alignment pass.
- **Safe Entry-Point Review**: Read each included project's ADC entry points and local AI instructions, such as `.adc/index.md`, `.adc/prompt-rules.md`, and `.github/copilot-instructions.md`, while respecting `.adcignore` and secret-handling rules.
- **Preserve Local Hard Rules**: Agents must preserve project-local hard rules, including language, TDD, security, runtime, deployment, ownership, and no-touch rules, even when ADC templates evolve.
- **Shared Versus Local Scope**: Put reusable cross-project policy in ADC templates, standards, skills, and generator output; do not edit individual project ADC files unless the user explicitly requests per-project onboarding or update work.
- **Alignment Report**: Final reports for workspace alignment MUST list the projects inspected, the common rule being aligned, project-specific exceptions, validation performed, and follow-up actions.

## Documentation

- `docs/` — All user-facing, API, and project documentation
- `.adc/` — Internal governance and conventions (not published)

Keep these strictly separated.
