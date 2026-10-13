# QBS Agentic Runtime

QBS Dev Kit 3.1 adds a governed runtime on top of the v3 engineering standards. It uses GitHub Agentic Workflows (`gh-aw`) for sandboxed agent execution, safe outputs, threat detection, evals, deterministic graders and AI Credit telemetry.

## Runtime model

```text
Agent Task issue
   |
agent-candidate
   |
human triage / acceptance criteria
   |
agent-ready
   |
QBS issue-to-PR agent
   |
verification + evals + graders
   |
threat detection + safe output
   |
draft PR
   |
deterministic CI + read-only QBS reviewer
   |
optional disposable preview
   |
human review / approval
   |
HUMAN PRODUCTION GATE
```

Production deployment, production database migration, IAM escalation, destructive infrastructure and production data mutation remain outside implementation-agent authority.

## Source vs compiled workflows

Agentic source workflows are Markdown files under `.github/workflows/`:

- `issue-to-pr.md`
- `pr-review.md`
- `ci-doctor.md`

They are **not executable until compiled**. The pinned `gh-aw` compiler generates hardened `*.lock.yml` workflows. Never hand-edit generated lock files.

Routine CI deliberately stays read-only for repository contents. `compile-agentic-workflows.yml` proves that the Markdown sources compile and uploads generated lock files as review evidence, but it does not receive standing authority to rewrite files under `.github/workflows/`.

An authenticated maintainer activates or updates the runtime by reviewing and committing source + generated locks together. The helper script keeps this repeatable:

```bash
bash scripts/activate-agentic-runtime.sh
# Review any safe-update warning and generated diff.
bash scripts/activate-agentic-runtime.sh --commit
```

If `gh-aw` blocks compilation because the reviewed change introduces a restricted secret, action, redirect or trigger escalation, inspect the warning and source diff first. Only for that exact reviewed change may a maintainer run:

```bash
bash scripts/activate-agentic-runtime.sh --approve-reviewed --commit
```

The helper never pushes or merges. Normal branch protection, CODEOWNERS, CI and PR review still apply.

Manual equivalent:

```bash
gh extension install github/gh-aw --pin v0.91.8
gh aw compile --strict --yamllint
gh aw validate --strict
git add .github/workflows/*.md .github/workflows/*.lock.yml .github/aw/actions-lock.json
git diff --cached
git commit -m "chore: activate QBS agentic workflow locks"
```

Once lock files are tracked, `validate-agentic-workflows.yml` rejects source/lock drift.

## Human-gated issue intake

Use the **QBS Agent Task** Issue Form for work intended for agent-assisted implementation. It captures:

- problem / goal;
- measurable acceptance criteria;
- explicit non-goals;
- implementation lane;
- tenancy/authentication impact;
- database/migration impact;
- infrastructure/deployment impact;
- required verification; and
- rollback/failure considerations.

New tasks receive `agent-candidate`, not `agent-ready`. A human maintainer reviews scope and risk, applies the appropriate `agent:*` routing label where useful, and only then adds `agent-ready` to authorize execution.

Bootstrap the standard labels once per repository:

```bash
bash scripts/setup-github-labels.sh owner/repo
```

Optional specialist labels:

- `agent:backend`
- `agent:frontend`
- `agent:infra`
- `agent:test`
- `agent:security`

The implementation workflow creates at most one **draft** PR and labels it `agent-generated` and `needs-human-review`. Protected governance, workflow, dependency and instruction files fall back to human review instead of being silently changed.

## GitHub App for safe-output credentials

`gh-aw` can fall back to the normal `GITHUB_TOKEN`, but a PR created with that token may not trigger the normal CI chain. Production QBS repositories should configure a dedicated GitHub App so safe-output jobs mint **short-lived** credentials only when required.

Set:

- repository variable `QBS_AUTOMATION_APP_ID`
- repository secret `QBS_AUTOMATION_APP_PRIVATE_KEY`

Grant only the repository permissions required by the configured safe outputs. Do **not** grant administration, environment deployment, workflow-management or organization-wide authority to the implementation app.

The workflow uses `ignore-if-missing: true`, so a repository can adopt the source safely before the app exists. Verify the expected CI-trigger behavior before broad autonomous issue execution.

## Runtime budgets

AI Credits (AIC) are the primary runtime cost metric. 1 AIC represents USD 0.01 of modeled inference spend.

| Workflow | Per-run AIC | 24h AIC | Threat-detection AIC |
|---|---:|---:|---:|
| Issue -> PR | 250 | 2500 | 75 |
| PR review | 125 | 1500 | 50 |
| CI Doctor | 75 | 750 | 40 |

Budget limits are safety rails, not expected spend. Tighten them as operating data becomes available.

### Model routing for this repository

The three activated workflows explicitly select `gpt-5.3-codex` for agent execution,
threat detection and evals. The Copilot catalog observed during smoke-test run
`38372150823` advertised this model with AI Credit pricing. In that same run,
the implicit `auto` selection resolved to `gpt-5.6-luna-utility`, which had no pricing
entry; the firewall rejected the request before inference to preserve budget enforcement.

Keep all three execution phases on an available, priced model. Model availability
and pricing can change: review the runtime catalog before changing these pins,
then recompile and commit source + locks together. Do not disable the AI Credit
guardrail or invent fallback prices to make an unpriced model run. Other organizations
adopting the kit must verify their own Copilot catalog and billing policies.

## Evals and graders

Every QBS runtime workflow declares both:

- `evals` — post-run outcome questions such as whether scope stayed bounded and production boundaries were preserved;
- `graders: {}` — deterministic trajectory metrics such as tool success rate, failures, retries, loops, duration, objective coverage and grounding accuracy.

Useful commands:

```bash
gh aw logs --count 25 --format markdown
gh aw logs --count 25 --json
gh aw audit <run-id> --evals
```

LLM judgement is never the sole release gate. Deterministic CI, security scanning and human review remain authoritative.

## Agentic telemetry

`Agentic Telemetry Report` runs weekly and can be triggered manually. It stores native `gh aw logs` JSON/Markdown evidence and writes a run-summary dashboard.

Track at minimum:

- success / failed / blocked rate;
- AI Credits by workflow and model;
- duration and turns;
- tool success/failure rate;
- retry and loop counts;
- eval pass rate;
- objective coverage / grounding metrics; and
- safe-output failures or threat-detection blocks.

Use these metrics to decide whether an agent needs a narrower prompt, fewer tools, stronger deterministic checks or a different model tier.

## PR preview environments

Add the `preview` label to a **same-repository** PR to create an isolated AWS environment named `pr-<number>`. Fork PRs are rejected from preview deployment.

The preview workflow deliberately separates trust zones:

1. **Verify** — checks out PR code and runs build/tests with **no AWS/OIDC credentials**.
2. **Infrastructure** — checks out Terraform from the **trusted base branch**, assumes the dedicated preview OIDC role, creates/selects the isolated `pr-N` workspace, and provisions preview infrastructure. PR-controlled Terraform never runs with cloud credentials.
3. **Build** — checks out PR code again with **no cloud credentials**, builds backend/frontend artifacts, and uploads them to GitHub Actions artifact storage.
4. **Publish** — downloads only the prebuilt artifacts, then receives short-lived preview AWS credentials to update Lambda/S3/CloudFront. It does not execute PR package/build scripts.
5. **Smoke** — checks `/health` and publishes preview URLs.
6. **Destroy** — on label removal or PR close, checks out trusted base-branch Terraform and destroys the isolated workspace.

RDS and Redis are disabled by default. Preview workloads must never use production data.

Required repository variables:

- `AWS_PREVIEW_ROLE_ARN`
- `AWS_REGION`
- `TF_STATE_BUCKET`

Fresh QBS scaffolds do not need to commit a backend block solely for previews: the workflow materializes an S3 backend declaration at runtime when none exists. If the project already declares a non-S3 backend, preview deployment fails closed until the workflow is adapted and reviewed for that backend.

The preview IAM role should be separate from production deployment and constrained to preview resource/state namespaces.

## Runtime governance variables

Useful organization/repository variables supported by `gh-aw` include:

- `GH_AW_POLICY_ALLOW_CREATE_PULL_REQUEST`
- `GH_AW_DEFAULT_MAX_AI_CREDITS`
- `GH_AW_DEFAULT_MAX_DAILY_AI_CREDITS`
- `GH_AW_DEFAULT_DETECTION_MAX_AI_CREDITS`

An organization can therefore freeze agent PR creation or tighten budget caps without editing every repository.

## Rollout recommendation

Roll out in stages:

1. **Activate** — compile/review/commit lock files and create the standard labels.
2. **Observe** — enable the PR reviewer and telemetry; inspect cost, eval and review quality.
3. **Assist** — use `agent-ready` only for a small maintained issue set; all outputs remain draft.
4. **Preview** — configure the isolated preview role/state and test preview lifecycle on a low-risk PR.
5. **Scale** — expand eligible issue categories only after runtime evidence is consistently healthy.
6. **Keep production human-controlled** — merging and production side effects remain governed human actions unless a separately approved policy explicitly changes that boundary.
