---
description: .NET 8 API — clean architecture, EF Core, JWT, caching, and conventions
globs: src/backend/**/*.cs
alwaysApply: false
---

# .NET 8 API Standards

## Architecture layers (strict dependency direction)
```
Domain       → no dependencies
Application  → depends on Domain
Infrastructure → depends on Application + Domain
Api          → depends on Application (never Infrastructure directly)
```

## Domain
- Entities extend `BaseEntity` (Id, CreatedAtUtc, UpdatedAtUtc)
- Domain interfaces live here (`IRepository<T>`, `ICacheService`, etc.)
- No EF Core, no infrastructure concerns

## Application
- CQRS via MediatR: `{Entity}{Action}Command/Query` + `{Entity}{Action}CommandHandler/QueryHandler`
- Validators via FluentValidation: `{Command}Validator` registered in `ValidationBehaviour`
- `DependencyInjection.cs` registers all application services
- DTOs are record types; keep them flat (no nested entities)

## Infrastructure
- EF Core + Npgsql; `ApplicationDbContext` inherits `DbContext`
- **Code-first migrations only**: `dotnet ef migrations add <Name> --project Infrastructure --startup-project Api`
- `AppDbContext.SaveChangesAsync` sets `UpdatedAtUtc` automatically via `ChangeTracker`
- Redis via `IDistributedCache` wrapped in `RedisCacheService : ICacheService`
- Repository pattern: `{Entity}Repository : IRepository<{Entity}>`

## API
- Controllers: thin — validate input, call mediator, return result
- Use `[ApiController]` and route attributes; keep routes RESTful
- Global exception handling via `ExceptionHandlerMiddleware`
- FluentValidation errors surfaced via `ValidationExceptionFilter`
- Scalar for API docs at `/scalar` (dev only)
- Health checks at `/health` (postgres + redis)

## JWT
- Tokens signed with `Jwt:Key` from configuration
- Claims: `sub` (userId), `orgId` (tenantId), standard expiry
- `ICurrentOrganization` is scoped — inject it in services, not controllers

## Configuration pattern
```csharp
// Required connection strings — throw on missing
var conn = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
```

## Logging
- Serilog with `ReadFrom.Configuration` — structured, level-controlled via `appsettings.json`
- Use `ILogger<T>` throughout; never `Console.Write*`

## Pagination
```csharp
public record PagedRequest(int Page = 1, int PageSize = 25);
public record PagedResult<T>(IReadOnlyList<T> Items, int Total, int Page, int PageSize)
{
    public int TotalPages => (int)Math.Ceiling((double)Total / PageSize);
    public bool HasNextPage => Page < TotalPages;
}

// Query handler:
var total = await _db.Set<TEntity>().Where(filter).CountAsync(ct);
var items = await _db.Set<TEntity>().Where(filter)
    .OrderByDescending(x => x.CreatedAtUtc)
    .Skip((request.Page - 1) * request.PageSize)
    .Take(request.PageSize)
    .ToListAsync(ct);
return new PagedResult<T>(items, total, request.Page, request.PageSize);
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
// Inject IEmailService into Application command handlers — never directly into controllers
```

## File uploads — S3 pre-signed URLs
```csharp
public interface IStorageService
{
    Task<string> GetUploadUrlAsync(string key, string contentType, CancellationToken ct = default);
    Task DeleteAsync(string key, CancellationToken ct = default);
}
// IStorageService is a Domain interface; S3StorageService is in Infrastructure
// Key format: "{orgId}/{entity}/{entityId}/{filename}"
// Client PUTs directly to S3 — API never receives binary data
```

## Health checks
```csharp
builder.Services.AddHealthChecks()
    .AddNpgsql(connectionString, name: "postgres")
    .AddRedis(redisConn, name: "redis");
app.MapHealthChecks("/health", new HealthCheckOptions {
    ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse
});
```

## Global error handling (ProblemDetails)
```csharp
builder.Services.AddProblemDetails();
builder.Services.AddExceptionHandler<GlobalExceptionHandler>();
// GlobalExceptionHandler maps domain exceptions → HTTP status codes:
// NotFoundException → 404, ValidationException → 422, UnauthorizedException → 401
```

## Tests
- Run `dotnet build` after all changes
- Run `dotnet test` when domain/application logic is touched
