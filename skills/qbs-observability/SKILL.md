---
name: qbs-observability
description: Add production observability to a QBS .NET/AWS service using OpenTelemetry, structured logs, traces, metrics, correlation IDs, deployment metadata, CloudWatch-compatible export and agent audit events. Use when the user asks for logging, observability, tracing, metrics, CloudWatch, OpenTelemetry, correlation IDs, alarms, or production diagnostics.
license: CC-BY-ND-4.0
---

# QBS observability

Production services should emit **logs, traces and metrics** with shared correlation context. Do not treat logging as the whole observability strategy.

## Required context

Every request/operation should make the following queryable where applicable:

- `trace_id`
- `span_id`
- `correlation_id`
- `organization_id` (identifier only; never tenant secrets)
- `service.name`
- `service.version`
- `deployment.environment.name`
- deployment/git SHA
- route/operation
- duration and outcome

Never log authentication tokens, OTP values, credentials, connection strings, request bodies by default, or raw PII.

## OpenTelemetry baseline (.NET)

Prefer OpenTelemetry APIs/instrumentation so exporters can change without rewriting application code.

Typical packages:

```bash
dotnet add {PascalName}.Api package OpenTelemetry.Extensions.Hosting
dotnet add {PascalName}.Api package OpenTelemetry.Instrumentation.AspNetCore
dotnet add {PascalName}.Api package OpenTelemetry.Instrumentation.Http
dotnet add {PascalName}.Api package OpenTelemetry.Instrumentation.Runtime
dotnet add {PascalName}.Api package OpenTelemetry.Exporter.OpenTelemetryProtocol
```

Add database/Redis instrumentation when used and supported. Configure exporters by environment; OTLP is the preferred portable boundary. AWS-native export/collection may use ADOT/CloudWatch/X-Ray behind that boundary.

## Correlation IDs

Accept `X-Correlation-Id` if it is a safe bounded value; otherwise generate one. Return it to the caller and attach it to the current logging/tracing scope. Distributed trace context remains authoritative for cross-service tracing.

## Structured application logs

Use structured properties, not interpolated blobs. Log request route, status, elapsed time and identifiers needed for diagnosis. Do not log request/response bodies unless an explicitly reviewed redaction policy exists.

## Metrics and SLO-ready signals

At minimum expose/collect:
- request rate
- error rate
- latency distributions
- dependency latency/errors
- Lambda duration/errors/throttles/concurrency where applicable
- queue age/depth for asynchronous workloads
- database connection/timeout signals where available

Define alarms from user-impacting signals rather than raw log volume alone.

## Agentic features

When the application itself uses agents/models/tools, capture audit telemetry without storing sensitive prompt content by default:
- agent/run ID
- model/provider identifier
- prompt or policy version identifier
- tool name and outcome
- tool latency
- approval requested/granted/denied
- files/resources affected where appropriate
- validation/eval result
- token/cost metadata when available

Do not record credentials, hidden reasoning, full sensitive prompts, or raw tool payloads by default.

## Production readiness

Before completion verify:
- trace propagation across outbound HTTP where applicable;
- logs contain trace/correlation context;
- health endpoints do not leak internals;
- production log retention is explicit;
- alarms exist for errors, latency/timeouts and throttling;
- dashboards distinguish environment/service/version;
- an operator can correlate a customer-visible failure to a deployment SHA.
