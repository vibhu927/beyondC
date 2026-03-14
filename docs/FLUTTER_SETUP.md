# Flutter App Setup Guide

Quick reference for setting up and working with the BeyondC Flutter mobile app.

## ✅ Initial Setup (One-time)

### 1. Install Flutter SDK
```bash
# Check if Flutter is installed
flutter --version

# If not installed, download from: https://flutter.dev/docs/get-started/install
```

### 2. Install Dependencies
```bash
cd beyondc
flutter pub get
```

### 3. Download Required Fonts
Visit these Google Fonts links and download the font families:

**Plus Jakarta Sans** (for headings)  
https://fonts.google.com/specimen/Plus+Jakarta+Sans
- Download weights: Regular (400), SemiBold (600), Bold (700), ExtraBold (800)

**Space Grotesk** (for labels/badges)  
https://fonts.google.com/specimen/Space+Grotesk
- Download weights: Regular (400), Medium (500), Bold (700)

**Nunito** (for body text)  
https://fonts.google.com/specimen/Nunito
- Download weights: Regular (400), SemiBold (600), Bold (700)

Extract the `.ttf` files and place them in `assets/fonts/`:
```
assets/fonts/
├── PlusJakartaSans-Regular.ttf
├── PlusJakartaSans-SemiBold.ttf
├── PlusJakartaSans-Bold.ttf
├── PlusJakartaSans-ExtraBold.ttf
├── SpaceGrotesk-Regular.ttf
├── SpaceGrotesk-Medium.ttf
├── SpaceGrotesk-Bold.ttf
├── Nunito-Regular.ttf
├── Nunito-SemiBold.ttf
└── Nunito-Bold.ttf
```

### 4. Configure Environment Variables

Create a `.env` file in the root or use `--dart-define` flags:

```bash
# Option 1: Using --dart-define (recommended for development)
flutter run \
  --dart-define=SUPABASE_URL=your_supabase_url \
  --dart-define=SUPABASE_ANON_KEY=your_supabase_anon_key \
  --dart-define=RAZORPAY_KEY_ID=your_razorpay_key_id

# Option 2: Hardcode in lib/core/constants/api_constants.dart (not recommended for production)
```

Get your credentials:
- **Supabase**: https://app.supabase.com → Your Project → Settings → API
- **Razorpay**: https://dashboard.razorpay.com → Settings → API Keys (Test Mode)

---

## 🚀 Running the App

### Run on iOS Simulator
```bash
flutter run -d ios
```

### Run on Android Emulator
```bash
flutter run -d android
```

### Run on Physical Device
```bash
# List connected devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

### Hot Reload
While the app is running:
- Press `r` for hot reload
- Press `R` for hot restart
- Press `q` to quit

---

## 📦 Key Dependencies

### State Management
- `flutter_riverpod` (^2.5.1) - Reactive state management
- `riverpod_annotation` (^2.3.5) - Code generation for providers

### Navigation
- `go_router` (^13.2.0) - Declarative routing with deep linking

### Backend & Storage
- `supabase_flutter` (^2.5.0) - Supabase client for auth & database
- `dio` (^5.4.3) - HTTP client for API calls
- `flutter_secure_storage` (^9.0.0) - Secure token storage

### Payments
- `razorpay_flutter` (^1.3.6) - Razorpay payment gateway

### UI Components
- `google_fonts` (^6.2.1) - Custom fonts
- `flutter_svg` (^2.0.10+1) - SVG rendering
- `cached_network_image` (^3.3.1) - Image caching
- `shimmer` (^3.0.0) - Loading skeletons
- `lottie` (^3.1.0) - Animations
- `qr_flutter` (^4.1.0) - QR code generation

### Utilities
- `intl` (^0.19.0) - Date formatting & internationalization
- `image_picker` (^1.0.7) - Photo/video selection
- `url_launcher` (^6.2.5) - Open URLs/emails/phone
- `timeago` (^3.6.0) - Relative time formatting

---

## 🎨 Design System

### Colors
Access via `AppColors`:
```dart
AppColors.neon      // #C8FF00 (Primary)
AppColors.pink      // #FF2D78 (Secondary)
AppColors.blue      // #3D5BFF (Tertiary)
AppColors.purple    // #9B5DE5
AppColors.orange    // #FF6B00
AppColors.ink       // #0D0D0D (Borders/Text)
```

### Typography
Access via `AppTypography`:
```dart
AppTypography.displayXL  // 40px, ExtraBold (Plus Jakarta Sans)
AppTypography.bodyMD     // 16px, Regular (Nunito)
AppTypography.labelSM    // 12px, Bold (Space Grotesk)
```

### Spacing
Access via `AppSpacing`:
```dart
AppSpacing.xs        // 4.0
AppSpacing.sm        // 8.0
AppSpacing.md        // 12.0
AppSpacing.lg        // 16.0
AppSpacing.xl        // 20.0
AppSpacing.xxl       // 24.0
AppSpacing.huge      // 32.0
AppSpacing.massive   // 48.0
```

### Shadows (Neo-Brutalist)
Access via `AppShadows`:
```dart
AppShadows.neon      // Neon box shadow
AppShadows.pink      // Pink box shadow
AppShadows.pressed   // No shadow (pressed state)
```

---

## 🧩 Core Components

### Buttons
```dart
// Primary button with neon color
BCPrimaryButton.neon(
  text: 'Continue',
  onPressed: () {},
)

// With loading state
BCPrimaryButton.neon(
  text: 'Submit',
  onPressed: () {},
  isLoading: true,
)

// Full width
BCPrimaryButton.neon(
  text: 'Get Started',
  onPressed: () {},
  isFullWidth: true,
)
```

### Cards
```dart
BCCard(
  shadow: AppShadows.blue,
  child: Text('Card content'),
  onTap: () {},
)
```

### Badges
```dart
BCBadge(
  text: 'Active',
  variant: BCBadgeVariant.success,
  emoji: '✅',
)
```

### Text Fields
```dart
BCTextField(
  label: 'Email',
  controller: emailController,
  validator: (value) => value?.isEmpty == true ? 'Required' : null,
  prefixIcon: Icons.email,
)
```

---

## 🔐 Authentication

### Check Auth State
```dart
final auth = ref.watch(authProvider);

if (auth.isAuthenticated) {
  // User is logged in
  final user = auth.user;
  final role = auth.role; // 'creator' or 'brand'
}
```

### Sign Out
```dart
ref.read(authProvider.notifier).signOut();
```

---

## 🗺️ Navigation

### Navigation via GoRouter
```dart
// Navigate to a route
context.go(RouteNames.creatorHome);

// Navigate with parameters
context.go('${RouteNames.campaignDetails}/campaign-id-123');

// Go back
context.pop();
```

### Route Protection
Routes are automatically protected based on authentication and role:
- Unauthenticated users → `/onboarding`
- Creators → Can access `/creator/*` routes only
- Brands → Can access `/brand/*` routes only

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

---

## 📱 Building for Release

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS IPA
```bash
flutter build ios --release
# Then open ios/Runner.xcworkspace in Xcode to archive
```

---

## 🐛 Troubleshooting

### Flutter command not found
Add Flutter to your PATH:
```bash
# macOS/Linux (add to ~/.zshrc or ~/.bashrc)
export PATH="$PATH:/path/to/flutter/bin"

# Windows
# Add C:\path\to\flutter\bin to System Environment Variables
```

### Fonts not showing
1. Ensure `.ttf` files are in `assets/fonts/`
2. Verify `pubspec.yaml` has correct font declarations
3. Run `flutter clean` then `flutter pub get`

### Supabase connection error
1. Check `SUPABASE_URL` and `SUPABASE_ANON_KEY` are set
2. Verify your Supabase project is active
3. Check if you're using the correct API endpoint

### Razorpay not working
1. Ensure you're using Test Mode keys in development
2. For iOS, add `razorpay_flutter` to `Info.plist`
3. For Android, verify minSdkVersion is 21+

### Hot reload not working
1. Try hot restart (`R` in terminal)
2. Stop the app and run `flutter clean`
3. Restart your IDE

---

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Supabase Flutter Documentation](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- [Razorpay Flutter Documentation](https://razorpay.com/docs/payments/payment-gateway/flutter-integration/)

---

## 🚧 Current Status

### ✅ Completed
- Project structure and folder setup
- Design system (colors, typography, spacing, shadows, theme)
- Core constants (app constants, API constants)
- Router with role-based protection
- Auth provider with Supabase integration
- Core widgets (button, card, badge, text field)
- App entry point with orientation lock

### 🔄 In Progress
- Font files need to be downloaded
- `flutter pub get` needs to be run

### ⏳ Pending
- Additional widgets (loaders, dropdowns, bottom nav)
- Data models (creator, brand, campaign, bid, collab, etc.)
- Repository layer (API wrappers)
- Service layer (Supabase, storage, Razorpay)
- Additional providers (creator, brand, campaign, etc.)
- Screen implementations (explicitly not started per user request)

---

Built with ❤️ by the BeyondC team
