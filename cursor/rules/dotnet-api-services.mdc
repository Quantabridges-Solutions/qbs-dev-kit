---
description: .NET 8/10 API — traditional services architecture, EF Core, JWT, caching, and conventions
globs: src/backend/**/*.cs
alwaysApply: false
---

# .NET API Standards (Traditional Services)

## Architecture layers
```
Domain/Models    → EF entities extending BaseEntity
DTOs/            → Request/response shapes (flat records)
Services/        → Business logic and orchestration
Repositories/    → Data access (or use DbContext directly in services)
Controllers/     → Thin: validate → call service → return result
Infrastructure/  → DbContext, caching, email, external integrations
```

## Controllers — thin
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

    [HttpPost]
    public async Task<IActionResult> Create(CreateInvoiceDto dto, CancellationToken ct)
    {
        var id = await invoiceService.CreateAsync(dto, ct);
        return CreatedAtAction(nameof(Get), new { id }, new { id });
    }
}
```

## Services — own the logic
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
        var invoice = await db.Invoices
            .Where(x => x.Id == id && x.OrganizationId == org.Id)
            .FirstOrDefaultAsync(ct);
        return invoice is null ? null : Map(invoice);
    }

    public async Task<Guid> CreateAsync(CreateInvoiceDto dto, CancellationToken ct)
    {
        var invoice = new Invoice { OrganizationId = org.Id, Number = dto.Number };
        db.Invoices.Add(invoice);
        await db.SaveChangesAsync(ct);
        return invoice.Id;
    }

    private static InvoiceDto Map(Invoice x) => new(x.Id, x.Number, x.CreatedAtUtc);
}
```

## Dependency Injection
```csharp
// Program.cs or a DependencyInjection.cs extension
services.AddScoped<IInvoiceService, InvoiceService>();
services.AddScoped<IAuthService, AuthService>();
services.AddScoped<ICurrentOrganization, CurrentOrganization>();
```

## DTOs — flat records
```csharp
// Request
public record CreateInvoiceDto(string Number, Guid CustomerId);

// Response
public record InvoiceDto(Guid Id, string Number, DateTime CreatedAtUtc);
```

## Models — EF entities
```csharp
public class Invoice : BaseEntity
{
    public Guid OrganizationId { get; set; }
    public string Number { get; set; } = string.Empty;
}
```

## Data and migrations
- **Never hand-write migration files** — use EF Core CLI only
- `dotnet ef migrations add <Name> --project Infrastructure --startup-project Api`
- `dotnet ef database update --project Infrastructure --startup-project Api`
- Seeding: `Data/DataSeeder.cs`; context: `Data/AppDbContext.cs`

## Multi-tenancy
- Scoped `ICurrentOrganization`; all tenant data filtered by `OrganizationId`
- HTTP: `X-Organization-Id` header consumed by `OrganizationContextMiddleware`

## JWT
- Tokens via `IAuthService.GenerateToken(user)`
- Claims: `sub` (userId), `orgId` (tenantId)
- `ICurrentOrganization` reads `orgId` claim from `IHttpContextAccessor`

## Caching
- Inject `ICacheService` (wraps `IDistributedCache` → Redis)
- Cache keys: `"{entity}:{id}"` or `"{entity}:org:{orgId}"`

## Logging
- `ILogger<T>` throughout via Serilog; structured, level-controlled via `appsettings.json`
- Never `Console.Write*`

## Pagination
```csharp
public record PagedRequest(int Page = 1, int PageSize = 25);
public record PagedResult<T>(IReadOnlyList<T> Items, int Total, int Page, int PageSize)
{
    public int TotalPages => (int)Math.Ceiling((double)Total / PageSize);
    public bool HasNextPage => Page < TotalPages;
}

// In service:
var total = await query.CountAsync(ct);
var items = await query
    .OrderByDescending(x => x.CreatedAtUtc)
    .Skip((req.Page - 1) * req.PageSize)
    .Take(req.PageSize)
    .ToListAsync(ct);
return new PagedResult<T>(items, total, req.Page, req.PageSize);
```

## Email — Resend
```csharp
public interface IEmailService
{
    Task SendAsync(string to, string subject, string htmlBody, CancellationToken ct = default);
    Task SendOtpAsync(string to, string code, CancellationToken ct = default);
    Task SendWelcomeAsync(string to, string name, CancellationToken ct = default);
}
// Register: builder.Services.AddResend(o => o.ApiToken = config["Resend:ApiKey"]!);
// Implement ResendEmailService : IEmailService using IResend
// From address: config["Email:From"] e.g. "noreply@yourdomain.com"
```

## File uploads — S3 pre-signed URLs
```csharp
// Never accept binary uploads at the API — issue pre-signed PUT URLs
public interface IStorageService
{
    Task<string> GetUploadUrlAsync(string key, string contentType, CancellationToken ct = default);
    Task DeleteAsync(string key, CancellationToken ct = default);
}

// Client workflow:
// 1. POST /files/upload-url  → { uploadUrl, key }
// 2. Client PUTs file directly to S3 using uploadUrl
// 3. Client calls API with key to associate file with entity
// Key format: "{orgId}/{entity}/{entityId}/{filename}"
```

## Health checks
```csharp
builder.Services.AddHealthChecks()
    .AddNpgsql(connectionString, name: "postgres")
    .AddRedis(redisConn, name: "redis");

app.MapHealthChecks("/health", new HealthCheckOptions {
    ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse
});
// Returns 200 JSON with status of each dependency — used by docker-compose + load balancer
```

## Global error handling (ProblemDetails)
```csharp
builder.Services.AddProblemDetails();
builder.Services.AddExceptionHandler<GlobalExceptionHandler>();
// app.UseExceptionHandler(); — never expose raw exceptions

// GlobalExceptionHandler maps known exceptions to status codes:
// NotFoundException → 404, ValidationException → 422, UnauthorizedException → 401
// All others → 500 (log full exception; return generic message)
```

## After changes
```bash
dotnet build
dotnet test  # when services/domain logic is affected
```
