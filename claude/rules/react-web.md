---
description: React web app (Vite + TypeScript + Tailwind) — stack, structure, and conventions
paths:
  - src/frontend/**/*.ts
  - src/frontend/**/*.tsx
---

# React Web Standards (Vite + TypeScript + Tailwind)

## Stack
Vite · React 19 · TypeScript (strict) · Tailwind CSS v4 · React Router v6 · TanStack Query · Axios · Lucide React · pnpm

## Directory structure
```
src/
  api/
    client.ts       # Single axios instance — never create ad-hoc ones
    {domain}.ts     # API functions per domain
  auth/
    token.ts        # JWT get/set/clear
    organization.ts # Active org context
  components/       # Shared UI
  pages/            # Route-level components
  hooks/            # Custom hooks
  types/            # Shared TypeScript types
```

## API layer
```typescript
// ✅ Always use the centralized client
import { api } from '@/api/client';

// ✅ TanStack Query — always include orgId in query key for tenant-scoped data
const { data } = useQuery({
  queryKey: ['invoices', orgId],
  queryFn: () => api.get('/api/invoices').then(r => r.data),
});

// ✅ Invalidate after mutations
const mutation = useMutation({
  mutationFn: (dto) => api.post('/api/invoices', dto),
  onSuccess: () => queryClient.invalidateQueries({ queryKey: ['invoices', orgId] }),
});
```

## Auth — OTP flow
1. `POST /api/auth/otp/send` with email
2. `POST /api/auth/otp/verify` with code → JWT
3. Store JWT in `token.ts`; axios interceptor sets `Authorization: Bearer {token}`
4. Set `X-Organization-Id` from `organization.ts` on every request

## Conventions
- Functional components and hooks only
- No `any` — use `unknown` and narrow
- `React.lazy` + `Suspense` for route-level code splitting
- Tailwind utility classes only; no inline styles

## Build
```bash
pnpm run build       # always run after substantive changes
pnpm run type-check  # TypeScript check without emit
```
