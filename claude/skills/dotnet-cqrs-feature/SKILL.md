---
name: dotnet-cqrs-feature
description: Add new features to a .NET API using CQRS/MediatR — commands, queries, handlers, entities, validators, and EF migrations.
when_to_use: Use when the user asks to add an endpoint, create a new feature, add a new entity, or implement CQRS in a .NET project.
---

# .NET Clean Architecture Feature

## Feature scaffold checklist

When adding a new feature (e.g. "Invoices"), create these files:

```
Domain/
  Entities/Invoice.cs                          # Entity extending BaseEntity
  Interfaces/IInvoiceRepository.cs             # Repository interface

Application/
  Invoices/
    Queries/
      GetInvoiceQuery.cs                       # record with Id
      GetInvoiceQueryHandler.cs                # IRequestHandler<GetInvoiceQuery, InvoiceDto>
      ListInvoicesQuery.cs
      ListInvoicesQueryHandler.cs
    Commands/
      CreateInvoiceCommand.cs                  # record with input properties
      CreateInvoiceCommandHandler.cs
      CreateInvoiceCommandValidator.cs         # FluentValidation
      UpdateInvoiceCommand.cs
      UpdateInvoiceCommandHandler.cs
      DeleteInvoiceCommand.cs
      DeleteInvoiceCommandHandler.cs
    Dtos/InvoiceDto.cs                         # Response shape — record type

Infrastructure/
  Persistence/
    Repositories/InvoiceRepository.cs
    Configurations/InvoiceConfiguration.cs    # IEntityTypeConfiguration<Invoice>

Api/
  Controllers/InvoicesController.cs
```

## Entity template
```csharp
public class Invoice : BaseEntity
{
    public Guid OrganizationId { get; set; }
    public string Number { get; set; } = string.Empty;
    // ... domain properties
}
```

## Command + Handler template
```csharp
public record CreateInvoiceCommand(Guid OrganizationId, string Number) : IRequest<Guid>;

public class CreateInvoiceCommandHandler(
    IInvoiceRepository repository) : IRequestHandler<CreateInvoiceCommand, Guid>
{
    public async Task<Guid> Handle(CreateInvoiceCommand request, CancellationToken ct)
    {
        var invoice = new Invoice { OrganizationId = request.OrganizationId, Number = request.Number };
        await repository.AddAsync(invoice, ct);
        return invoice.Id;
    }
}
```

## Validator template
```csharp
public class CreateInvoiceCommandValidator : AbstractValidator<CreateInvoiceCommand>
{
    public CreateInvoiceCommandValidator()
    {
        RuleFor(x => x.OrganizationId).NotEmpty();
        RuleFor(x => x.Number).NotEmpty().MaximumLength(50);
    }
}
```

## Controller template
```csharp
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class InvoicesController(IMediator mediator) : ControllerBase
{
    [HttpGet("{id:guid}")]
    public async Task<IActionResult> Get(Guid id, CancellationToken ct)
    {
        var result = await mediator.Send(new GetInvoiceQuery(id), ct);
        return result is null ? NotFound() : Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> Create(CreateInvoiceCommand command, CancellationToken ct)
    {
        var id = await mediator.Send(command, ct);
        return CreatedAtAction(nameof(Get), new { id }, new { id });
    }
}
```

## After adding a new entity

Run migrations:
```bash
dotnet ef migrations add Add{EntityName} \
  --project src/Infrastructure/Infrastructure.csproj \
  --startup-project src/Api/Api.csproj

dotnet ef database update \
  --project src/Infrastructure/Infrastructure.csproj \
  --startup-project src/Api/Api.csproj
```

Then build and test:
```bash
dotnet build
dotnet test
```
