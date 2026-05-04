---
description: .NET API — traditional services architecture, EF Core, JWT, caching, and conventions
paths:
  - src/backend/**/*.cs
---

# .NET API Standards (Traditional Services)

## Architecture layers
```
Models/       → EF entities (extend BaseEntity)
DTOs/         → Request/response shapes (flat records)
Services/     → Business logic and orchestration (IXxxService / XxxService)
Controllers/  → Thin: validate → call service → return result
Data/         → AppDbContext, DataSeeder
```

## Controllers — always thin
```csharp
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class InvoicesController(IInvoiceService invoiceService) : ControllerBase
{
    [HttpGet("{id:guid}")]
    public async Task<IActionResult> Get(Guid id, CancellationToken ct)
    {
        var result = await invoiceService.GetByIdAsync(id, ct);
        return result is null ? NotFound() : Ok(result);
    }
}
```

## Services — own the domain logic
```csharp
public interface IInvoiceService
{
    Task<InvoiceDto?> GetByIdAsync(Guid id, CancellationToken ct = default);
    Task<Guid> CreateAsync(CreateInvoiceDto dto, CancellationToken ct = default);
}

public class InvoiceService(AppDbContext db, ICurrentOrganization org) : IInvoiceService
{
    public async Task<InvoiceDto?> GetByIdAsync(Guid id, CancellationToken ct)
    {
        var x = await db.Invoices
            .FirstOrDefaultAsync(e => e.Id == id && e.OrganizationId == org.Id, ct);
        return x is null ? null : new InvoiceDto(x.Id, x.Number, x.CreatedAtUtc);
    }
}
```

## Data and migrations
- **Never hand-write migration files** — use EF Core CLI only
- `dotnet ef migrations add <Name> --project Infrastructure --startup-project Api`
- `dotnet ef database update --project Infrastructure --startup-project Api`

## Multi-tenancy
- Scoped `ICurrentOrganization`; all tenant data filtered by `OrganizationId`
- HTTP: `X-Organization-Id` header consumed by `OrganizationContextMiddleware`

## After changes
```bash
dotnet build
dotnet test  # when services or domain logic is touched
```
