# Technical plan: {FEATURE_TITLE}

**Spec:** `specs/{FEATURE_ID}/spec.md`  
**Status:** Draft  
**Last updated:** {TODAY}

## Overview

Short technical summary tied to the spec (no new product requirements here).

## Stack choices (confirm against repo)

| Area | Choice | Notes |
|------|--------|-------|
| API | .NET / Lambda / etc. | |
| Data | EF Core, entities, migrations | |
| Web | React / routes / state | |
| Mobile | Expo / N/A | |
| Infra | Terraform modules touched | |

## Architecture

- **Flow** — request/response or job flow (bullets or diagram in prose).
- **Boundaries** — which projects/folders change (`src/backend/...`, `src/frontend/...`).

## Data model

- Entities / tables affected, keys, indexes, relationships.
- Migration strategy (`dotnet ef migrations add ...`).

## API contracts

- New or changed endpoints (method, path, request/response shapes).
- Errors and status codes.

## Security and tenancy

- AuthZ rules, `OrganizationId` enforcement, PII handling.

## Dependencies and risks

| Risk | Mitigation |
|------|------------|
| | |

## Out of scope for this plan

- …

## References

- Link to spec, issues, ADRs.
