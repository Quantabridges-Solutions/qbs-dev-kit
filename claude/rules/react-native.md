---
description: React Native (Expo) mobile app — navigation, auth, SecureStore, and conventions
paths:
  - src/mobile/**/*.ts
  - src/mobile/**/*.tsx
---

# React Native Standards (Expo)

## Stack
Expo managed workflow (SDK 51+) · Expo Router · TypeScript strict · TanStack Query · Axios · Expo SecureStore

## Directory structure (Expo Router)
```
app/
  (auth)/
    login.tsx       # OTP send — email input → POST /auth/otp/send
    verify.tsx      # OTP verify — code input → POST /auth/otp/verify → store JWT
    register.tsx
  (app)/
    _layout.tsx     # Tab nav + auth guard
    index.tsx       # Dashboard
    profile.tsx
  _layout.tsx       # Root layout — auth check, splash
src/
  api/client.ts     # Axios instance with SecureStore interceptor
  components/
  hooks/
```

## Auth guard (root `app/_layout.tsx`)
```typescript
const token = await SecureStore.getItemAsync('auth_token');
if (!token) router.replace('/(auth)/login');
```

## JWT storage
```typescript
// Store
await SecureStore.setItemAsync('auth_token', token);
// Read (in axios interceptor)
const token = await SecureStore.getItemAsync('auth_token');
// Clear (logout)
await SecureStore.deleteItemAsync('auth_token');
router.replace('/(auth)/login');
```

## API client
```typescript
api.interceptors.request.use(async config => {
  const token = await SecureStore.getItemAsync('auth_token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});
```

## Splash screen
```typescript
await SplashScreen.preventAutoHideAsync();
// ... check auth, load fonts
await SplashScreen.hideAsync();
```

## Conventions
- Use `StyleSheet.create` or NativeWind — no inline style objects
- Handle keyboard avoiding on all input screens
- Test on both iOS and Android before marking complete
- `EXPO_PUBLIC_` prefix for env vars exposed to app
