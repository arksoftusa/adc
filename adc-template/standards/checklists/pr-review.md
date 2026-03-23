# Autonomous PR Checklist
*AI Agents MUST read and verify every item below before generating a Git commit or PR.*
- [ ] Are all unit tests and E2E tests passing?
- [ ] Did I verify the CVSS score of all new dependencies introduced?
- [ ] If auth/token logic changed, did I enforce JWT algorithm/key requirements and minimum token entropy policy?
- [ ] If database/search logic changed, did I apply the correct `pgvector`/`sqlite-vec`/graph-database policy and index/query constraints?
- [ ] Did I auto-update the Mermaid diagrams in `.adc/diagrams/` to match my architectural modifications?
- [ ] Are Docker CPU/Memory resource limits properly set as environment variables?
