# Autonomous PR Checklist
*AI Agents MUST read and verify every item below before generating a Git commit or PR.*
- [ ] Are all unit tests and E2E tests passing?
- [ ] Did I verify the CVSS score of all new dependencies introduced?
- [ ] Was this work checked in on a `dev/*` (or `hotfix/*`) branch and not directly on `main`?
- [ ] For CPMD, will the source branch merge into `main` and be deleted remotely and locally after merge?
- [ ] Is `docs/deploy_key.md` present and updated with the current public deploy key when deploy credentials were added or rotated?
- [ ] If auth/token logic changed, did I enforce JWT algorithm/key requirements and minimum token entropy policy?
- [ ] If database/search logic changed, did I apply the correct `pgvector`/`sqlite-vec`/graph-database policy and index/query constraints?
- [ ] Did I auto-update the Mermaid diagrams in `.adc/knowledge/diagrams/` to match my architectural modifications?
- [ ] Are Docker CPU/Memory resource limits properly set as environment variables?
- [ ] If ports were added, changed, reserved, or removed, did I update or verify the RD port registry and resolve conflicts?
