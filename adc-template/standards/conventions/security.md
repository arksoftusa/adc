# Security & Vulnerability Management
- **Inviolable Rule**: Do NOT introduce dependencies with a CVSS score >= 7.0.
- **Input Sanitization**: All external inputs MUST run through the Zod validation middleware before reaching controllers.
- **Secret Management**: NEVER hardcode API keys. All keys MUST be retrieved at runtime via `aws-secrets-manager`.
