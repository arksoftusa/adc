# Project Terminology & Abbreviations

This file defines the terminology, abbreviations, and shortcuts used in this template and any downstream project that adopts it.

## Development Workflow Abbreviations

| Abbreviation | Full Term | Definition |
|---|---|---|
| **CPMD** | Checkin/Push/Merge/Deploy | Four-step git workflow: `git add -A`, `git commit -m "..."`, `git push origin main`, then deploy via CI/CD pipeline |
| **TDD** | Test-Driven Development | Development methodology: write failing tests first, then implement to pass, then refactor with tests passing |
| **ADC** | Autonomous Development Constitution | Standardized framework for managing project governance, AI instructions, and developer context in `.adc/` folder |
| **GHC** | GitHub Copilot | Standard abbreviation for GitHub Copilot in this project documentation and discussion |
| **MCP** | Model Context Protocol | Protocol for AI agents (like Copilot, Claude) to access external tools and data sources |
| **RD** | Repodepot | Optional repository and artifact management system; use `RD` as shorthand only in projects that integrate it |

## Repodepot Components

| Term | Definition |
|---|---|
| **Repodepot** | Optional artifact catalog, project registry, and orchestration service used by some deployments |
| **RD MCP Server** | Model Context Protocol server for programmatic Repodepot access when that integration is enabled |
| **RD Edge Agent** | Local execution and orchestration agent for RD-enabled projects |
| **RD Getstarted** | Bootstrap endpoint for Repodepot registration when that ecosystem is used |

## Project Structure Terms

| Term | Definition |
|---|---|
| **.adc/** | Hidden governance directory at project root containing project rules, AI instructions, and agent workspace |
| **src/** | Source code directory containing all application logic, utilities, and build scripts |
| **dist/** | Compiled/bundled output directory with subdirs: `release/` (production artifacts), `staging/` (pre-prod), `build/` (cache) |
| **docs/** | User-facing, publishable project documentation (separate from `.adc/`) |
| **tests/** | Isolated test directory mirroring `src/` structure; never mix with source files |
| **.env** | Environment configuration file (git-ignored); never commit real secrets |
| **.env.example** | Template with dummy values showing all required environment variables (committed to git) |

## ADC Subdomains

| Subdomain | Location | Purpose |
|---|---|---|
| **Planning** | `.adc/planning/` | Project phases, roadmap, status tracking |
| **Standards** | `.adc/standards/` | Conventions, checklists, runbooks organized by domain |
| **Knowledge** | `.adc/knowledge/` | Glossary, known issues, ADRs, diagrams |
| **RD Edge Agent** | `.adc/rd-edge-agent/` | Optional agent workspace: tasks, scratchpad, MCP configs, skills |

## File Type Conventions

| Abbreviation | Full Name | Usage |
|---|---|---|
| **.md** | Markdown | Documentation, guidelines, decisions |
| **.mmd** | Mermaid | Diagram format for architecture, data flow, state machines |
| **.json** | JSON | Configuration files (mcp-servers.json, package.json) |
| **ADR** | Architecture Decision Record | Historical record of why architectural choices were made |

## Git & Deployment

| Term | Definition |
|---|---|
| **Commit** | Git snapshot of code changes with descriptive message |
| **Push** | Send committed changes from local to remote repository (origin/main) |
| **Merge** | Integrate changes from one branch into another; main branch is primary |
| **Deploy** | Release code to production via CI/CD pipeline triggered after push to main |
| **origin/main** | Primary branch on remote repository; commits here trigger deployments |

## Testing & Quality

| Term | Definition |
|---|---|
| **Unit Test** | Test of single function/module in isolation |
| **Integration Test** | Test of multiple components working together |
| **E2E Test** | End-to-end test simulating real user workflows |
| **Coverage** | Percentage of code lines executed by tests; target 80%+ for core logic |
| **Mock** | Simulated object/service used in tests instead of real implementation |

## Quality Glossary

| Term | Definition |
|---|---|
| **Branch Coverage** | Percentage of decision branches (`if/else`, match/case, boolean paths) exercised by tests |
| **Changed-Lines Coverage** | Coverage measured only on lines modified in the current change set |
