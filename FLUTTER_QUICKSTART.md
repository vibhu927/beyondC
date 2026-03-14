# 🚀 Flutter App Setup - Quick Start

Complete guide to install and run the BeyondC Flutter mobile app on Windows.

---

## Prerequisites

- **Windows 10 or higher** (64-bit)
- **Git** installed
- **Chrome** (for web debugging)
- **Android Studio** (for Android development) OR **VS Code** with Flutter extension

---

## Step 1: Install Flutter SDK

### Download Flutter
1. Visit https://docs.flutter.dev/get-started/install/windows
2. Download the latest stable Flutter SDK (Windows ZIP)
3. Extract to a permanent location (e.g., `C:\src\flutter`)
   - **IMPORTANT**: Do NOT install in directories requiring elevated privileges (like `C:\Program Files`)

### Add Flutter to PATH
1. Open **Start Menu** → Search for "Environment Variables"
2. Click **"Edit the system environment variables"**
3. Click **"Environment Variables"** button
4. Under **"User variables"**, find **Path** and click **"Edit"**
5. Click **"New"** and add: `C:\src\flutter\bin` (or your installation path)
6. Click **OK** on all dialogs

### Verify Installation
Open a **NEW** PowerShell/Command Prompt window:
```powershell
flutter --version
flutter doctor
```

You should see Flutter version info and a system health check.

---

## Step 2: Install Android Studio (for Android Development)

### Download & Install
1. Download from https://developer.android.com/studio
2. Run the installer and follow the setup wizard
3. Install these components:
   - Android SDK
   - Android SDK Platform-Tools
   - Android SDK Build-Tools
   - Android Virtual Device (AVD)

### Configure Flutter
```powershell
flutter config --android-studio-dir="C:\Program Files\Android\Android Studio"
```

### Accept Android Licenses
```powershell
flutter doctor --android-licenses
```
Press `y` to accept all licenses.

### Create Android Emulator
1. Open **Android Studio**
2. Click **Device Manager** (phone icon on right sidebar)
3. Click **+ Create Device**
4. Select **Pixel 6** → **Next**
5. Download a system image (e.g., **Tiramisu API 33**) → **Next**
6. Name it "Pixel_6_API_33" → **Finish**

---

## Step 3: Navigate to Project & Install Dependencies

```powershell
# Navigate to the mobile app directory
cd "D:\Groww\Vibe Coding\beyondC\mobile"

# Install all Flutter dependencies
flutter pub get
```

You should see output like:
```
Running "flutter pub get" in mobile...
Resolving dependencies...
...
Got dependencies!
```

---

## Step 4: Configure Supabase & Backend

### Option A: Using --dart-define (Recommended)
When you run the app, pass environment variables:
```powershell
flutter run `
  --dart-define=SUPABASE_URL=https://your-project.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=your-anon-key `
  --dart-define=RAZORPAY_KEY_ID=your-razorpay-key
```

### Option B: Hardcode for Development (Quick Testing)
Edit `mobile\lib\core\constants\api_constants.dart`:
```dart
static const String supabaseUrl = 'https://your-project.supabase.co';
static const String supabaseAnonKey = 'your-anon-key';
static const String razorpayKeyId = 'your-razorpay-key';
```

**Get Your Credentials:**
- **Supabase URL & Key**: https://app.supabase.com → Your Project → Settings → API
- **Razorpay Key**: https://dashboard.razorpay.com → Settings → API Keys (Test Mode)

### Start Backend Server
```powershell
# In a separate terminal
cd "D:\Groww\Vibe Coding\beyondC\backend"
npm run dev
```
Backend runs on `http://localhost:3000`

---

## Step 5: Run the Flutter App

### Start Android Emulator
1. Open **Android Studio**
2. Click **Device Manager**
3. Click ▶️ (Play) next to your emulator
4. Wait for emulator to boot up

### Run the App
```powershell
cd "D:\Groww\Vibe Coding\beyondC\mobile"

# List available devices
flutter devices

# Run on Android emulator
flutter run
```

**OR** run with environment variables:
```powershell
flutter run `
  --dart-define=SUPABASE_URL=https://your-project.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=your-anon-key `
  --dart-define=RAZORPAY_KEY_ID=rzp_test_xxxxx
```

### Hot Reload
While app is running:
- Press **`r`** → Hot reload (fast UI updates)
- Press **`R`** → Hot restart (full app restart)
- Press **`q`** → Quit

---

## Step 6: Download Fonts (Optional but Recommended)

The app uses three custom fonts. Download and place in `mobile\assets\fonts\`:

### Plus Jakarta Sans
https://fonts.google.com/specimen/Plus+Jakarta+Sans
- Download: Regular (400), SemiBold (600), Bold (700), ExtraBold (800)
- Place: `PlusJakartaSans-Regular.ttf`, `PlusJakartaSans-SemiBold.ttf`, etc.

### Space Grotesk
https://fonts.google.com/specimen/Space+Grotesk
- Download: Regular (400), Medium (500), Bold (700)
- Place: `SpaceGrotesk-Regular.ttf`, `SpaceGrotesk-Medium.ttf`, `SpaceGrotesk-Bold.ttf`

### Nunito
https://fonts.google.com/specimen/Nunito
- Download: Regular (400), SemiBold (600), Bold (700)
- Place: `Nunito-Regular.ttf`, `Nunito-SemiBold.ttf`, `Nunito-Bold.ttf`

**Note:** App will work without fonts but will fall back to system fonts.

---

## 🎯 Quick Commands Reference

```powershell
# Check Flutter setup
flutter doctor -v

# List devices
flutter devices

# Clean build files
flutter clean

# Get dependencies
flutter pub get

# Run app (debug mode)
flutter run

# Run app (release mode)
flutter run --release

# Build APK
flutter build apk

# Check for errors
flutter analyze
```

---

## 🐛 Troubleshooting

### "flutter: command not found"
- Restart PowerShell/Command Prompt after adding Flutter to PATH
- Verify PATH: `echo $env:Path` (PowerShell) or `echo %PATH%` (CMD)

### "Android SDK not found"
```powershell
flutter config --android-sdk "C:\Users\YourName\AppData\Local\Android\Sdk"
flutter doctor --android-licenses
```

### "No connected devices"
- Start Android Emulator in Android Studio first
- For physical device: enable USB debugging, connect via cable

### "Could not find a file named pubspec.yaml"
```powershell
# Make sure you're in the mobile directory
cd "D:\Groww\Vibe Coding\beyondC\mobile"
```

### Build errors after pulling new code
```powershell
flutter clean
flutter pub get
flutter run
```

---

## 📱 Testing Auth Flow

Once the app is running:

1. **Splash Screen** (2.5s) → Auto-navigates based on auth state
2. **Onboarding** (3 pages) → Swipe or tap "Next", "Skip", or "Let's Go"
3. **Role Select** → Choose "Creator" or "Brand"
4. **Signup** → Fill form (role-specific fields)
5. **Login** → Email + password (or "Forgot Password")

**Test Credentials:**
- Create new account via signup
- Backend must be running at `http://localhost:3000`

---

## 🎨 App Features

- ✅ **Neo-Brutalist Design** - Solid shadows, neon colors, 2px borders
- ✅ **Role-Based Auth** - Separate flows for Creators & Brands
- ✅ **Form Validation** - Email, phone, password, Instagram handle
- ✅ **State Management** - Riverpod with auth provider
- ✅ **Supabase Integration** - Auth, database, storage
- ✅ **Complete Auth Flow** - Splash, onboarding, role select, signup, login, forgot password

---

## 📚 Additional Documentation

- **Full Setup Guide**: `docs/FLUTTER_SETUP.md`
- **Foundation Architecture**: `docs/FLUTTER_FOUNDATION.md`
- **Backend API**: `docs/API_REFERENCE.md`
- **Backend Setup**: `docs/BACKEND_README.md`
- **Project Overview**: `README.md`

---

## 🆘 Need Help?

1. Check `flutter doctor -v` for system diagnostics
2. Review error messages in terminal
3. Check if backend is running at http://localhost:3000
4. Verify Supabase credentials are correct
5. Try `flutter clean` and `flutter pub get`

---

**Ready to build? Happy coding! 🚀**
