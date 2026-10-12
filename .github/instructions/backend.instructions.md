---
applyTo: "src/backend/**/*.cs"
---

# QBS backend instructions

Use the project's selected services or CQRS pattern consistently. Scope tenant-owned queries with `OrganizationId` obtained from trusted server context. New endpoints require authorization unless the feature specification explicitly documents anonymous access. Keep controllers thin, validate inputs, create EF Core migrations with the CLI, and add cross-tenant negative tests when tenant-owned persistence changes. Do not place credentials or sensitive request data in application logs. Build and run relevant tests before completion.
