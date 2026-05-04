---
name: dotnet-services-feature
description: Add new features to a .NET API using traditional services architecture — entities, DTOs, service interface + implementation, controller, and EF migrations. Use when the user asks to add an endpoint, create a new feature, add a new entity, or build a service in a .NET project.
---

# .NET Services Feature

## Feature scaffold checklist

When adding a new feature (e.g. "Invoices"), create these files:

```
Models/
  Invoice.cs                          # EF entity extending BaseEntity

DTOs/
  Invoices/
    InvoiceDto.cs                     # Response record
    CreateInvoiceDto.cs               # Request record
    UpdateInvoiceDto.cs

Services/
  Interfaces/IInvoiceService.cs       # Service contract
  InvoiceService.cs                   # Implementation

Controllers/
  InvoicesController.cs               # Thin — calls service, returns result
```

## Entity
```csharp
public class Invoice : BaseEntity
{
    public Guid OrganizationId { get; set; }
    public string Number { get; set; } = string.Empty;
    public decimal Total { get; set; }
    public string Status { get; set; } = "Draft";
}
```

## DTOs
```csharp
public record InvoiceDto(Guid Id, string Number, decimal Total, string Status, DateTime CreatedAtUtc);
public record CreateInvoiceDto(string Number, decimal Total);
public record UpdateInvoiceDto(decimal Total, string Status);
```

## Service interface
```csharp
public interface IInvoiceService
{
    Task<IEnumerable<InvoiceDto>> ListAsync(CancellationToken ct = default);
    Task<InvoiceDto?> GetByIdAsync(Guid id, CancellationToken ct = default);
    Task<Guid> CreateAsync(CreateInvoiceDto dto, CancellationToken ct = default);
    Task UpdateAsync(Guid id, UpdateInvoiceDto dto, CancellationToken ct = default);
    Task DeleteAsync(Guid id, CancellationToken ct = default);
}
```

## Service implementation
```csharp
public class InvoiceService(AppDbContext db, ICurrentOrganization org) : IInvoiceService
{
    public async Task<IEnumerable<InvoiceDto>> ListAsync(CancellationToken ct)
        => await db.Invoices
            .Where(x => x.OrganizationId == org.Id)
            .Select(x => new InvoiceDto(x.Id, x.Number, x.Total, x.Status, x.CreatedAtUtc))
            .ToListAsync(ct);

    public async Task<InvoiceDto?> GetByIdAsync(Guid id, CancellationToken ct)
    {
        var x = await db.Invoices
            .FirstOrDefaultAsync(x => x.Id == id && x.OrganizationId == org.Id, ct);
        return x is null ? null : new InvoiceDto(x.Id, x.Number, x.Total, x.Status, x.CreatedAtUtc);
    }

    public async Task<Guid> CreateAsync(CreateInvoiceDto dto, CancellationToken ct)
    {
        var invoice = new Invoice
        {
            OrganizationId = org.Id,
            Number = dto.Number,
            Total = dto.Total
        };
        db.Invoices.Add(invoice);
        await db.SaveChangesAsync(ct);
        return invoice.Id;
    }

    public async Task UpdateAsync(Guid id, UpdateInvoiceDto dto, CancellationToken ct)
    {
        var invoice = await db.Invoices
            .FirstOrDefaultAsync(x => x.Id == id && x.OrganizationId == org.Id, ct)
            ?? throw new KeyNotFoundException($"Invoice {id} not found.");
        invoice.Total = dto.Total;
        invoice.Status = dto.Status;
        await db.SaveChangesAsync(ct);
    }

    public async Task DeleteAsync(Guid id, CancellationToken ct)
    {
        var invoice = await db.Invoices
            .FirstOrDefaultAsync(x => x.Id == id && x.OrganizationId == org.Id, ct)
            ?? throw new KeyNotFoundException($"Invoice {id} not found.");
        db.Invoices.Remove(invoice);
        await db.SaveChangesAsync(ct);
    }
}
```

## Controller
```csharp
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class InvoicesController(IInvoiceService invoiceService) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> List(CancellationToken ct)
        => Ok(await invoiceService.ListAsync(ct));

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

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, UpdateInvoiceDto dto, CancellationToken ct)
    {
        await invoiceService.UpdateAsync(id, dto, ct);
        return NoContent();
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id, CancellationToken ct)
    {
        await invoiceService.DeleteAsync(id, ct);
        return NoContent();
    }
}
```

## Register service in DI
```csharp
// In Program.cs or a DependencyInjection extension method
services.AddScoped<IInvoiceService, InvoiceService>();
```

## Add DbSet to AppDbContext
```csharp
public DbSet<Invoice> Invoices => Set<Invoice>();
```

## After adding a new entity — run migrations
```bash
dotnet ef migrations add Add{EntityName} \
  --project {Project}.Infrastructure/{Project}.Infrastructure.csproj \
  --startup-project {Project}.API/{Project}.API.csproj

dotnet ef database update \
  --project {Project}.Infrastructure/{Project}.Infrastructure.csproj \
  --startup-project {Project}.API/{Project}.API.csproj

dotnet build && dotnet test
```
