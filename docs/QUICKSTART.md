# BeyondC Quick Start Guide 🚀

Get your development environment up and running in 5 minutes.

## 🎯 What You Need

1. **Flutter SDK 3.0+** installed ([Download](https://flutter.dev/docs/get-started/install))
2. **Node.js 18+** installed (for backend API)
3. **VS Code** or **Android Studio** with Flutter extension
4. **Xcode** (Mac only, for iOS) or **Android Studio** (for Android)

---

## ⚡ Quick Setup

### Step 1: Clone & Install Dependencies

```bash
cd beyondc

# Install Next.js backend dependencies
npm install

# Install Flutter dependencies
flutter pub get
```

### Step 2: Download Fonts

Visit these links and download the font families:
- [Plus Jakarta Sans](https://fonts.google.com/specimen/Plus+Jakarta+Sans) - Download weights: 400, 600, 700, 800
- [Space Grotesk](https://fonts.google.com/specimen/Space+Grotesk) - Download weights: 400, 500, 700
- [Nunito](https://fonts.google.com/specimen/Nunito) - Download weights: 400, 600, 700

Extract and place `.ttf` files in `assets/fonts/`

### Step 3: Configure Environment

Create `.env.local` in the root:

```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key

# Razorpay
RAZORPAY_KEY_ID=your_razorpay_key_id
RAZORPAY_KEY_SECRET=your_razorpay_key_secret
```

Get your credentials:
- **Supabase**: [app.supabase.com](https://app.supabase.com) → Your Project → Settings → API
- **Razorpay**: [dashboard.razorpay.com](https://dashboard.razorpay.com) → Settings → API Keys (use Test Mode keys)

### Step 4: Set Up Database

```bash
# Install Supabase CLI (if not installed)
npm install -g supabase

# Link to your project
supabase link --project-ref your-project-ref

# Push migrations
supabase db push
```

Or manually run the SQL files in `supabase/migrations/` in your Supabase dashboard.

### Step 5: Run the Apps

**Backend API & Landing Page:**
```bash
npm run dev
# Visit http://localhost:3000
```

**Flutter Mobile App:**
```bash
flutter run \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key \
  --dart-define=RAZORPAY_KEY_ID=your_key
```

---

## 📱 Platform-Specific Setup

### iOS (Mac only)

1. Install Xcode from App Store
2. Install CocoaPods:
   ```bash
   sudo gem install cocoapods
   ```
3. Install iOS dependencies:
   ```bash
   cd ios
   pod install
   cd ..
   ```
4. Run on simulator:
   ```bash
   flutter run -d ios
   ```

### Android

1. Install Android Studio
2. Create an Android Virtual Device (AVD) via AVD Manager
3. Start the emulator
4. Run the app:
   ```bash
   flutter run -d android
   ```

---

## 🧪 Verify Setup

### Check Backend API
```bash
curl http://localhost:3000/api/auth/refresh
# Should return: {"error": "Missing refresh token"}
```

### Check Flutter App
1. Open the app on emulator/device
2. You should see the splash screen
3. Hot reload with `r` in terminal should work
4. Check fonts are loading (should see Plus Jakarta Sans, not default font)

---

## 📂 Key Files to Know

### Backend
- `app/api/` - All API endpoints
- `lib/validators.ts` - Request validation schemas
- `supabase/migrations/` - Database schema
- `.env.local` - Environment variables
- `BACKEND_README.md` - Full backend documentation

### Flutter
- `lib/main.dart` - App entry point
- `lib/core/theme/` - Design system
- `lib/core/router/app_router.dart` - Navigation setup
- `lib/providers/auth_provider.dart` - Auth state
- `lib/widgets/` - Reusable UI components
- `FLUTTER_SETUP.md` - Full Flutter documentation

---

## 🐛 Common Issues

### Flutter command not found
```bash
# Add Flutter to PATH (replace with your path)
export PATH="$PATH:/path/to/flutter/bin"

# Or use Homebrew (Mac)
brew install flutter
```

### CocoaPods error (iOS)
```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
```

### Android build fails
1. Check `minSdkVersion` is 21+ in `android/app/build.gradle`
2. Run `flutter clean`
3. Try again: `flutter run`

### Fonts not showing
1. Ensure `.ttf` files are in `assets/fonts/`
2. Run `flutter clean && flutter pub get`
3. Hot restart (press `R` in terminal)

### Supabase connection error
1. Verify `.env.local` has correct keys
2. Check Supabase project is not paused
3. Try regenerating the anon key

---

## 📚 Documentation Structure

- **README.md** - Main project overview
- **FLUTTER_SETUP.md** - Complete Flutter setup guide
- **FLUTTER_FOUNDATION.md** - Technical implementation details
- **BACKEND_README.md** - Backend API documentation
- **API_REFERENCE.md** - Complete API endpoint reference
- **assets/fonts/README.md** - Font download instructions

---

## 🎨 Design Resources

- **Colors**: See `lib/core/theme/app_colors.dart`
- **Typography**: See `lib/core/theme/app_typography.dart`
- **Components**: See `lib/widgets/`
- **Figma** (if available): [Link to Figma design]

---

## 🚀 Development Workflow

### Making Changes

1. **Backend Changes**:
   ```bash
   # Edit files in app/api/
   # Changes auto-reload with Next.js
   ```

2. **Flutter Changes**:
   ```bash
   # Edit files in lib/
   # Press 'r' for hot reload
   # Press 'R' for hot restart
   ```

### Adding New Features

1. **New API Endpoint**:
   - Create file in `app/api/your-route/route.ts`
   - Add validation schema in `lib/validators.ts`
   - Update `API_REFERENCE.md`

2. **New Flutter Screen**:
   - Create screen file in `lib/features/[creator|brand]/screens/`
   - Add route in `lib/core/router/app_router.dart`
   - Add route name in `lib/core/router/route_names.dart`

3. **New Widget**:
   - Create widget in `lib/widgets/[category]/`
   - Use design system constants (AppColors, AppTypography, etc.)
   - Add example usage to widget documentation

### Testing

```bash
# Run Flutter tests
flutter test

# Run specific test
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

---

## 🔗 Useful Links

- [Flutter Docs](https://flutter.dev/docs)
- [Next.js Docs](https://nextjs.org/docs)
- [Supabase Docs](https://supabase.com/docs)
- [Razorpay Docs](https://razorpay.com/docs)
- [Riverpod Docs](https://riverpod.dev)
- [GoRouter Docs](https://pub.dev/packages/go_router)

---

## 💡 Pro Tips

1. **Use VS Code Flutter extension** for better autocomplete and debugging
2. **Keep hot reload running** while developing Flutter UI
3. **Use DevTools** (`flutter run` then press `v` to open)
4. **Test on real devices** before deploying
5. **Use --dart-define-from-file** for easier environment variable management:
   ```bash
   flutter run --dart-define-from-file=config.json
   ```

---

## ✅ You're Ready!

Once you complete the setup steps above, you should have:
- ✅ Backend API running on http://localhost:3000
- ✅ Flutter app running on emulator/device
- ✅ Hot reload working
- ✅ Database connected
- ✅ Fonts loading correctly

Start building features! 🚀

---

Need help? Check:
1. **FLUTTER_SETUP.md** - Detailed Flutter guide
2. **BACKEND_README.md** - Backend API documentation
3. **FLUTTER_FOUNDATION.md** - Technical architecture details

Happy coding! 🎉
