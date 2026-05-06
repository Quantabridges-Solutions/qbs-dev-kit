---
description: PostgreSQL + EF Core conventions — migrations, context, and repository patterns
globs: src/backend/**/*.cs
alwaysApply: false
---

# PostgreSQL + EF Core Standards

## Migrations — code-first only
```bash
# Add a new migration
dotnet ef migrations add <MigrationName> \
  --project src/Infrastructure/Infrastructure.csproj \
  --startup-project src/Api/Api.csproj

# Apply to local DB
dotnet ef database update \
  --project src/Infrastructure/Infrastructure.csproj \
  --startup-project src/Api/Api.csproj

# Revert last migration
dotnet ef migrations remove \
  --project src/Infrastructure/Infrastructure.csproj \
  --startup-project src/Api/Api.csproj
```
**Never hand-write migration files.**

## DbContext
```csharp
public class ApplicationDbContext : DbContext
{
    public DbSet<MyEntity> MyEntities => Set<MyEntity>();

    protected override void OnModelCreating(ModelBuilder mb)
    {
        // Use IEntityTypeConfiguration<T> classes in separate files
        mb.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);
    }

    public override Task<int> SaveChangesAsync(CancellationToken ct = default)
    {
        foreach (var entry in ChangeTracker.Entries<BaseEntity>())
            if (entry.State == EntityState.Modified)
                entry.Entity.UpdatedAtUtc = DateTime.UtcNow;
        return base.SaveChangesAsync(ct);
    }
}
```

## Entity configuration
```csharp
// One file per entity: Persistence/Configurations/{Entity}Configuration.cs
public class MyEntityConfiguration : IEntityTypeConfiguration<MyEntity>
{
    public void Configure(EntityTypeBuilder<MyEntity> b)
    {
        b.HasKey(e => e.Id);
        b.Property(e => e.Name).HasMaxLength(200).IsRequired();
        b.Property(e => e.OrganizationId).IsRequired(); // always on tenant entities
        b.HasIndex(e => e.OrganizationId);
    }
}
```

## Base entity
```csharp
public abstract class BaseEntity
{
    public Guid Id { get; init; } = Guid.NewGuid();
    public DateTime CreatedAtUtc { get; init; } = DateTime.UtcNow;
    public DateTime UpdatedAtUtc { get; set; } = DateTime.UtcNow;
}
```

## Soft deletes
```csharp
public abstract class SoftDeleteEntity : BaseEntity
{
    public bool IsDeleted { get; private set; }
    public DateTime? DeletedAtUtc { get; private set; }
    public void SoftDelete() { IsDeleted = true; DeletedAtUtc = DateTime.UtcNow; }
}

// In OnModelCreating — apply per entity (not globally, to be explicit):
builder.Entity<Invoice>().HasQueryFilter(e => !e.IsDeleted);

// In service — soft delete, never DbContext.Remove():
invoice.SoftDelete();
await db.SaveChangesAsync(ct);
```

## Audit log
```csharp
public class AuditLog : BaseEntity
{
    public Guid UserId { get; set; }
    public Guid OrganizationId { get; set; }
    public string EntityType { get; set; } = string.Empty;   // e.g. "Invoice"
    public Guid EntityId { get; set; }
    public string Action { get; set; } = string.Empty;        // "Created" | "Updated" | "Deleted"
    public string? Changes { get; set; }                      // JSON diff of before/after
    public string? IpAddress { get; set; }
}
// Write audit entries in SaveChangesAsync via ChangeTracker — not in every service method
// Retain for minimum 90 days; never allow non-admin deletion
```

## Common query patterns
```csharp
// Tenant-scoped + soft-delete-safe (global query filter handles IsDeleted):
var items = await db.Invoices
    .Where(x => x.OrganizationId == org.Id)
    .OrderByDescending(x => x.CreatedAtUtc)
    .AsNoTracking()
    .ToListAsync(ct);

// Exists check (avoid loading full entity):
var exists = await db.Invoices.AnyAsync(x => x.Id == id && x.OrganizationId == org.Id, ct);
```

## Connection string format
```
Host=localhost;Port=5432;Database={project};Username={project};Password={pass}
```
