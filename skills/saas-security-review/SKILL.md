---
name: saas-security-review
description: Run a security review on a new feature, endpoint, or entity in a QBS SaaS project. Covers auth, tenant isolation, data encryption, input validation, secrets, logging, and infrastructure hardening. Use when the user asks for a security review, security checklist, "is this secure", or when completing a new feature that handles sensitive data.
license: CC-BY-ND-4.0
---

# SaaS Security Review

## Run this checklist on every new feature before marking it complete

### 1. Authentication & Authorization
- [ ] Every new endpoint has `[Authorize]` or explicit `[AllowAnonymous]` with documented reason
- [ ] Role-based access applied where needed (`[Authorize(Roles = "Admin")]`)
- [ ] JWT expiry is 15–60 minutes; no "never expire" tokens
- [ ] OTP endpoints have rate limiting (`[EnableRateLimiting("auth")]`)

### 2. Multi-tenant data isolation
- [ ] Every DB query filters by `OrganizationId` from `ICurrentOrganization` (not from request body)
- [ ] No query uses `FindAsync(id)` alone on tenant-scoped entities
- [ ] Write a test that verifies Org A cannot read Org B's data via this endpoint

### 3. Input validation
- [ ] All input DTOs have a FluentValidation validator registered
- [ ] String fields have `MaximumLength` set
- [ ] No raw SQL queries (EF Core LINQ only)
- [ ] File uploads validated: allowed types, max size, sanitized filename

### 4. Sensitive data & PII
- [ ] Identified what data fields are PII (name, email, ID numbers, financial, medical)
- [ ] PII fields encrypted at column level (EF Core value converter) or at rest (RDS encrypted)
- [ ] Passwords/OTP codes hashed with BCrypt before storage
- [ ] No PII in logs, error messages, or query strings

### 5. Secrets & configuration
- [ ] No secrets, keys, or connection strings hardcoded in source or config files
- [ ] All secrets in environment variables or AWS Secrets Manager
- [ ] `.env` and `terraform.tfvars` are gitignored

### 6. Logging — check for leaks
- [ ] No tokens, passwords, or OTP codes appear in any log statement
- [ ] Sensitive user data (email, phone) logged only at Warn/Error level with purpose

### 7. API surface
- [ ] CORS is restricted to known origins — no `AllowAnyOrigin()` in production
- [ ] HTTPS redirection and HSTS are configured
- [ ] Rate limiting applied to auth and high-volume endpoints
- [ ] Security headers set: `X-Content-Type-Options`, `X-Frame-Options`, CSP

### 8. Frontend / mobile
- [ ] JWT stored in `HttpOnly` cookie (web) or `SecureStore` (mobile) — not `localStorage`
- [ ] No `dangerouslySetInnerHTML` without DOMPurify sanitization
- [ ] Sensitive data not in URL params or browser history

### 9. AWS infrastructure
- [ ] RDS: `storage_encrypted = true`, `publicly_accessible = false`
- [ ] S3: `block_public_acls = true`, AES256 encryption
- [ ] Lambda IAM role: minimum required permissions, no wildcard `*`
- [ ] CloudFront: HTTPS only

### 10. Audit trail (for sensitive entities)
- [ ] Mutations (create/update/delete) logged with userId, orgId, timestamp
- [ ] Audit logs protected from deletion by regular users

---

## Implementing column-level encryption for PII

```csharp
// 1. Create encryption service
public interface IEncryptionService
{
    string Encrypt(string plainText);
    string Decrypt(string cipherText);
}

public class AesEncryptionService(IConfiguration config) : IEncryptionService
{
    private readonly byte[] _key = Convert.FromBase64String(
        config["Encryption:Key"] ?? throw new InvalidOperationException("Encryption:Key missing"));

    public string Encrypt(string plainText)
    {
        using var aes = Aes.Create();
        aes.Key = _key;
        aes.GenerateIV();
        using var encryptor = aes.CreateEncryptor();
        var plainBytes = Encoding.UTF8.GetBytes(plainText);
        var cipherBytes = encryptor.TransformFinalBlock(plainBytes, 0, plainBytes.Length);
        return Convert.ToBase64String(aes.IV.Concat(cipherBytes).ToArray());
    }

    public string Decrypt(string cipherText)
    {
        var fullBytes = Convert.FromBase64String(cipherText);
        using var aes = Aes.Create();
        aes.Key = _key;
        aes.IV = fullBytes[..16];
        using var decryptor = aes.CreateDecryptor();
        var cipherBytes = fullBytes[16..];
        return Encoding.UTF8.GetString(decryptor.TransformFinalBlock(cipherBytes, 0, cipherBytes.Length));
    }
}

// 2. EF Core value converter on the entity property
b.Property(e => e.NationalId)
 .HasConversion(
     v => encryptionService.Encrypt(v),
     v => encryptionService.Decrypt(v));
```

---

## OTP security implementation

```csharp
// Send OTP
var code = Random.Shared.Next(100000, 999999).ToString();
var expiry = DateTime.UtcNow.AddMinutes(10);
var hashed = BCrypt.Net.BCrypt.HashPassword(code);

await db.OtpCodes.AddAsync(new OtpCode
{
    Email = email,
    HashedCode = hashed,
    ExpiresAtUtc = expiry,
    IsUsed = false
});

// Verify OTP
var otp = await db.OtpCodes
    .Where(x => x.Email == email && !x.IsUsed && x.ExpiresAtUtc > DateTime.UtcNow)
    .OrderByDescending(x => x.CreatedAtUtc)
    .FirstOrDefaultAsync(ct);

if (otp is null || !BCrypt.Net.BCrypt.Verify(request.Code, otp.HashedCode))
    return Unauthorized("Invalid or expired code.");

otp.IsUsed = true;
await db.SaveChangesAsync(ct);
```

---

## Encryption key generation

```bash
# Generate a 256-bit base64 key for Encryption:Key
openssl rand -base64 32
```

Store in Lambda environment: `"Encryption__Key" = "your-generated-key"`
