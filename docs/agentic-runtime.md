# QBS Agentic Runtime

QBS Dev Kit 3.1 adds a governed runtime on top of the v3 engineering standards. It uses GitHub Agentic Workflows (`gh-aw`) for sandboxed agent execution, safe outputs, threat detection, evals, deterministic graders and AI Credit telemetry.

## Runtime model

```text
Issue + agent-ready label
        |
        v
QBS issue-to-PR agent
  - read-only GitHub token to the model
  - bounded shell/edit tools in sandbox
  - specialist QBS agent rules
  - threat detection
  - evals + graders
        |
        v
Safe output handler
        |
        +--> draft PR only
                |
                v
        deterministic CI + QBS PR reviewer
                |
                v
           human approval
```

Production deployment, production database migration, IAM escalation, destructive infrastructure and production data mutation remain outside implementation-agent authority.

## Source vs compiled workflows

Agentic source workflows are Markdown files under `.github/workflows/`:

- `issue-to-pr.md`
- `pr-review.md`
- `ci-doctor.md`

They are **not** executed directly by GitHub Actions. The pinned `gh-aw` compiler generates hardened `*.lock.yml` workflows. Do not hand-edit generated lock files.

`compile-agentic-workflows.yml` compiles same-repository feature branches/PRs and commits the lock files back to the source branch. `validate-agentic-workflows.yml` rejects invalid or stale source/lock pairs.

Local maintainer commands:

```bash
gh extension install github/gh-aw --pin v0.91.8
gh aw compile --strict --yamllint
gh aw validate --strict
gh aw list --json
```

## Issue -> draft PR

Add the label `agent-ready` to an issue only after a human has confirmed that it is bounded and implementation-ready.

Optional specialist labels:

- `agent:backend`
- `agent:frontend`
- `agent:infra`
- `agent:test`
- `agent:security`

The workflow creates at most one **draft** PR and labels it `agent-generated` and `needs-human-review`. Protected governance, workflow, dependency and instruction files fall back to a human-review issue instead of being pushed automatically.

The implementation workflow may build/test locally in its sandbox, but it cannot deploy production infrastructure, apply production migrations, approve reviews, merge PRs or bypass branch protection.

## GitHub App for safe-output credentials

`gh-aw` can fall back to the normal `GITHUB_TOKEN`, but a PR created with that token may not trigger the normal CI chain. Production QBS repositories should configure a dedicated GitHub App so safe-output jobs mint **short-lived** credentials only when needed.

Set:

- repository variable `QBS_AUTOMATION_APP_ID`
- repository secret `QBS_AUTOMATION_APP_PRIVATE_KEY`

Recommended app permissions should be the minimum required for the configured safe outputs; typically repository Contents write for the automation branch plus Pull Requests write and Issues write where fallback/comment operations are enabled. Do not grant administration, environment deployment or organization-wide permissions to the implementation app.

The workflow uses `ignore-if-missing: true`, so repos can adopt v3.1 before the app is configured, but CI-trigger behavior should be verified before enabling autonomous issue execution broadly.

## Runtime budgets

AI Credits (AIC) are the primary runtime cost metric. 1 AIC represents USD 0.01 of modeled inference spend.

Current defaults in QBS workflows:

| Workflow | Per-run AIC | 24h AIC | Threat-detection AIC |
|---|---:|---:|---:|
| Issue -> PR | 250 | 2500 | 75 |
| PR review | 125 | 1500 | 50 |
| CI Doctor | 75 | 750 | 40 |

Budget limits are safety rails, not expected spend. Tighten them using repository/organization runtime policy variables as operating data becomes available.

## Evals and graders

Every QBS runtime workflow declares both:

- `evals` — post-run YES/NO outcome questions, such as whether scope stayed bounded and production boundaries were preserved.
- `graders: {}` — deterministic post-agent trajectory metrics such as tool success rate, failures, retries, loops, execution duration, objective coverage and grounding accuracy.

Use:

```bash
gh aw logs --count 25 --format markdown
gh aw logs --count 25 --json
gh aw audit <run-id> --evals
```

Do not use an LLM-only score as the sole release gate. Deterministic CI, security scanners and human review remain authoritative for release decisions.

## Agentic telemetry

`Agentic Telemetry Report` runs weekly and can be triggered manually. It stores a 30-day artifact containing the native `gh aw logs` JSON and Markdown report and writes a dashboard-style summary into the GitHub Actions run summary.

Track at minimum:

- run success/failure/blocked rate
- AI Credits and trend by workflow/model
- duration and turns
- tool success/failure rate
- retry and loop counts
- eval pass rate
- objective coverage / grounding metrics
- safe-output failures or threat-detection blocks

Use these metrics to decide whether an agent needs a better prompt, narrower tools, a stronger deterministic check, or a lower/higher model tier.

## PR preview environments

Add the `preview` label to a PR to create an isolated AWS environment named `pr-<number>`.

The preview workflow:

1. assumes `AWS_PREVIEW_ROLE_ARN` using GitHub OIDC;
2. selects a dedicated Terraform workspace;
3. applies resources with `environment=pr-N`;
4. disables RDS and Redis by default;
5. builds/tests and deploys backend/frontend when present;
6. smoke-checks `/health`;
7. publishes preview URLs to the PR;
8. destroys the environment when `preview` is removed or the PR closes.

Required repository variables:

- `AWS_PREVIEW_ROLE_ARN`
- `AWS_REGION`
- `TF_STATE_BUCKET`

The preview IAM role should be separate from production deployment and constrained to the preview resource/state namespace. Preview workloads must not point to production data. If a feature needs persistence, use an explicitly approved disposable or shared non-production datastore.

## Runtime governance variables

Useful organization/repository variables supported by gh-aw include:

- `GH_AW_POLICY_ALLOW_CREATE_PULL_REQUEST`
- `GH_AW_DEFAULT_MAX_AI_CREDITS`
- `GH_AW_DEFAULT_MAX_DAILY_AI_CREDITS`
- `GH_AW_DEFAULT_DETECTION_MAX_AI_CREDITS`

An organization can therefore freeze agent PR creation or tighten budget caps without changing and recompiling every QBS repository.

## Rollout recommendation

Roll out in stages:

1. **Observe** — enable PR reviewer + telemetry.
2. **Assist** — allow `agent-ready` only for a small maintained issue set; keep all outputs draft.
3. **Scale** — expand issue categories after eval/CI data is consistently healthy.
4. **Never remove the production boundary** — merging and production side effects remain governed human actions unless a separately approved policy explicitly changes that boundary.
