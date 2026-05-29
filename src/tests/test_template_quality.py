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


def test_frontend_visualization_library_policy_is_required_across_templates() -> None:
    frontend = _read(".templates/standards/conventions/frontend.md")
    prompt_rules = _read(".templates/prompt-rules.md")
    generator = _read("src/scripts/generate-adc-template.ps1")
    readme = _read("README.md")

    required_frontend_entries = [
        "## Web Visualization Library Policy",
        "Dynamic state-machine indicators",
        "d3-tube-map",
        "AntV or ECharts",
        "2.5D simulated 3D",
        "sigma",
    ]

    for entry in required_frontend_entries:
        assert entry in frontend

    for content in [prompt_rules, generator, readme]:
        assert "d3-tube-map" in content
        assert "AntV or ECharts" in content
        assert "2.5D simulated 3D" in content
        assert "sigma" in content


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


def test_cpmd_branch_closure_policy_is_required_across_templates() -> None:
    devops = _read(".templates/standards/conventions/devops.md")
    prompt_rules = _read(".templates/prompt-rules.md")
    terminology = _read(".templates/knowledge/terminology.md")
    pr_template = _read(".templates/.github/pull_request_template.md")
    pr_checklist = _read(".templates/standards/checklists/pr-review.md")
    cpmd_skill = _read(".copilot/skills/cpmd/SKILL.md")
    generator = _read("src/scripts/generate-adc-template.ps1")

    required_entries = [
        "Every CPMD source branch MUST be merged into `main`",
        "deleted from the remote and local repository",
    ]
    for entry in required_entries:
        assert entry in devops
        assert entry in generator

    assert "merge the source branch into `main` and delete the merged source branch remotely and locally" in prompt_rules
    assert "merge it into `main`, delete the merged source branch" in terminology
    assert "merged into `main` and deleted remotely and locally" in pr_template
    assert "merge into `main` and be deleted remotely and locally" in pr_checklist
    assert "merged into `main` through the approved path" in cpmd_skill


def test_rd_port_registry_policy_is_required_across_templates() -> None:
    devops = _read(".templates/standards/conventions/devops.md")
    prompt_rules = _read(".templates/prompt-rules.md")
    pr_template = _read(".templates/.github/pull_request_template.md")
    pr_checklist = _read(".templates/standards/checklists/pr-review.md")

    devops_required_entries = [
        "## RD Port Registry Policy",
        "Every ADC-managed project MUST register every owned, exposed, or reserved port in RepoDepot before the port is used",
        "host port",
        "container port",
        "environment",
        "No new or changed port may be introduced until RD confirms that the port is available",
    ]

    for entry in devops_required_entries:
        assert entry in devops

    assert "register or verify every project port in RD" in prompt_rules
    assert "RD port registry" in pr_template
    assert "RD port registry" in pr_checklist


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
