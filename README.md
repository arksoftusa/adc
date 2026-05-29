# Autonomous Development Constitution (ADC)

**Version:** 1.1.23
**Status:** Published
**Author:** Nate Scott
**Date:** 2026-05-29

## 1. Introduction

The **Autonomous Development Constitution (ADC)** is a reusable framework for organizing project context, conventions, and implementation guidance in a way that scales across many codebases.

The core philosophy of ADC is to keep project rules, domain knowledge, and workflow guidance alongside the source code in a predictable structure. It acts as a durable reference layer for both AI assistants and human developers.

By design, governance materials are stored within a hidden `.adc/` directory at the project root. The `.` prefix keeps rule files separate from application source code while remaining easy for tooling and editors to discover.

---

## 2. Core Structure

A `.adc/` directory should exist at the root of the project (and optionally within any independent, large-scale submodules).

Important boundary clarification:
- `.adc/` is a hidden governance/context folder at the project root.
- `src/`, `docs/`, `tests/`, and other application folders remain root-level siblings of `.adc/`.
- `src/` and `docs/` MUST NOT be placed inside `.adc/`.

Example root layout:

```text
project-root/
├── .adc/
├── src/
├── docs/
├── tests/
└── ...
```

Here is the standard structure of a `.adc/` directory:

```text
.adc/
├── index.md                  # [Required] Core context entry point, containing global architecture and basic info.
├── prompt-rules.md           # [Required] Dedicated system prompt rules and mandatory instructions for AI assistants.
├── bootstrap.md              # [Required] Exact terminal commands to install dependencies, run local services, and start local dev servers.
│
├── planning/                 # [Project Management Domain]
│   ├── status.md             # [Required] Current project phase, active goals, and recent major changes.
│   ├── project-roadmap.md    # [Required] High-level project timeline, milestones, and strategic objectives.
│   └── development-phases.md # [Required] Detailed breakdown of implementation phases and current sprint focus.
│
├── standards/                # [Specifications & Conventions Domain]
│   ├── conventions/          # [Optional] Directory containing specific coding conventions split by domain.
│   │   ├── structure.md      # Project layout rules and environment management.
│   │   ├── frontend.md       # Frontend component/styling conventions.
│   │   ├── backend.md        # Backend API design/database conventions.
│   │   ├── data-engineering.md # Database schemas, caching, message queues, and vector DB rules.
│   │   ├── performance.md    # Performance budgets, Big-O limits, and optimization strategies.
│   │   ├── observability.md  # Logging formats, metrics, and distributed tracing rules.
│   │   ├── security.md       # Secure coding practices and vulnerability management.
│   │   ├── devops.md         # Docker, CI/CD, and deployment conventions (e.g., container constraints).
│   │   └── testing.md        # Strict testing guidelines (unit/e2e coverage, mocking rules).
│   ├── checklists/           # [Optional] Pre-flight checklists the AI must complete before specific actions (e.g., PR creation).
│   │   └── pr-review.md      # Example: Code review checklist.
│   └── runbooks/             # [Optional] Troubleshooting guides and recovery procedures for common local/CI errors.
│       └── 001-common-errors.md
│
├── knowledge/                # [Persistent Knowledge Domain]
│   ├── glossary.md           # [Required] Domain-specific vocabulary to eliminate misunderstandings (Jargon).
│   ├── known-issues.md       # [Required] Technical debt, legacy code warnings, and areas the AI should NOT refactor.
│   ├── amendments.md         # [Required] The formal protocol and history of modifications made to this Digital Constitution.
│   ├── adr/                  # [Optional] Architecture Decision Records (why certain approaches were chosen/rejected).
│   │   └── 001-why-we-use-redis.md
│   └── diagrams/             # [Required] Living architecture and flow diagrams. MUST be auto-updated by AI on code changes.
│       ├── architecture.mmd
│       └── data-flow.mmd
│
└── rd-edge-agent/            # [Dynamic agent workspace]
    ├── tasks/                # [Optional] Atomic task management queue for tracking multi-agent or multi-step execution.
    │   ├── done/
    │   ├── in-progress/
    │   └── todo/
    │       └── TASK-001.md
    ├── scratchpad/           # [Required] Ignored directory for agent memory (Brain Dump) and session handover context.
    │   └── session.md
    ├── mcp/                  # [Required] Model Context Protocol (MCP) server configurations specific to this project.
    │   └── mcp-servers.json  # Configuration file to load project-specific MCP servers automatically.
    └── skills/               # [Optional] Instruction sets and executable scripts providing specialized actions for AI Agents.
        └── your-skill/       # Example of a specific domain skill.
            ├── SKILL.md      # Actionable instructions for the AI on how to perform this specific task.
            └── scripts/      # Utility scripts the AI can execute.

.adcignore              # [Optional] Specifies files/directories that AI Assistants MUST ignore when reading context.
.cursorrules            # [Required] Standard IDE trigger pointer for Cursor to initialize the AI on the .adc guidelines.
.windsurfrules          # [Required] Standard IDE trigger pointer for Windsurf.
.clinerules             # [Required] Standard IDE trigger pointer for Cline/Claude Dev.
.roomadesrules          # [Required] Standard IDE trigger pointer for Roo Code/Roo Cline.
.aider.rules            # [Required] Standard IDE trigger pointer for Aider.
.codexrules             # [Required] Standard IDE trigger pointer for Codex / traditional OpenAI agents.
.antigravityrules       # [Required] Standard IDE trigger pointer for DeepMind Antigravity and advanced web agents.
.codeiumrules           # [Required] Standard IDE trigger pointer for Codeium.
.codyrules              # [Required] Standard IDE trigger pointer for Sourcegraph Cody.
.github/copilot-instructions.md # [Required] Trigger pointer for GitHub Copilot.
```

---

## 3. Detailed Specifications

### 3.1 `index.md` (Main Entry Point)
This is the entry file for parsing the entire project context. It MUST contain standard YAML Frontmatter so that AI can easily extract structured metadata:

```yaml
---
project-name: "Your Project Name"
version: "1.0.1"
description: "A concise description of the project's core business value."
tech-stack:
  - React 18
  - Node.js 20
  - PostgreSQL
architecture-style: "Microservices / Monolith / Event-Driven"
entry-points:
  - src/main.ts
---
```
**Body Content** should include:
- **Project Background**: The business reason for building this project.
- **Core Modules**: List the top 2-3 most critical directories and their specific purposes.
- **Environment Requirements**: Prerequisites needed to spin up the local environment quickly.

### 3.2 `prompt-rules.md` (AI Core Instructions)
This file isolates the mandatory rules directed at the AI. By separating these instructions, we force the AI to read the strict "Do's and Don'ts" before modifying any code.
**Example Content:**
- **You MUST** strictly use absolute paths when importing modules.
- **You MUST NOT** use the `any` type when defining TypeScript interfaces.
- **You SHOULD** wrap all asynchronous function calls in `try-catch` blocks.
- **Context Awareness**: When modifying the `src/db` directory, you must prioritize reading `.adc/standards/conventions/backend.md`.

### 3.3 `glossary.md` (Domain Glossary)
One of the most common mistakes made by AI and new employees is misunderstanding industry jargon, acronyms, and business domain terms.
By defining a domain glossary, AI assistants will be significantly more accurate when naming variables, models, and writing comments:
- **SPU**: Standard Product Unit.
- **SKU**: Stock Keeping Unit. Ensure `skuId` is strictly used in the code base instead of generic terms like `itemId`.

### 3.4 `conventions/` (Domain-Specific Conventions)
To prevent overwhelming the AI's context window with irrelevant information, massive documentation files are split by domain.
Instead of providing the entire documentation at once, the AI can load these files on-demand. For instance, if the AI is tasked with updating the UI, it only needs to read `.adc/standards/conventions/frontend.md`, saving tokens and focusing its attention purely on frontend constraints.

Frontend visualization policy for webpage projects MUST be captured in `.adc/standards/conventions/frontend.md`:
- Dynamic state-machine indicators, including metro-style operational status views, MUST use `d3-tube-map`.
- Plain node/edge graph displays MUST use AntV or ECharts.
- 2.5D simulated 3D graph, network, or topology views MUST use `sigma`.

### 3.5 `skills/` (Actionable AI Skills)
To evolve the AI from merely "understanding static rules" to "executing complex project-specific actions," ADC introduces the `skills/` directory.

A "Skill" is an advanced extension pack (Instruction Set) that grants the AI specialized capabilities for recurring complex tasks.
Example use cases:
- `.adc/skills/generate-ui/SKILL.md`: Teaches the AI how to use the project's UI component library, pointing to reference examples and automated scripts.
- `.adc/skills/run-migrations/SKILL.md`: Guides the AI on how to correctly generate, review, and execute database migrations within the project's environment.

### 3.6 `.adcignore` (AI Context Exclusion)
Much like `.gitignore` prevents files from being checked into version control, `.adcignore` instructs AI Assistants on which paths to **STRICTLY EXCLUDE** from their context reading.
This is crucial for:
- Preventing the AI from reading large compiled directories (`dist/`, `node_modules/`, `build/`) which could flood the Context Window.
- Protecting sensitive configuration files or keystores (`.env`, `secrets/`, `*.pem`) from being processed.

AI agents must parse `.adcignore` (located at the root or within the `.adc/` directory) and filter file paths accordingly before starting their analysis.

### 3.7 Scoped Context per Directory
Beyond the root `.adc/` directory, if a massive submodule exists (e.g., `src/billing/`), a localized `.adc/index.md` can be created inside it.
When processing code within `src/billing/`, the AI will dynamically inherit **Root Configuration + Sub-directory Configuration**.

### 3.8 `status.md`, `project-roadmap.md` & `development-phases.md` (Project Progress)
AI assistants need to know the current and future trajectory of the project to align their coding decisions with your milestones.
- **`status.md`**: Outlines the **Current Phase** and **Recent Changes** (e.g., "Switched auth from JWT to Session").
- **`project-roadmap.md`**: Provides the macro-level vision, defining epic milestones, feature releases, and long-term strategic objectives.
- **`development-phases.md`**: Breaks down the roadmap into actionable, granular development phases, acting as a step-by-step master plan for the AI to follow.

### 3.9 `adr/` (Architecture Decision Records)
To prevent the AI from generating "hallucinated" architectural suggestions, the `adr/` directory stores historical context.
By reading the relevant ADRs, the AI learns the historical constraints and avoids proposing solutions that have already failed in the past.

### 3.10 `known-issues.md` (Technical Debt & No-Touch Zones)
A manifest of "spaghetti code" or fragile legacy modules.
You can explicitly tell the AI: *"The `src/legacy-billing/` directory is extremely fragile but forms the core cash flow. **You MUST NOT** attempt large-scale refactoring here unless fixing a specific critical bug."* This mitigates the risk of an AI over-optimizing functioning legacy code.

### 3.11 `conventions/data-engineering.md` (Databases, Caching & Messaging)
Data consistency and persistence are paramount. This file dictates how the AI should generate code interacting with databases, caches, and event queues.
**Example constraints to include:**
- **Vector Search (pgvector / sqlite-vec)**: "When implementing semantic search, you MUST use `pgvector` (or `sqlite-vec` for local environments). Ensure HNSW or IVFFlat indexes are applied to the embedding columns. Never fallback to standard SQL text matching for vector fields."
- **Graph Databases (e.g., Neo4j / Nebula)**: "For traversing complex relational node trees (like social graphs or permission hierarchies), you MUST utilize the existing Graph DB connector using Cypher/Gremlin instead of writing recursive SQL CTEs."
- **Caching Strategy (Redis)**: "All read-heavy backend endpoints MUST implement a Redis caching layer. You MUST always append a strict TTL (Time-To-Live) to every cache write operation to prevent unbounded memory growth."
- **Messaging Queues (Kafka / RabbitMQ)**: "When constructing asynchronous background tasks or pub/sub events, you MUST assume at-least-once delivery. Therefore, all consumer functions MUST be designed to be strictly **idempotent**."

### 3.12 `conventions/security.md` (Security & Vulnerability Management)
Security must be "Shift-Left" and treated as a hard constraint during the coding phase. This file informs the AI of the project's security posture and specific vulnerability thresholds. **These rules are inviolable. The AI MUST NOT overstep or ignore these security bounds under any circumstances unless the human user explicitly agrees to amend these rules in this Digital Constitution.**
**Example constraints to include:**
- **Dependency Vulnerabilities (CVE/CVSS)**: "Before adding any new dependency to `package.json` or `requirements.txt`, you MUST verify it against known CVEs (Common Vulnerabilities and Exposures). You MUST NOT introduce any library with an unpatched CVSS score of 7.0 (High) or above."
- **Input Sanitization**: "All external inputs in the backend MUST go through our central validation middleware before processing. Trust NOTHING."
- **Secret Management**: "No secrets, API tokens, or cryptographic keys shall ever be placed in source code or docker-compose files. All credentials must be injected dynamically at runtime via secure secret managers (e.g., AWS Secrets Manager, HashiCorp Vault)."

### 3.13 `conventions/performance.md` (Performance & Optimization)
Writing code that works is not enough; AI must write code that scales. This file enforces strict rules surrounding algorithm efficiency and resource consumption in production.
**Example constraints to include:**
- **Algorithmic Limits (Big-O)**: "When processing large arrays or datasets, nested loops yielding O(N²) complexity MUST be avoided. Utilize HashMaps or Set lookups to achieve O(N) where applicable."
- **Data Fetching Limitations**: "All database queries returning lists MUST enforce pagination or absolute limits (e.g., `LIMIT 100`). Unbounded queries (e.g., `SELECT * FROM users`) are explicitly forbidden."
- **Asset Optimization**: "When dealing with frontend assets or images, you MUST use lazy-loading techniques and modern compression formats (e.g., WebP). Blocking the main thread for more than 50ms is considered a violation."

### 3.14 `conventions/observability.md` (Telemetry & Logging)
A black-box production environment is a disaster waiting to happen. To maintain high project quality, the AI must instrument the code with robust observability patterns.
**Example constraints to include:**
- **Structured Logging**: "All backend logs MUST be in structured JSON format. Standard `console.log()` strings are FORBIDDEN. Every log entry must include at least an `event_id`, `timestamp`, and `user_id` context."
- **Distributed Tracing**: "When writing cross-service HTTP requests or database calls, you MUST propagate OpenTelemetry Context headers. Ensure that every transaction can be traced end-to-end."
- **Custom Metrics**: "For any new core business logic (e.g., processing an order), you MUST autonomously add a metrics counter (e.g., Prometheus `orders_processed_total`) to track its success and failure rate."
- **Error Tracking**: "All unhandled exceptions and promise rejections MUST be caught and forwarded to the designated error tracking tool (e.g., Sentry) alongside the current stack trace and request footprint."

### 3.15 `conventions/devops.md` (Docker & Infrastructure Constraints)
For projects heavily reliant on containerization, this file dictates strict rules for infrastructure code.
When an AI assistant is asked to write Dockerfiles, `docker-compose.yml`, or CI/CD pipelines, this convention enforces security and performance baselines.
- Note: Docker manifests now live under `src/` instead of the repository root.
**Example constraints to include:**
- **RD Port Registry**: "Every ADC-managed project MUST register every owned, exposed, or reserved port in RepoDepot before the port is used. Registrations MUST include project ID, environment, service name, protocol, bind host/interface, host port, container/internal port, purpose, exposure scope, source configuration path, owner, and last verified date. No new or changed port may be introduced until RD confirms that the port is available for the target environment. Dynamic port ranges must be registered with their allocation rules, and stale registrations must be retired when ports are removed."
- **CPMD Branch Closure**: "Every CPMD source branch MUST merge into `main` through the approved path. After successful merge, the source branch MUST be deleted from the remote and local repository before CPMD is considered complete. If merge or branch deletion is blocked, report the blocker and required human action instead of treating deployment as complete."
- **Toolchain Verification**: "When a release or binary validation step needs a local tool such as `dumpbin`, the agent MUST install the required toolchain or activate an existing installation, for example Visual Studio Build Tools through `vswhere`, before claiming the validation cannot be performed. Skipping validation is allowed only after installation or activation fails and the failure is documented."
- **Resource Limits**: "All Docker containers MUST be created with CPU and Memory limits (e.g., `--memory=\"512m\" --cpus=\"1.0\"`)."
- **Parameter Passing**: "Resource limits MUST be passed dynamically to the container via environment variables or Orchestration tools, never hardcoded in scripts."
- **Base Images**: "You MUST ONLY use Alpine or specific distroless images from our official repository. Never use `:latest`."
- **User Permissions**: "Containers MUST NOT run as root. Always add a `USER node` (or equivalent) instruction."
- **Semantic Versioning (SemVer)**: "All project releases, Git tags, and package versions MUST strictly adhere to Semantic Versioning (https://semver.org). When automatically bumping versions or generating changelogs, AI agents MUST correctly evaluate the diff to apply MAJOR (breaking changes), MINOR (new features), or PATCH (bug fixes) increments."

### 3.16 `conventions/structure.md` (Project Layout & Environment Management)
This file establishes strict boundaries for where certain types of files must live and how environment configurations are managed. This forces the AI to keep the repository organized, hierarchical, and secure.
**Example constraints to include:**
- **Environment Variables**: "Absolutely NO real secrets or API keys are to be written or hallucinated. Whenever a new environment variable is needed, you MUST declare it in `.env.example` first with dummy values. Do NOT auto-generate or modify a real `.env` file unless explicitly instructed for local debugging."
- **Source Code Integrity**: "All core business logic and application source code MUST be placed exclusively within the `src/` directory. Root-level software logic (other than standard config files) is strictly forbidden."
- **Documentation**: "All non-contextual, user-facing, or API documentation MUST reside within the `docs/` directory, keeping it separate from the `.adc/` internal context."
- **Compiled Assets**: "All compiled or bundled software output MUST be directed to `dist/` at the project root. For consistency, final artifacts are organized in `dist/release/`, pre-production artifacts in `dist/staging/`, and intermediate build cache files in `dist/build/`. This keeps all build outputs outside the application source tree while maintaining clear separation."
- **Utility Scripts**: "All supplementary bash, python, or Node.js scripts used for building, deploying, or local development MUST be placed in `src/script/` (or `script/` if a project has top-level scripts). No dangling scripts should exist at the project root."
- **Versioning Constraints (`.gitignore`)**: "A `.gitignore` file MUST exist at the root. AI assistants MUST automatically ignore common local cache, IDE configs, dependency folders (`node_modules`), logs, and compiled outputs unless explicitly instructed otherwise."
- **CI/CD & Workflows (`.github/`)**: "All GitHub Actions, issue templates, and pull request templates MUST be centralized in the `.github/` directory. AI agents MUST respect and update these workflows when adding new deployment or testing stages."
- **Push Protocol Fallback**: "Repository checkins should use HTTPS as the default push protocol. If HTTPS push fails due to transient credential or network issues, retry over SSH as the fallback path. This ensures build/test workflows remain unblocked while preserving protocol resiliency."
- **Temporary Data**: "Any runtime logs, uploads, or temporary artifacts MUST be written to `src/log/` or `tmp/` respectively. Both paths MUST be explicitly added to `.gitignore`."
- **Testing Separation**: "All automated tests MUST be placed in an isolated `tests/` directory at the project root. Tests should mirror the `src/` directory structure but must never be mixed within the application source files."

### 3.17 `conventions/testing.md` (Test-Driven Development)
This file enforces your team's quality assurance policies and testing methodologies. **All projects under ADC are highly encouraged to adopt TDD**.
**Example constraints to include:**
- **TDD Enforcement (Test-Driven Development)**: "This project STRICTLY adheres to TDD. When asked to implement a new feature, you MUST write the failing tests in the `tests/` directory **FIRST**, and ONLY write the implementation in `src/` after the test design is confirmed."
- **Coverage Rules**: "Every core domain function MUST have corresponding unit tests. Un-tested code is considered incomplete."
- **LOC Coverage (Line of Code Coverage)**: "Define LOC Coverage as `Executed Coverable Lines / Total Coverable Lines * 100`. Coverable lines include executable statements and exclude blanks, comments, generated code, and non-executable declarations."
- **Mocking**: "When writing tests for the backend API, you MUST use our standardized mocking factory instead of hitting the real database."

### 3.18 `diagrams/` (Living Architecture Documentation)
To ensure that human developers always have an accurate mental model of the system, the `diagrams/` directory MUST remain a "living" documentation hub.
**Example constraints to include:**
- **Auto-Update Requirement**: "Whenever a new core module is created, an API endpoint is added, or the database schema is modified, you MUST automatically generate or update the corresponding `.mmd` (Mermaid) diagrams in the `.adc/knowledge/diagrams/` directory."
- **Format Consistency**: "All diagrams MUST be written in Mermaid format so that they can be directly rendered in standard Markdown viewers and easily manipulated by AI."
- **Diagram Types**: "Maintain at least three baseline diagrams: `architecture.mmd` (high-level system design), `data-flow.mmd` (how data moves between services), and `schema.mmd` (database entity relationships)."

### 3.19 `mcp/` (Model Context Protocol Configurations)
To achieve portability for AI agents, the project can ship with its own toolsets. The `.adc/mcp/` directory stores the configuration files required to bootstrap **Model Context Protocol (MCP)** servers.
- **Portability**: "When cloning this repository on a new machine, the user or AI can import `.adc/mcp/mcp-servers.json` into a local AI client to gain access to project-specific tools and context sources."
- **Constraint**: "Any new external integration SHOULD be accompanied by an update to the MCP configuration so that future AI agents inherit the ability to query that system directly."
- **Integration Indexing**: "After integrating an external agent or MCP-backed service for a project, initialize one full-project index before executing feature tasks. Subsequent updates SHOULD use incremental indexing on changed files."
- **Workspace Rule**: "Use `.adc/rd-edge-agent/tasks/` and `.adc/rd-edge-agent/scratchpad/` for orchestration state only. Canonical requirements and architecture decisions MUST remain in planning/standards/knowledge files."
- **Execution Rule**: "MCP integrations are for retrieval/indexing and external context operations. Local build/test/deploy execution MUST remain on native project tooling."
- **Secret Rule**: "Credentials MUST be injected through environment variables and MUST NOT be committed in tracked files."
- **RD Onboarding Rule**: "Before a project uses RepoDepot context, indexing, project secrets, or MCP tools, follow `.adc/standards/runbooks/003-rd-project-onboarding-mcp.md`: confirm the RD project record, create a missing project key only through first-contact bootstrap, store the project-scoped key as `RD_PROJECT_API_KEY_<PROJECT_ID_SUFFIX>`, configure the RepoDepot MCP launcher through the project's ignored `.env`, and verify project-scoped access before indexing."

### 3.20 `checklists/` (Autonomous Pre-Flight Checks)
For autonomous workflows, deterministic checklists prevent AI from cutting corners.
- **Execution Rule**: "Before generating a Git commit or a Pull Request, you MUST autonomously read `.adc/checklists/pr-review.md` and verify each item. You MUST output a generated report confirming the checklist was completed."

### 3.21 `amendments.md` (Constitutional Amendment Protocol)
Since this constitution defines the repository's core rules, altering those rules requires a formalized amendment process.
**Example constraints to include:**
- **Amendment Proposals**: "Any change to the `.adc/` directory by an AI Agent MUST be submitted as an independent Pull Request titled prefix `[AMENDMENT]`. AI Agents are strictly forbidden from committing changes directly to the `main` branch if they affect the `.adc/` ruleset."
- **Human Ratification**: "An AI Agent CANNOT self-approve amendments. All changes to the constitution require explicit human review and approval."
- **Documenting Amendments**: "Every ratified change must be logged chronologically in `.adc/amendments.md`, detailing the date, the rule altered, and the specific reason for the governance shift."
- **Versioning**: "Significant changes to the constitution (e.g., adding a new `conventions/` domain) require bumping the MAJOR or MINOR version declared in `index.md`."
- **Upstream Synchronization**: "The maintainer SHOULD periodically review the authoritative upstream source for updates and document any adopted changes in `.adc/amendments.md` before promoting a new local version."

---

## 4. How to Use ADC for AI Assistants & Autonomous Agents

Whether you are configuring a reactive coding assistant (like Cursor or GitHub Copilot via `.cursorrules`) or defining the core processing loop for a **Fully Autonomous AI Agent**, your AI system requires strict environmental awareness.

Inject the following directive into your Agent's System Prompt or Core Instruction Set:

> **[INITIALIZATION & EXECUTION PROTOCOL]**
> "As an AI Assistant or Autonomous Agent, before planning, reasoning, or executing ANY task, you MUST check if a `.adc/` directory exists at the project root. This directory contains the project's governing rules. If it exists, you are strictly bound by its rules. You CANNOT bypass its core constraints (especially Security and DevOps limits) unless the human user explicitly instructs you to modify the governing rules themselves. You MUST self-onboard and act iteratively:
>
> 1. **Self-Onboarding**: Read `.adc/index.md`, `.adc/status.md`, and `.adc/development-phases.md` FIRST to establish your macro-level plan and ensure your autonomous reasoning aligns with the current sprint phase.
> 2. **Risk Mitigation**: Read `.adc/known-issues.md` before planning any refactoring to identify 'No-Touch Zones' and historical technical debt.
> 3. **Guideline Enforcement**: Read `.adc/prompt-rules.md` and STRICTLY adhere to the mandatory coding conventions throughout your autonomous execution loop.
> 4. **Vocabulary Synchronization**: Read `.adc/glossary.md` to guarantee correct domain-specific naming in variables, DB schemas, and your generated documentation.
> 5. **Tool Utilization**: Check `.adc/skills/` to see if your current goal can be achieved by utilizing pre-existing automated workflows or executing specific scripts within the project. Verify required tools via `.adc/mcp/`.
> 6. **Pre-flight Checks**: Complete all requirements in `.adc/checklists/` before finalizing commits or pull requests.
> 7. **Self-Correction & Documentation**: Before concluding your execution session, if you have autonomously modified any architecture, data flow, or database schema, you MUST proactively update the corresponding Mermaid diagrams in `.adc/knowledge/diagrams/`."
>
> **[Role]**
> You are an architecture-level AI assistant integrated with the `{SYSTEM_NAME}` system. You have high-level access to the project's logic graph through the MCP protocol and can traverse file boundaries to understand complex code topology.
>
> **[Universal Execution Logic]**
> - **Graph-First**: Before handling any task, you MUST call the `{SYSTEM_NAME}` interface. You are forbidden from relying only on the current file's narrow view; you MUST obtain global context first.
> - **High-Signal**: Refuse to read redundant code. Use graph database capabilities to retrieve only task-relevant nodes, including interface definitions, upstream callers, downstream dependencies, and related configuration metadata.
> - **Impact Analysis**: Before modifying code, you MUST output an impact analysis that identifies which modules will experience cascading effects from the change.
> - **Architecture Consistency**: Strictly follow the design patterns represented by the current project in `{SYSTEM_NAME}`. If the project is security-sensitive, strengthen static checks for privilege escalation and data leakage risks.
>
> **[Output Protocol]**
> - **Status Header**: `[{SYSTEM_NAME} Indexing: Active]`
> - **Topology Feedback**: Briefly summarize the key dependency paths discovered through the graph.
> - **Risk Warning**: If a logic gap is detected, mark it prominently with `⚠️ Logic Gap`.

---

## 5. Quick Start Skeleton

Run the following command in your terminal to generate the barebones ADC structure for an existing codebase:

```bash
mkdir -p .adc/planning .adc/standards/conventions .adc/standards/checklists .adc/standards/runbooks .adc/knowledge/adr .adc/knowledge/diagrams .adc/rd-edge-agent/skills .adc/rd-edge-agent/mcp .adc/rd-edge-agent/tasks/todo .adc/rd-edge-agent/tasks/in-progress .adc/rd-edge-agent/tasks/done .adc/rd-edge-agent/scratchpad tests .github
touch .adc/index.md .adc/bootstrap.md .adc/prompt-rules.md .adc/planning/status.md .adc/planning/project-roadmap.md .adc/planning/development-phases.md .adc/knowledge/glossary.md .adc/knowledge/known-issues.md .adc/knowledge/amendments.md .adc/standards/conventions/structure.md .adc/standards/conventions/frontend.md .adc/standards/conventions/backend.md .adc/standards/conventions/data-engineering.md .adc/standards/conventions/performance.md .adc/standards/conventions/observability.md .adc/standards/conventions/security.md .adc/standards/conventions/devops.md .adc/standards/conventions/testing.md .adc/rd-edge-agent/mcp/mcp-servers.json .adc/standards/checklists/pr-review.md .adc/standards/runbooks/001-common-errors.md .adc/rd-edge-agent/scratchpad/session.md .adc/rd-edge-agent/tasks/todo/TASK-001.md .adcignore .cursorrules .windsurfrules .clinerules .roomadesrules .aider.rules .codexrules .antigravityrules .codeiumrules .codyrules .github/copilot-instructions.md
```
Populate these files with the core essence and rules of your project to achieve peak synergy with AI coding assistants.

---

## 6. Deployment (GitHub Pages)

This repository includes an automated GitHub Pages deployment workflow:

- Workflow file: `.github/workflows/deploy-pages.yml`
- Trigger conditions:
  - Push to `main`
  - Manual run via `workflow_dispatch`
- Source content:
  - `README.md` is published as `site/index.md`
  - `docs/` is copied to `site/docs/`

How to view deployment status and URL:

1. Open **GitHub -> Actions** and run **Deploy Docs To Pages**.
2. After success, open **GitHub -> Settings -> Pages** to see the published site URL.
3. The deployed URL is also exposed in the workflow job output (`github-pages` environment URL).
