---
description: PostgreSQL + EF Core — migrations, DbContext, and entity patterns
paths:
  - src/backend/**/*.cs
---

# PostgreSQL + EF Core Standards

## Migrations — code-first only
```bash
dotnet ef migrations add <Name> \
  --project src/Infrastructure/Infrastructure.csproj \
  --startup-project src/Api/Api.csproj

dotnet ef database update \
  --project src/Infrastructure/Infrastructure.csproj \
  --startup-project src/Api/Api.csproj

# Revert last
dotnet ef migrations remove \
  --project src/Infrastructure/Infrastructure.csproj \
  --startup-project src/Api/Api.csproj
```
**Never hand-write migration files.**

## Base entity
```csharp
public abstract class BaseEntity
{
    public Guid Id { get; init; } = Guid.NewGuid();
    public DateTime CreatedAtUtc { get; init; } = DateTime.UtcNow;
    public DateTime UpdatedAtUtc { get; set; } = DateTime.UtcNow;
}
```

## DbContext
```csharp
public class AppDbContext : DbContext
{
    public DbSet<Invoice> Invoices => Set<Invoice>();

    protected override void OnModelCreating(ModelBuilder mb)
        => mb.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);

    public override Task<int> SaveChangesAsync(CancellationToken ct = default)
    {
        foreach (var e in ChangeTracker.Entries<BaseEntity>())
            if (e.State == EntityState.Modified)
                e.Entity.UpdatedAtUtc = DateTime.UtcNow;
        return base.SaveChangesAsync(ct);
    }
}
```

## Entity configuration (one file per entity)
```csharp
public class InvoiceConfiguration : IEntityTypeConfiguration<Invoice>
{
    public void Configure(EntityTypeBuilder<Invoice> b)
    {
        b.HasKey(e => e.Id);
        b.Property(e => e.Number).HasMaxLength(50).IsRequired();
        b.Property(e => e.OrganizationId).IsRequired();
        b.HasIndex(e => e.OrganizationId);
    }
}
```

## Connection string format
```
Host=localhost;Port=5432;Database={project};Username={project};Password={pass}
```
