---
description: React Native (Expo) mobile app — stack, navigation, auth, and conventions
globs: src/mobile/**/*.{ts,tsx}
alwaysApply: false
---

# React Native Standards (Expo)

## Stack
- **Expo** managed workflow (SDK 51+)
- **Expo Router** for file-based navigation
- **React Native Paper** or **NativeWind** for UI
- **TanStack Query** for server state
- **Axios** with centralized client (mirrors web pattern)
- **Expo SecureStore** for token storage (not AsyncStorage for auth tokens)
- TypeScript strict mode

## Directory structure (Expo Router)
```
app/
  (auth)/
    login.tsx         # OTP send screen
    verify.tsx        # OTP verify screen
    register.tsx      # Sign up screen
  (app)/
    _layout.tsx       # Tab navigation + auth guard
    index.tsx         # Home / dashboard
    profile.tsx       # Profile screen
  _layout.tsx         # Root layout (auth check, splash)
src/
  api/
    client.ts         # Axios instance
    {domain}.ts
  components/         # Shared UI
  hooks/
  types/
assets/
  splash.png
  icon.png
```

## Navigation
- Expo Router file-based routing
- Auth guard in `(app)/_layout.tsx` — redirect to `/(auth)/login` if no token
- Tab bar in `(app)/_layout.tsx`; stack navigation inside tabs as needed

## Auth — OTP flow
1. `/(auth)/login` → enter email/phone → `POST /auth/otp/send`
2. `/(auth)/verify` → enter 6-digit code → `POST /auth/otp/verify` → JWT
3. Store JWT in `Expo.SecureStore` (key: `auth_token`)
4. On app start, check for token; redirect accordingly

## Splash screen
- Configure in `app.json` under `expo.splash`
- Use `expo-splash-screen` to delay until fonts/data loaded:
```typescript
await SplashScreen.preventAutoHideAsync();
// ... load fonts, check auth
await SplashScreen.hideAsync();
```

## API client
```typescript
// Identical pattern to web — single axios instance
import { api } from '@/src/api/client';
// Interceptor reads token from SecureStore and sets Authorization header
```

## Build
```bash
npx expo start              # dev mode
npx expo run:ios            # local iOS build
npx expo run:android        # local Android build
eas build --platform ios    # EAS cloud build
```

## Push notifications (Expo)
```typescript
import * as Notifications from 'expo-notifications';
import * as Device from 'expo-device';

Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true, shouldPlaySound: true, shouldSetBadge: true,
  }),
});

export async function registerForPushNotificationsAsync(): Promise<string | null> {
  if (!Device.isDevice) return null;                    // won't work in simulator
  const { status } = await Notifications.requestPermissionsAsync();
  if (status !== 'granted') return null;
  const token = (await Notifications.getExpoPushTokenAsync()).data;
  await api.post('/devices/register', { pushToken: token });  // save to API
  return token;
}
// Call registerForPushNotificationsAsync() after login, store token in API against user
```
Add: `npx expo install expo-notifications expo-device`

## Deep links
```typescript
// app.json:
// { "expo": { "scheme": "{project-name}", "intentFilters": [...] } }

// Handle in root _layout.tsx:
import * as Linking from 'expo-linking';
const url = Linking.useURL();
useEffect(() => {
  if (!url) return;
  const { path, queryParams } = Linking.parse(url);
  // e.g. path "verify" with token param → navigate to verify screen
  if (path === 'verify') router.push({ pathname: '/(auth)/verify', params: queryParams });
}, [url]);
// Deep link example: {project-name}://verify?token=xyz
```
Add: `npx expo install expo-linking`

## Lists — FlatList with pagination + pull-to-refresh
```tsx
function InvoiceList() {
  const { data, fetchNextPage, hasNextPage, refetch, isRefetching } = useInfiniteQuery({
    queryKey: ['invoices', orgId],
    queryFn: ({ pageParam = 1 }) =>
      api.get<PagedResult<Invoice>>(`/invoices?page=${pageParam}&pageSize=25`).then(r => r.data),
    getNextPageParam: last => last.hasNextPage ? last.page + 1 : undefined,
    initialPageParam: 1,
  });
  const items = data?.pages.flatMap(p => p.items) ?? [];

  return (
    <FlatList
      data={items}
      keyExtractor={item => item.id}
      renderItem={({ item }) => <InvoiceRow item={item} />}
      refreshControl={<RefreshControl refreshing={isRefetching} onRefresh={refetch} />}
      onEndReached={() => hasNextPage && fetchNextPage()}
      onEndReachedThreshold={0.5}
      ListEmptyComponent={<EmptyState message="No invoices yet" />}
    />
  );
}
```

## Forms — react-hook-form + Zod
```tsx
import { Controller, useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';

const { control, handleSubmit, formState: { errors } } = useForm({
  resolver: zodResolver(schema),
});

// Always use <Controller> for React Native inputs (no register prop spread):
<Controller
  control={control}
  name="email"
  render={({ field: { onChange, value } }) => (
    <TextInput value={value} onChangeText={onChange} keyboardType="email-address" />
  )}
/>
{errors.email && <Text style={styles.error}>{errors.email.message}</Text>}
```
Add: `pnpm add react-hook-form @hookform/resolvers zod`

## Organization switcher
```typescript
import * as SecureStore from 'expo-secure-store';
// Active org stored in SecureStore alongside auth token
export const getActiveOrg = () => SecureStore.getItemAsync('active_org_id');
export const setActiveOrg = (id: string) => SecureStore.setItemAsync('active_org_id', id);
// On org switch: await setActiveOrg(newId); queryClient.invalidateQueries();
```

## File uploads — S3 pre-signed URL + image picker
```typescript
import * as ImagePicker from 'expo-image-picker';

async function pickAndUpload(entityId: string) {
  const result = await ImagePicker.launchImageLibraryAsync({ mediaTypes: ['images'] });
  if (result.canceled) return;
  const asset = result.assets[0];
  // 1. Get pre-signed URL
  const { uploadUrl, key } = await api.post('/files/upload-url', {
    filename: asset.fileName, contentType: 'image/jpeg', entityId,
  }).then(r => r.data);
  // 2. Upload directly to S3
  await fetch(uploadUrl, { method: 'PUT', body: { uri: asset.uri, type: 'image/jpeg', name: asset.fileName } as any });
  // 3. Confirm with API
  await api.post('/files/confirm', { key, entityId });
}
```
Add: `npx expo install expo-image-picker`

## Conventions
- Use `StyleSheet.create` or NativeWind — no inline style objects
- Handle keyboard avoiding (`KeyboardAvoidingView`) on all input screens
- Always request permissions gracefully with a pre-permission explanation; handle denial
- Test on both iOS and Android simulators before marking complete
- Use `expo-secure-store` for all auth tokens and sensitive values — never `AsyncStorage`
