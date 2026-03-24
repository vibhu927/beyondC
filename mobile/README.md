# BeyondC Mobile

## Backend Environment Switch (One Change)

The app supports 3 backend target modes via `APP_ENV`:

1. `local_emulator`
2. `local_device`
3. `hosted`

Configured in [mobile/lib/core/constants/api_constants.dart](lib/core/constants/api_constants.dart).

### Option A: Switch from command (recommended)

1. Android Emulator -> local backend on your laptop

```bash
flutter run --dart-define=APP_ENV=local_emulator
```

2. Physical Device (same Wi-Fi as laptop) -> local backend on LAN IP

```bash
flutter run --dart-define=APP_ENV=local_device
```

3. Physical Device or Emulator -> hosted backend

```bash
flutter run --dart-define=APP_ENV=hosted
```

### Option B: Manual one-line change in code

Edit `defaultAppEnv` in [mobile/lib/core/constants/api_constants.dart](lib/core/constants/api_constants.dart):

1. `local_emulator`
2. `local_device`
3. `hosted`

### Local device IP setup

For physical-device local testing, update this line in [mobile/lib/core/constants/api_constants.dart](lib/core/constants/api_constants.dart):

1. `localDeviceApiBaseUrl = 'http://<your-laptop-lan-ip>:3000/api'`

Example: `http://192.168.1.7:3000/api`

### Force any custom backend URL

You can override everything using:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.7:3000/api
```

### Runtime verification

In debug mode, app startup prints active config in logs:

1. `APP_ENV`
2. Effective `API_BASE_URL`
3. `SUPABASE_URL`

Look for log line starting with:

1. `[BeyondC Config] ...`
