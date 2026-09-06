---
name: react-native-expo
description: Add new screens or features to a React Native Expo app. Covers screen creation, navigation, API integration, and UI patterns. Use when the user asks to add a screen, mobile page, React Native component, Expo screen, or mobile feature.
license: CC-BY-ND-4.0
---

# React Native Expo Screen

## New screen checklist

1. Create screen file in `app/(app)/` (or appropriate route group)
2. Add to navigation (tab bar or stack)
3. Create any API hooks needed in `src/api/`
4. Add types to `src/types/` if new data shapes

## Screen template
```typescript
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { useRouter } from 'expo-router';
import { useQuery } from '@tanstack/react-query';
import { api } from '@/src/api/client';

export default function MyScreen() {
  const router = useRouter();
  const { data, isLoading, error } = useQuery({
    queryKey: ['myData'],
    queryFn: () => api.get('/my-endpoint').then(r => r.data),
  });

  if (isLoading) return <LoadingView />;
  if (error) return <ErrorView error={error} />;

  return (
    <ScrollView style={styles.container}>
      <Text style={styles.title}>Screen Title</Text>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff' },
  title: { fontSize: 24, fontWeight: 'bold', padding: 16 },
});
```

## OTP Auth screens

### Login screen (`app/(auth)/login.tsx`)
```typescript
// 1. Input: email or phone number
// 2. Call POST /auth/otp/send
// 3. Navigate to verify screen with email param
router.push({ pathname: '/(auth)/verify', params: { email } });
```

### Verify screen (`app/(auth)/verify.tsx`)
```typescript
// 1. Input: 6-digit OTP code
// 2. Call POST /auth/otp/verify
// 3. Store JWT: await SecureStore.setItemAsync('auth_token', token)
// 4. Navigate to app: router.replace('/(app)')
```

## Navigation patterns

### Tab bar (in `app/(app)/_layout.tsx`)
```typescript
import { Tabs } from 'expo-router';
import { Home, FileText, User } from 'lucide-react-native';

export default function AppLayout() {
  return (
    <Tabs screenOptions={{ tabBarActiveTintColor: '#007AFF' }}>
      <Tabs.Screen name="index" options={{ title: 'Home', tabBarIcon: ({ color }) => <Home color={color} /> }} />
      <Tabs.Screen name="profile" options={{ title: 'Profile', tabBarIcon: ({ color }) => <User color={color} /> }} />
    </Tabs>
  );
}
```

### Auth guard (root `app/_layout.tsx`)
```typescript
const token = await SecureStore.getItemAsync('auth_token');
if (!token) {
  router.replace('/(auth)/login');
}
```

## API client setup
```typescript
// src/api/client.ts
import axios from 'axios';
import * as SecureStore from 'expo-secure-store';

export const api = axios.create({ baseURL: process.env.EXPO_PUBLIC_API_URL });

api.interceptors.request.use(async config => {
  const token = await SecureStore.getItemAsync('auth_token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});
```

## Environment variables
Use `EXPO_PUBLIC_` prefix for variables exposed to the app:
```
EXPO_PUBLIC_API_URL=https://your-api.execute-api.eu-west-1.amazonaws.com
```

## Profile screen essentials
- Display user name, email
- Organization switcher (if multi-tenant)
- Logout button: clear SecureStore + router.replace('/(auth)/login')

## Splash screen setup
```json
// app.json
{
  "expo": {
    "splash": {
      "image": "./assets/splash.png",
      "resizeMode": "contain",
      "backgroundColor": "#ffffff"
    }
  }
}
```
```typescript
// app/_layout.tsx
import * as SplashScreen from 'expo-splash-screen';
SplashScreen.preventAutoHideAsync();
// After fonts/auth check:
SplashScreen.hideAsync();
```
