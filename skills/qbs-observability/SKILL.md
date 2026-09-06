---
name: qbs-observability
description: Add structured logging, correlation IDs, and CloudWatch-friendly diagnostics to a QBS .NET Lambda API (Serilog or built-in logging). Use when the user asks for logging, observability, correlation IDs, CloudWatch, tracing, alarms, or production diagnostics.
license: CC-BY-ND-4.0
---

# QBS observability

Lambda has no local disk and short lifetimes. Logs go to CloudWatch via `AWSLambdaBasicExecutionRole`. Keep payloads small; never log tokens, OTP codes, or raw PII.

## Correlation ID

- Accept `X-Correlation-Id` if present; otherwise generate a GUID at the start of the request.
- Return it on the response.
- Include it in every log scope.

```csharp
app.Use(async (ctx, next) =>
{
    var id = ctx.Request.Headers["X-Correlation-Id"].FirstOrDefault()
             ?? Guid.NewGuid().ToString("N");
    ctx.Response.Headers["X-Correlation-Id"] = id;
    using (LogContext.PushProperty("CorrelationId", id))
    using (LogContext.PushProperty("OrganizationId", ctx.User.FindFirst("orgId")?.Value))
        await next();
});
```

## Serilog (API)

```bash
dotnet add {PascalName}.Api package Serilog.AspNetCore
dotnet add {PascalName}.Api package Serilog.Formatting.Compact
```

Use `CompactJsonFormatter` so CloudWatch Logs Insights can query `CorrelationId`, `OrganizationId`, `RequestPath`.

Log:

- Information: handled requests (path, status, elapsed ms) — no bodies
- Warning: validation / auth failures (no OTP codes)
- Error: exceptions via `IProblemDetailsService` (no stack traces to clients)

## Lambda / CloudWatch

- Log group: `/aws/lambda/{function-name}` (created by the execution role)
- Optional: set retention in Terraform (`aws_cloudwatch_log_group`, 14–30 days staging, 90 production)
- Alarms: errors > N in 5 minutes; duration approaching timeout; throttles

Do not add X-Ray unless the user asked; prefer logs first.

## Frontend

Send `X-Correlation-Id` from the shared axios client (generate per page session). Do not log JWTs in the browser console in production builds.
