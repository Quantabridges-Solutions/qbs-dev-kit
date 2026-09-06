---
name: eas-release
description: Build and submit QBS Expo apps with EAS for iOS and Android, including eas.json profiles, GitHub Actions, and required secrets. Use when the user asks for EAS, App Store, Play Store, Android build, iOS submit, or mobile release.
license: CC-BY-ND-4.0
---

# EAS release (iOS + Android)

Project lives in `src/mobile`. Requires Expo account token `EXPO_TOKEN`.

## Profiles (`src/mobile/eas.json`)

```json
{
  "cli": { "version": ">= 12.0.0" },
  "build": {
    "development": { "developmentClient": true, "distribution": "internal" },
    "preview": { "distribution": "internal" },
    "production": { "autoIncrement": true }
  },
  "submit": {
    "production": {}
  }
}
```

## Local

```bash
cd src/mobile
pnpm dlx eas-cli login
pnpm dlx eas-cli build --platform ios --profile production
pnpm dlx eas-cli build --platform android --profile production
pnpm dlx eas-cli submit --platform ios --latest
pnpm dlx eas-cli submit --platform android --latest
```

Android production needs a Play service account key or `eas credentials`. Do not commit keystores; use EAS-managed credentials.

## CI

Kit templates:

- `.github/workflows/mobile-ios-build.yml`
- `.github/workflows/mobile-android-build.yml`

Both use `expo/expo-github-action` and `secrets.EXPO_TOKEN`. Production submit is gated on the `production` profile.

## Env

`EXPO_PUBLIC_API_URL` must point at the deployed API (`terraform output api_url`), not localhost.

## Checklist

- [ ] `app.json` / `app.config.ts` bundle IDs match store listings
- [ ] OTP login still uses SecureStore (not AsyncStorage) for the JWT
- [ ] Preview profile used for QA; production only on `main` or `workflow_dispatch`
