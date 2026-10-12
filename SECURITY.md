# Security Policy

## Supported versions

Only the latest supported QBS Dev Kit release and the latest commit on `main` are actively maintained. v3 introduces explicit agent/tool/production security boundaries; projects on earlier versions should adopt those controls before increasing agent autonomy.

## Reporting a vulnerability

If you discover a security issue in the kit itself, **do not open a public issue**. Email **security@quantabridges.com** with:

- a description of the vulnerability;
- the affected rule, skill, agent, policy, hook, workflow, MCP configuration or template;
- realistic impact if a developer/agent follows the guidance as written;
- reproduction/evidence where safe;
- suggested remediation if known.

We aim to respond within **48 hours** and to publish a fix within **7 days** of a confirmed vulnerability.

## In scope

Security reports include:

- agent/rule/skill instructions that produce insecure code or weaken controls;
- prompt-injection paths that can override QBS policy or disclose sensitive data;
- tool/MCP configurations with excessive privileges, unsafe credential handling or unintended external writes;
- agent profiles that can cross production approval boundaries;
- hooks that fail open for critical secret/security checks;
- Terraform, Docker or GitHub Actions templates that create insecure deployments;
- use of long-lived cloud deployment credentials where short-lived federation is intended;
- production schema migration/deployment behaviour that bypasses review;
- vulnerable supply-chain or CI patterns introduced by the kit;
- incorrect security guidance in documentation or evals that fail to cover a known critical regression.

## Security design assumptions

- external/retrieved content is untrusted data;
- agent tools follow least privilege;
- production side effects require human approval;
- deterministic scanners/tests complement model review;
- credentials are scoped and short-lived where supported;
- agent installs do not silently enable third-party MCP access.

## Out of scope

- vulnerabilities exclusively in third-party products that the kit does not configure unsafely (report those to the relevant maintainer);
- feature requests framed as security issues;
- insecure downstream modifications that contradict the kit's documented controls.
