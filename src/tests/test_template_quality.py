from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


def _read(rel_path: str) -> str:
    return (ROOT / rel_path).read_text(encoding="utf-8")


def test_prompt_rules_has_core_quality_sections() -> None:
    content = _read(".templates/prompt-rules.md")

    required_sections = [
        "## Mandatory Core Rules",
        "## Repository and Workflow Rules",
        "## RD Use Policy",
        "## RD Retrieval and Token Policy",
        "## RD-First Trigger Conditions",
        "## Allowed Exceptions",
    ]

    for section in required_sections:
        assert section in content


def test_security_convention_has_patch_and_update_strategies() -> None:
    content = _read(".templates/standards/conventions/security.md")

    required_entries = [
        "## Version, Update, and Patch Security Strategies",
        "- **Security-First Versioning**",
        "- **Patch Cadence Policy**",
        "- **Time-Bounded Exceptions**",
        "- **Post-Patch Verification**",
    ]

    for entry in required_entries:
        assert entry in content


def test_testing_convention_has_quality_strategy_section() -> None:
    content = _read(".templates/standards/conventions/testing.md")

    required_entries = [
        "## Common Test and Software Quality Strategies",
        "- **Branch Coverage Focus**",
        "- **Golden/Snapshot Validation**",
        "## Coverage Governance",
        "- **Minimum Baseline**: Maintain at least 80% line coverage",
    ]

    for entry in required_entries:
        assert entry in content


def test_devops_convention_has_cicd_gitea_coolify_policy() -> None:
    content = _read(".templates/standards/conventions/devops.md")

    required_entries = [
        "## CI/CD Policy (Gitea + Coolify)",
        "CICD=enabled",
        "GITEA_TOKEN",
        "COOLIFY_API_TOKEN",
        "main -> production",
        "Webhook-driven auto deploy",
    ]

    for entry in required_entries:
        assert entry in content


def test_cicd_setup_script_exists_and_has_confirmation_gate() -> None:
    script = _read("src/scripts/setup-cicd-gitea-coolify.ps1")

    required_entries = [
        "CICD",
        "CICD_Enabled",
        "enabled",
        "Read-Host",
        "GITEA_TOKEN",
        "COOLIFY_API_TOKEN",
        "TriggerDeployTest",
    ]

    for entry in required_entries:
        assert entry in script


def test_cicd_preflight_gate_policy_is_explicit() -> None:
    script = _read("src/scripts/setup-cicd-gitea-coolify.ps1")
    runbook = _read(".templates/standards/runbooks/002-cicd-gitea-coolify-debug.md")

    script_required_entries = [
        "CI/CD setup is disabled",
        "Missing GITEA_TOKEN",
        "Missing COOLIFY_API_TOKEN",
        "Validating Gitea token",
        "Validating Coolify token",
    ]
    for entry in script_required_entries:
        assert entry in script

    runbook_required_entries = [
        "Preflight Gate",
        "CICD=enabled",
        "GITEA_TOKEN",
        "COOLIFY_API_TOKEN",
        "Validate Gitea token",
        "Validate Coolify token",
    ]
    for entry in runbook_required_entries:
        assert entry in runbook


def test_all_powershell_scripts_live_under_src_scripts() -> None:
    root_ps1_files = list(ROOT.glob("*.ps1"))
    assert not root_ps1_files


def test_devops_convention_has_required_compose_healthcheck_block() -> None:
    content = _read(".templates/standards/conventions/devops.md")

    required_entries = [
        "## Docker Compose Health Check Policy",
        "healthcheck:",
        "- CMD",
        "- curl",
        "- '-f'",
        "- 'http://localhost:8000/health'",
        "interval: 30s",
        "timeout: 10s",
        "retries: 3",
        "start_period: 40s",
    ]

    for entry in required_entries:
        assert entry in content
