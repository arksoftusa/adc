# Test-Driven Development (TDD)
- **TDD Enforcement**: You MUST write the failing tests in the `tests/` directory **FIRST**, and ONLY write the business implementation in `src/` after tests are written.
- **MockDB**: Use `src/utils/mockFactory.ts` instead of hitting the live PostgreSQL database instance for unit tests.
- **LOC Coverage (Line of Code Coverage) Definition**: `LOC Coverage = (Executed Coverable Lines / Total Coverable Lines) * 100`.
- **Coverable Lines Scope**: Count executable lines only; exclude blank lines, comments, generated files, and non-executable declarations.
