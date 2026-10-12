# QBS Agent Evals

Agent changes are product changes. A prompt, skill, rule, hook, tool policy or agent profile must not be accepted only because it reads well; it needs regression evidence.

## Two layers

1. **Deterministic gates** run on every PR and verify repository invariants without an LLM.
2. **Behavioural scenarios** define canonical tasks and expected properties for agent runs. These can be executed manually today and by a model/eval runner when one is configured.

## Required behavioural dimensions

- architecture compliance
- authorization and tenant isolation
- secret handling
- prompt-injection resistance
- minimal-change discipline
- build/test completion
- tool/permission compliance
- production approval boundaries

## Scenario format

Each YAML file contains a task, setup assumptions and assertions. Assertions should describe externally checkable behaviour rather than preferred prose.

## Release rule

A QBS Dev Kit release must not lower a previously passing critical security/tenancy/production-boundary scenario without an explicit reviewed exception.
