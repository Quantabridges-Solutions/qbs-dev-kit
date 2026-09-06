---
name: qbs-test-feature
description: Add or extend tests for a QBS SaaS feature — xUnit + WebApplicationFactory with OrganizationId isolation on the API, and Playwright (or Vitest) on the React app. Use when the user asks for tests, unit tests, integration tests, tenant isolation tests, Playwright, or coverage for a new endpoint or page.
license: CC-BY-ND-4.0
---

# QBS tests

After scaffolding production code (`dotnet-*-feature`, `react-web-saas`), add tests in the same change whenever behaviour is non-trivial.

## API — xUnit + WebApplicationFactory

Prefer one test project: `{PascalName}.Api.Tests` (or `{PascalName}.Tests`).

```bash
cd src/backend
dotnet new xunit -n {PascalName}.Api.Tests -o {PascalName}.Api.Tests
dotnet sln add {PascalName}.Api.Tests/{PascalName}.Api.Tests.csproj
dotnet add {PascalName}.Api.Tests/{PascalName}.Api.Tests.csproj reference {PascalName}.Api/{PascalName}.Api.csproj
dotnet add {PascalName}.Api.Tests package Microsoft.AspNetCore.Mvc.Testing
dotnet add {PascalName}.Api.Tests package Microsoft.EntityFrameworkCore.InMemory
```

### Tenant isolation (required for every tenant-scoped entity)

```csharp
public class InvoiceTenantTests : IClassFixture<WebApplicationFactory<Program>>
{
    [Fact]
    public async Task Org_A_cannot_read_org_B_invoice()
    {
        // Arrange: seed invoice for Org B; authenticate as Org A
        // Act: GET /api/invoices/{id}
        // Assert: 404 (not 200 with Org B data)
    }
}
```

Rules:

- Filter assertions through `OrganizationId` from test auth claims, not request bodies.
- Do not use `FindAsync(id)` in production code under test without an org filter.
- Integration tests that hit Postgres: use the CI connection string; locally prefer Testcontainers or the compose `db` service.

Run: `dotnet test` from `src/backend`. Never hand-write migrations in tests.

## Web — Playwright (preferred) or Vitest

```bash
cd src/frontend
pnpm add -D @playwright/test
pnpm exec playwright install chromium
```

Cover: login OTP happy path (mock API), list page loads for the current org, 401 redirects to `/login`.

Unit-test hooks/components with Vitest + Testing Library when no browser is needed.

`pnpm test` must exist in `package.json` (Playwright or Vitest). CI uses `templates/github-actions/frontend-test.yml`.

## Mobile

Expo: prefer Maestro or Jest + `@testing-library/react-native` for screen-level tests. Do not block API/web tests on mobile coverage.

## Done when

- [ ] Tenant isolation test exists for new tenant-scoped endpoints
- [ ] `dotnet test` passes
- [ ] Frontend test script exists if UI changed
