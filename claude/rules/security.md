---
description: SaaS security standards — auth, encryption, data isolation, input validation, AWS, and OWASP
---

# SaaS Security Standards

## Authentication & JWT
- JWT signing key: minimum 32 characters, stored in environment variable — never in source
- Access token expiry: 15–60 minutes max; never "never expire"
- OTP codes: 6 digits, expire in 10 minutes, single-use, invalidate after verification
- OTP rate limit: max 5 attempts per 15-minute window; lock on excess
- Hash OTP codes before storing (BCrypt); verify on submission
- Never log JWT tokens, OTP codes, or raw passwords

## Authorization — every endpoint
```csharp
[Authorize]                          // authenticated user required
[Authorize(Roles = "Admin")]         // role required
// Tenant routes: always verify OrganizationId from ICurrentOrganization
```

## Multi-tenant data isolation (critical)
```csharp
// ✅ Always double-check OrganizationId — never trust client-supplied ID
var invoice = await db.Invoices
    .Where(x => x.Id == id && x.OrganizationId == org.Id)
    .FirstOrDefaultAsync(ct);

// ❌ Never — trusts client input
var invoice = await db.Invoices.FindAsync(id);
```

## Encrypting sensitive fields (PII)
- Fields that MUST be encrypted at column level: ID numbers, bank details, medical data, SSN, DOB
- Fields that must be hashed (not encrypted): passwords → use BCrypt
- Use EF Core value converters for transparent column encryption
- RDS storage encryption: `storage_encrypted = true` in Terraform (already in template)

## Input validation
- All DTOs validated by FluentValidation before reaching services
- Sanitize: max length, allowed characters, trim whitespace
- Never raw SQL — always EF Core LINQ (parameterized by default)
- File uploads: allowed MIME types, max size, sanitize filenames

## Secrets management
```
✅ Lambda environment variables (set via Terraform var.lambda_environment)
✅ AWS Secrets Manager for production database credentials
❌ Never in appsettings.json committed to git
❌ Never in .env committed to git
❌ Never in terraform.tfvars committed to git
```

## CORS
```csharp
// ✅ Explicit origins only
p.WithOrigins(config["Cors:AllowedOrigins"]!.Split(','))
// ❌ Never in production
.AllowAnyOrigin()
```

## Rate limiting
```csharp
// Apply to all auth endpoints: OTP send, OTP verify, login
builder.Services.AddRateLimiter(o => o
    .AddFixedWindowLimiter("auth", opts => {
        opts.PermitLimit = 5;
        opts.Window = TimeSpan.FromMinutes(15);
    }));
```

## HTTPS & headers
```csharp
app.UseHttpsRedirection();
app.UseHsts();
// CloudFront: redirect-to-https (already in template)
// Add: X-Content-Type-Options, X-Frame-Options, CSP via response headers
```

## Logging — never log sensitive data
```csharp
// ❌ Never
logger.LogInformation("OTP: {Code}", code);
logger.LogInformation("JWT: {Token}", token);

// ✅ Safe
logger.LogInformation("OTP sent to {Email}", email);
logger.LogWarning("Failed OTP attempt {Count} for {Email}", count, email);
```

## AWS infrastructure security
- RDS: `storage_encrypted = true`, `publicly_accessible = false`, inside VPC
- S3: `block_public_acls = true`, AES256 server-side encryption
- CloudFront: `viewer_protocol_policy = "redirect-to-https"`
- Lambda IAM: minimal permissions — never wildcard `*` in production
- Enable CloudWatch alarms for unusual Lambda error rates

## Frontend (React web)
- Prefer `HttpOnly` cookies over `localStorage` for JWT in sensitive apps
- Never `dangerouslySetInnerHTML` — sanitize with DOMPurify if unavoidable
- Never expose internal IDs or sensitive data in URLs or query strings

## Mobile (Expo)
- `Expo.SecureStore` for tokens — never `AsyncStorage` for auth data
- No sensitive data in persisted state (Redux/Zustand)
- Certificate pinning for financial or medical apps

## Audit trail
- Log all mutations (create/update/delete) with userId, orgId, timestamp
- Retain audit logs minimum 90 days; protect from deletion by regular users
