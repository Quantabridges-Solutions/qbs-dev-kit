---
description: React web app (Vite + TypeScript + Tailwind) — stack, structure, and conventions
globs: src/frontend/**/*.{ts,tsx}
alwaysApply: false
---

# React Web Standards (Vite + TypeScript + Tailwind)

## Stack
- **Vite** · **React 19** · **TypeScript** (strict) · **Tailwind CSS v4**
- **React Router v6** for routing
- **TanStack Query** (`useQuery` / `useMutation`) for server state
- **Axios** with a single centralized client
- **Lucide React** for icons
- Package manager: **pnpm**

## Directory structure
```
src/
  api/
    client.ts         # Single axios instance — the only place axios is configured
    {domain}.ts       # API functions per domain (e.g. invoices.ts, auth.ts)
  auth/
    token.ts          # JWT get/set/clear
    organization.ts   # Active org context
  components/         # Shared UI components
  pages/              # Route-level components
  hooks/              # Custom hooks
  types/              # Shared TypeScript types/interfaces
```

## API layer
```typescript
// ✅ Always use the centralized client
import { api } from '@/api/client';

// ✅ Wrap in TanStack Query hooks
export const useInvoices = (orgId: string) =>
  useQuery({ queryKey: ['invoices', orgId], queryFn: () => api.get(`/invoices`) });

// ❌ Never create ad-hoc axios instances
const response = await axios.get('/api/invoices');
```

## Auth — OTP flow
1. User enters email → `POST /auth/otp/send`
2. User enters code → `POST /auth/otp/verify` → receives JWT
3. Store JWT in `token.ts`; set `Authorization: Bearer {token}` in axios interceptor
4. Multi-tenant: set `X-Organization-Id` header from `organization.ts`

## Components
- Functional components and hooks only — no class components
- Co-locate component styles in the same file using Tailwind classes
- Extract reusable logic into `src/hooks/use{Name}.ts`
- Prefer composition over large monolithic components

## Build
```bash
pnpm install
pnpm run dev          # local dev
pnpm run build        # production build — always run after substantive changes
pnpm run type-check   # TypeScript check without emitting
```

## Auth — protected routes + useAuth
```tsx
// src/auth/useAuth.ts
export function useAuth() {
  const token = getToken();   // reads from sessionStorage / httpOnly cookie
  const user = token ? parseJwt(token) : null;
  const login = (jwt: string) => { setToken(jwt); queryClient.clear(); };
  const logout = () => { clearToken(); clearOrg(); queryClient.clear(); navigate('/login'); };
  return { user, login, logout, isAuthenticated: !!user };
}

// src/auth/ProtectedRoute.tsx
export function ProtectedRoute({ children }: { children: ReactNode }) {
  const { isAuthenticated } = useAuth();
  if (!isAuthenticated) return <Navigate to="/login" replace />;
  return <>{children}</>;
}

// In router:
<Route path="/dashboard" element={<ProtectedRoute><Dashboard /></ProtectedRoute>} />
```

## Forms — react-hook-form + Zod
```tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const schema = z.object({
  email: z.string().email('Valid email required'),
  amount: z.number().positive('Must be positive'),
});
type FormValues = z.infer<typeof schema>;

function InvoiceForm() {
  const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm<FormValues>({
    resolver: zodResolver(schema),
  });
  const onSubmit = async (data: FormValues) => { await createInvoice(data); };
  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email')} />
      {errors.email && <p className="text-red-500 text-sm">{errors.email.message}</p>}
      <button type="submit" disabled={isSubmitting}>Save</button>
    </form>
  );
}
```
Add: `pnpm add react-hook-form @hookform/resolvers zod`

## Toast notifications
```tsx
// App.tsx — add once at the root:
import { Toaster } from 'react-hot-toast';
<Toaster position="top-right" toastOptions={{ duration: 4000 }} />

// Usage anywhere:
import toast from 'react-hot-toast';
toast.success('Invoice saved');
toast.error('Something went wrong');
const promise = toast.promise(saveAsync(), { loading: 'Saving…', success: 'Saved!', error: 'Failed' });
```
Add: `pnpm add react-hot-toast`

## Loading skeletons
```tsx
// Prefer skeleton screens over spinners for content loads
function InvoiceSkeleton() {
  return (
    <div className="animate-pulse space-y-3">
      <div className="h-4 bg-gray-200 rounded w-3/4" />
      <div className="h-4 bg-gray-200 rounded w-1/2" />
    </div>
  );
}
// Use: if (isLoading) return <InvoiceSkeleton />;
```

## Error boundary
```tsx
// src/components/ErrorBoundary.tsx — wrap route-level components
import { ErrorBoundary } from 'react-error-boundary';
<ErrorBoundary fallback={<p className="text-red-500">Something went wrong.</p>}>
  <Dashboard />
</ErrorBoundary>
```
Add: `pnpm add react-error-boundary`

## Organization switcher
```tsx
// src/auth/organization.ts
export const getActiveOrg = () => localStorage.getItem('active_org_id') ?? '';
export const setActiveOrg = (id: string) => localStorage.setItem('active_org_id', id);
export const clearOrg = () => localStorage.removeItem('active_org_id');

// Axios interceptor (in client.ts):
api.interceptors.request.use(config => {
  const orgId = getActiveOrg();
  if (orgId) config.headers['X-Organization-Id'] = orgId;
  return config;
});

// On org switch: setActiveOrg(newOrgId); queryClient.invalidateQueries();
```

## File uploads — S3 pre-signed URL flow
```tsx
async function uploadFile(file: File, entityId: string) {
  // 1. Get pre-signed URL from API
  const { uploadUrl, key } = await api.post('/files/upload-url', {
    filename: file.name, contentType: file.type, entityId,
  });
  // 2. PUT directly to S3 — no API proxy
  await fetch(uploadUrl, { method: 'PUT', body: file, headers: { 'Content-Type': file.type } });
  // 3. Notify API of completed upload
  await api.post('/files/confirm', { key, entityId });
}
```

## Patterns
- Query keys always include `orgId` for tenant-scoped data
- Invalidate relevant queries after mutations
- Use `React.lazy` + `Suspense` for route-level code splitting
- No `any` types — use `unknown` and narrow explicitly
