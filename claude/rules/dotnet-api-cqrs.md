---
description: .NET API — CQRS/MediatR architecture, EF Core, JWT, caching, and conventions
paths:
  - src/backend/**/*.cs
---

# .NET API Standards (CQRS / MediatR)

## Architecture layers (strict dependency direction)
```
Domain       → entities, interfaces — no dependencies
Application  → commands, queries, handlers, validators
Infrastructure → DbContext, repositories, caching, email
Api          → controllers, middleware, filters
```

## Commands and Queries
```
Application/
  {Entity}/
    Commands/
      Create{Entity}Command.cs
      Create{Entity}CommandHandler.cs
      Create{Entity}CommandValidator.cs
    Queries/
      Get{Entity}Query.cs
      Get{Entity}QueryHandler.cs
      {Entity}Dto.cs
```

## Handler template
```csharp
public record CreateInvoiceCommand(Guid OrganizationId, string Number) : IRequest<Guid>;

public class CreateInvoiceCommandHandler(IInvoiceRepository repo)
    : IRequestHandler<CreateInvoiceCommand, Guid>
{
    public async Task<Guid> Handle(CreateInvoiceCommand req, CancellationToken ct)
    {
        var invoice = new Invoice { OrganizationId = req.OrganizationId, Number = req.Number };
        await repo.AddAsync(invoice, ct);
        return invoice.Id;
    }
}
```

## Controllers — always thin
```csharp
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class InvoicesController(IMediator mediator) : ControllerBase
{
    [HttpPost]
    public async Task<IActionResult> Create(CreateInvoiceCommand cmd, CancellationToken ct)
    {
        var id = await mediator.Send(cmd, ct);
        return CreatedAtAction(nameof(Get), new { id }, new { id });
    }
}
```

## Migrations
- **Never hand-write migration files** — use EF Core CLI only
- `dotnet ef migrations add <Name> --project Infrastructure --startup-project Api`
- `dotnet ef database update --project Infrastructure --startup-project Api`

## After changes
```bash
dotnet build && dotnet test
```
