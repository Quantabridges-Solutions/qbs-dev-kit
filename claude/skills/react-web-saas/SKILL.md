---
name: react-web-saas
description: Add new pages, features, or API integrations to a React (Vite + TypeScript + Tailwind) web app.
when_to_use: Use when the user asks to add a page, React component, web UI feature, form, table, or dashboard section.
---

# React Web SaaS Page/Feature

## New page checklist

1. Create page in `src/pages/`
2. Add route in router config (`src/router.tsx` or `App.tsx`)
3. Add API functions in `src/api/{domain}.ts`
4. Add TanStack Query hooks
5. Add navigation link to sidebar/nav

## Page template
```typescript
// src/pages/InvoicesPage.tsx
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/api/client';
import { useOrganization } from '@/auth/organization';

export function InvoicesPage() {
  const { orgId } = useOrganization();
  const queryClient = useQueryClient();

  const { data: invoices, isLoading } = useQuery({
    queryKey: ['invoices', orgId],
    queryFn: () => api.get('/api/invoices').then(r => r.data),
  });

  const createMutation = useMutation({
    mutationFn: (data: CreateInvoiceDto) => api.post('/api/invoices', data),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['invoices', orgId] }),
  });

  if (isLoading) return <LoadingSpinner />;

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Invoices</h1>
      {/* content */}
    </div>
  );
}
```

## OTP Auth pages

### Login page (`src/pages/LoginPage.tsx`)
```typescript
// 1. Email input form
// 2. Submit → POST /api/auth/otp/send
// 3. On success → navigate to /verify?email={email}
```

### Verify page (`src/pages/VerifyPage.tsx`)
```typescript
// 1. 6-digit OTP input (auto-focus, paste support)
// 2. Submit → POST /api/auth/otp/verify
// 3. On success → store JWT via token.ts → navigate to /dashboard
```

## API client setup
```typescript
// src/api/client.ts
import axios from 'axios';
import { getToken } from '@/auth/token';
import { getOrgId } from '@/auth/organization';

export const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
});

api.interceptors.request.use(config => {
  const token = getToken();
  const orgId = getOrgId();
  if (token) config.headers.Authorization = `Bearer ${token}`;
  if (orgId) config.headers['X-Organization-Id'] = orgId;
  return config;
});

api.interceptors.response.use(
  r => r,
  err => {
    if (err.response?.status === 401) {
      clearToken();
      window.location.href = '/login';
    }
    return Promise.reject(err);
  }
);
```

## Layout / Navigation pattern
```typescript
// src/components/Layout.tsx
// Sidebar with nav links, top bar with org switcher + user menu
// All authenticated pages render inside <Layout>
```

## Profile page essentials
- Display user name, email
- Organization name + switch org
- Update profile form (name, etc.)
- Sign out: `clearToken()` + `navigate('/login')`

## Form pattern (with React Hook Form + Zod)
```typescript
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const schema = z.object({ name: z.string().min(1) });
type FormData = z.infer<typeof schema>;

const { register, handleSubmit, formState: { errors } } = useForm<FormData>({
  resolver: zodResolver(schema),
});
```

## Table pattern
```typescript
// Use TanStack Table for sortable/filterable data tables
import { useReactTable, getCoreRowModel, flexRender } from '@tanstack/react-table';
```

## Tailwind class conventions
- Layout: `flex`, `grid`, `p-{n}`, `gap-{n}`, `max-w-{n}`
- Cards: `bg-white rounded-lg shadow-sm border border-gray-200 p-6`
- Buttons: `px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700`
- Text: `text-gray-900` (primary), `text-gray-600` (secondary), `text-sm` (small)

## Build verification
```bash
pnpm run build          # always run after substantive changes
pnpm run type-check     # TypeScript only, no emit
```
