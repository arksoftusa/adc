# Security & Vulnerability Management
- **Inviolable Rule**: Do NOT introduce dependencies with a CVSS score >= 7.0.
- **Input Sanitization**: All external inputs MUST run through the Zod validation middleware before reaching controllers.
- **Secret Management**: NEVER hardcode API keys. All keys MUST be retrieved at runtime via `aws-secrets-manager`.

## Token Security Policy (JWT and Opaque Tokens)
- **Approved JWT Algorithms**: Use `RS256` or `ES256` for multi-service and third-party trust boundaries. `HS256` is allowed only for internal-only services with strong secret management.
- **JWT Signing Key Strength**: HMAC signing keys MUST be at least 256 bits (32 random bytes). RSA keys MUST be at least 2048 bits.
- **JWT Claim Requirements**: Every JWT MUST include `iss`, `sub`, `aud`, `exp`, `iat`, and `jti`.
- **JWT Lifetime Limits**: Access tokens MUST expire in 15 minutes or less. Refresh tokens MUST be rotated on every use and revoked on suspected compromise.
- **Forbidden JWT Practices**: `alg=none`, static/non-random `jti`, or long-lived bearer tokens without revocation capability are strictly forbidden.

## Token Entropy and Generation Requirements
- **CSPRNG Requirement**: All tokens MUST be generated using a cryptographically secure random generator.
- **Minimum Entropy**: Opaque tokens (session IDs, API keys, refresh tokens, password reset tokens, email verification tokens) MUST provide at least 128 bits of entropy. 192 bits or higher is recommended for long-lived tokens.
- **Encoding Guidance**: If base64url is used, token length MUST preserve required entropy (for example, at least 22 base64url chars for 128-bit entropy, at least 43 chars for 256-bit entropy).
- **Single-Use and Expiry**: Password reset and one-time verification tokens MUST be single-use and MUST expire quickly.
- **Storage and Logging**: Raw tokens MUST NOT be stored in plaintext where avoidable and MUST NEVER be written to logs.
