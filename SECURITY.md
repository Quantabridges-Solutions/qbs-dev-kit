# Security Policy

## Supported versions

QBS Dev Kit is a development tooling reference. Only the latest commit on the `main` branch is actively maintained.

## Reporting a vulnerability

If you discover a security issue in the kit itself (e.g. a rule or template that would introduce a vulnerability into projects that use it):

1. **Do not open a public issue**
2. Email **security@quantabridges.com** with:
   - A description of the vulnerability
   - Which rule, skill, or template is affected
   - The potential impact if a developer follows the guidance as written
   - Suggested remediation if known

We aim to respond within **48 hours** and to publish a fix within **7 days** of a confirmed vulnerability.

## Scope

Security reports are in scope if they relate to:
- A rule or skill that instructs the AI agent to produce insecure code patterns
- A template (Terraform, Docker, GitHub Actions) that would create an insecure deployment
- Incorrect security guidance in documentation

Out of scope:
- Security issues in third-party tools referenced by the kit (report to those maintainers)
- Feature requests framed as security issues
