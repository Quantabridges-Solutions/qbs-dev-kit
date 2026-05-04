---
description: SaaS security standards — auth, encryption, data isolation, input validation, AWS, and OWASP
alwaysApply: true
---

# SaaS Security Standards

## Authentication & JWT
- JWT signing key: minimum 32 characters, stored in environment variable — never in source
- Access token expiry: 15–60 minutes max; never set to "never expire"
- OTP codes: 6 digits, expire in 10 minutes, single-use, invalidate after verification
- OTP rate limit: max 5 attempts per 15-minute window; lock account on excess
- Hash OTP codes before storing: `BCrypt.HashPassword(code)` / verify on submission
- Never log JWT tokens, OTP codes, or raw passwords

## Authorization — every endpoint
```csharp
// Every controller or endpoint must have explicit auth
[Authorize]                          // authenticated user required
[Authorize(Roles = "Admin")]         // role required
// OR for tenant-scoped routes:
// Verify OrganizationId from ICurrentOrganization matches the resource
```

## Multi-tenant data isolation (critical)
```csharp
// ALWAYS filter by OrganizationId — never trust the client to send it
var invoice = await db.Invoices
    .Where(x => x.Id == id && x.OrganizationId == org.Id)  // ✅ double-check
    .FirstOrDefaultAsync(ct);

// ❌ Never do this — trusts client-supplied orgId
var invoice = await db.Invoices.FindAsync(id);
```

## Encrypting sensitive fields (PII)
```csharp
// EF Core value converter for AES-encrypted columns
// Store encrypted; decrypt on read — transparent to the rest of the app
services.AddDbContext<AppDbContext>(o =>
    o.UseNpgsql(conn)
     .AddInterceptors(new EncryptionInterceptor(encryptionKey)));

// Fields that MUST be encrypted: ID numbers, bank details, medical data, SSN, DOB (if stored)
// Fields that should be hashed (not encrypted): passwords (use BCrypt)
```

## Input validation
- All commands/DTOs validated by FluentValidation before reaching services
- Sanitize string inputs: max length, allowed characters, trim whitespace
- Never use raw SQL strings — always EF Core LINQ (parameterized by default)
- Validate file uploads: allowed MIME types, max size, scan if possible

## Secrets management
```
✅ Environment variables (Lambda env vars via Terraform)
✅ AWS Secrets Manager for production database credentials
❌ Never in appsettings.json committed to git
❌ Never in .env files committed to git
❌ Never in Terraform tfvars committed to git
```

## CORS
```csharp
builder.Services.AddCors(o => o.AddPolicy("Frontend", p =>
    p.WithOrigins(config["Cors:AllowedOrigins"]!.Split(','))
     .AllowedMethods(["GET","POST","PUT","DELETE"])
     .AllowCredentials()));
// ❌ Never: .AllowAnyOrigin() in production
```

## Rate limiting (API)
```csharp
builder.Services.AddRateLimiter(o => o
    .AddFixedWindowLimiter("auth", opts => {
        opts.PermitLimit = 5;
        opts.Window = TimeSpan.FromMinutes(15);
    }));
// Apply [EnableRateLimiting("auth")] on all auth endpoints
```

## HTTPS & headers
```csharp
app.UseHttpsRedirection();
app.UseHsts();                       // Strict-Transport-Security
// Add security headers via middleware or CloudFront response policies:
// X-Content-Type-Options: nosniff
// X-Frame-Options: DENY
// Content-Security-Policy
```

## Logging — never log sensitive data
```csharp
// ❌ Never log
logger.LogInformation("OTP for {Email}: {Code}", email, code);
logger.LogInformation("JWT: {Token}", token);
logger.LogInformation("Connection: {Conn}", connectionString);

// ✅ Log only safe context
logger.LogInformation("OTP sent to {Email}", email);
logger.LogWarning("Failed login attempt for {Email} — attempt {Count}", email, count);
```

## AWS infrastructure security
- RDS: `storage_encrypted = true`, no `publicly_accessible`, inside VPC
- S3: `block_public_acls = true`, server-side encryption AES256
- CloudFront: `viewer_protocol_policy = "redirect-to-https"`
- Lambda IAM: AWSLambdaBasicExecutionRole + only specific additional policies needed
- No wildcard `*` in IAM actions or resources for production

## Frontend (React web)
- Do not store JWT in `localStorage` for sensitive apps — prefer `HttpOnly` cookies or `sessionStorage`
- Avoid `dangerouslySetInnerHTML` — if required, sanitize with DOMPurify first
- Never expose internal IDs or sensitive data in URLs

## Mobile (Expo)
- Always use `Expo.SecureStore` for tokens — never `AsyncStorage` for auth data
- No sensitive data in Redux/Zustand stores that may be persisted to disk
- Enable certificate pinning for apps handling financial or medical data

## Audit trail
- Log all data mutations (create/update/delete) with userId, orgId, timestamp, and before/after values for sensitive entities
- Retain audit logs for minimum 90 days; do not allow deletion by regular users
