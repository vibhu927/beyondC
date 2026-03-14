# BeyondC - Creator-Brand Collaboration Marketplace

A two-sided marketplace connecting brands with content creators for paid collaborations. Built with **Next.js 14** (landing page & backend API) and **Flutter** (iOS/Android mobile app).

## 🚀 Project Overview

This repository contains three main components:

1. **Backend** (`/backend/`) - Next.js 14 API routes + landing page
2. **Mobile App** (`/mobile/`) - Flutter app for iOS and Android  
3. **Documentation** (`/docs/`) - Setup guides and API reference

## 📁 Repository Structure

```
beyondc/
├── backend/          # Next.js backend + landing page
│   ├── app/         # Next.js app directory
│   ├── components/  # Landing page components
│   ├── lib/         # Backend utilities (validators, Supabase, Razorpay)
│   ├── supabase/    # Database migrations
│   └── ...
├── mobile/          # Flutter mobile app
│   ├── lib/         # Flutter app code
│   ├── assets/      # Images, fonts, icons
│   └── ...
├── docs/            # Documentation
│   ├── BACKEND_README.md
│   ├── API_REFERENCE.md
│   ├── FLUTTER_SETUP.md
│   └── ...
└── README.md        # This file
```

## 🎨 Design System

### Colors
- **Primary**: Neon Yellow-Green (#C8FF00)
- **Secondary**: Hot Pink (#FF2D78)
- **Tertiary**: Electric Blue (#3D5BFF)
- **Purple**: Vivid Purple (#9B5DE5)
- **Orange**: Bright Orange (#FF6B00)

### Typography
- **Display**: Plus Jakarta Sans (headings)
- **Body**: Nunito (paragraphs)
- **Labels**: Space Grotesk (badges, buttons, stats)

### Neo-Brutalist Style
All components feature bold borders and solid color offset shadows (no blur).

---

## 📱 Flutter Mobile App

### Prerequisites
- Flutter SDK 3.0+
- Xcode (for iOS)
- Android Studio (for Android)

### Setup

1. **Navigate to mobile directory:**
   ```bash
   cd mobile
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Download Fonts:**
   - Plus Jakarta Sans (Regular, SemiBold, Bold, ExtraBold)
   - Space Grotesk (Regular, Medium, Bold)
   - Nunito (Regular, SemiBold, Bold)
   
   Place in `mobile/assets/fonts/` (see `mobile/assets/fonts/README.md` for links)

4. **Configure Environment:**
   ```bash
   flutter run --dart-define=SUPABASE_URL=your_url \
               --dart-define=SUPABASE_ANON_KEY=your_key \
               --dart-define=RAZORPAY_KEY_ID=your_key
   ```

5. **Run the app:**
   ```bash
   flutter run -d ios    # iOS
   flutter run -d android # Android
   ```

### Flutter Tech Stack
- **State Management**: Riverpod
- **Navigation**: GoRouter with role-based routing
- **Backend**: Supabase Flutter
- **Payments**: Razorpay Flutter
- **UI**: Material 3 with custom neo-brutalist theme

---

## 🌐 Next.js Backend & Landing Page

### Prerequisites
- Node.js 18+
- npm or yarn

### Setup

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Configure environment variables:**
   ```bash
   cp .env.local.example .env.local
   # Edit .env.local with your Supabase and Razorpay credentials
   ```

4. **Run the development server:**
   ```bash
   npm run dev
   ```

5. **Open [http://localhost:3000](http://localhost:3000)**

## 🏗️ Project Structure

### Backend (`/backend/`)
```
backend/
├── app/
│   ├── api/                   # Backend API routes
│   │   ├── auth/             # Authentication endpoints
│   │   ├── creator/          # Creator-specific endpoints
│   │   ├── brand/            # Brand-specific endpoints
│   │   ├── collabs/          # Collaboration endpoints
│   │   ├── ratings/          # Rating endpoints
│   │   └── notifications/    # Notification endpoints
│   ├── layout.tsx             # Root layout
│   ├── page.tsx               # Landing page
│   └── globals.css            # Global styles
├── components/
│   └── landing/               # Landing page components
│       ├── Navbar.tsx
│       ├── Hero.tsx
│       ├── Marquee.tsx
│       └── ... (13 sections)
├── lib/
│   ├── supabase/             # Supabase client
│   ├── validators.ts          # Zod validation schemas
│   ├── razorpay.ts           # Razorpay integration
│   └── collabFee.ts          # Fee calculation logic
├── supabase/
│   └── migrations/           # Database migrations (14 tables)
├── package.json              # Node dependencies
└── ... (next.config.js, tailwind.config.ts)
```

### Mobile App (`/mobile/`)
```
mobile/
├── lib/
│   ├── main.dart              # App entry point
│   ├── app.dart               # MaterialApp root
│   ├── core/
│   │   ├── theme/            # Design system (colors, typography, spacing, shadows)
│   │   ├── router/           # GoRouter config + role-based routing
│   │   ├── constants/        # App constants & API config
│   │   └── utils/            # Formatters & validators
│   ├── data/
│   │   ├── models/           # Data models
│   │   ├── repositories/     # Data repositories
│   │   └── services/         # API services (Supabase, Storage, Razorpay)
│   ├── providers/            # Riverpod state providers
│   ├── features/             # Feature-specific screens & widgets
│   │   ├── onboarding/
│   │   ├── auth/
│   │   ├── creator/
│   │   ├── brand/
│   │   └── shared/
│   └── widgets/              # Reusable UI components
│       ├── buttons/
│       ├── cards/
│       ├── inputs/
│       ├── badges/
│       └── loaders/
├── assets/
│   ├── fonts/                # Custom fonts
│   ├── images/               # Static images
│   ├── icons/                # Icon assets
│   └── animations/           # Lottie animations
└── pubspec.yaml              # Flutter dependencies
```

### Documentation (`/docs/`)
```
docs/
├── BACKEND_README.md         # Backend documentation
├── API_REFERENCE.md          # Complete API reference
├── FLUTTER_SETUP.md          # Flutter setup guide
├── FLUTTER_FOUNDATION.md     # Technical architecture
└── QUICKSTART.md             # Quick start guide
```

---

## 🔌 Backend API

The Next.js API provides 43 endpoints across 6 categories:

### Authentication (4 endpoints)
- POST `/api/auth/signup` - Create account with role
- POST `/api/auth/login` - Sign in
- POST `/api/auth/logout` - Sign out
- POST `/api/auth/refresh` - Refresh session

### Creator Endpoints (16 endpoints)
- Profile, wallet, campaigns, bids, collabs management
- Payment initiation/verification
- Event invites

### Brand Endpoints (17 endpoints)
- Profile, credits, campaigns, collabs, events management
- Payment processing
- Creator discovery

### Shared Endpoints (6 endpoints)
- Collaborations, ratings, notifications
- Real-time updates

See `docs/BACKEND_README.md` and `docs/API_REFERENCE.md` for full documentation.

---

## 🎯 Key Sections

1. **Hero** - Full viewport height with parallax blobs and floating cards
2. **Marquee** - Infinite scrolling ticker with creator niches and brand types
3. **How It Works** - Tab-based flow for creators and brands
4. **Privacy First** - Showcasing the privacy-first matching system
5. **Collab Types** - Four types of collaborations (Paid, Barter, Hybrid, Event)
6. **Event Invites** - Digital ticket system for IRL events
7. **Stats** - Animated count-up stats with Intersection Observer
8. **For Creators** - Benefits and dashboard preview
9. **For Brands** - Features and campaign card preview
10. **Pricing** - Credit packs and wallet tiers
11. **FAQ** - Accordion-style frequently asked questions
12. **Waitlist** - Email capture with localStorage
13. **Footer** - Links and branding

## 🎨 Color Palette

- **Neon Yellow-Green** (#C8FF00) - Primary brand color
- **Hot Pink** (#FF2D78) - Secondary accent
- **Electric Blue** (#3D5BFF) - Tertiary accent
- **Vivid Purple** (#9B5DE5) - Fourth accent
- **Bright Orange** (#FF6B00) - Fifth accent
- **Ink Black** (#0D0D0D) - Text and borders
- **Muted Gray** (#6B6B6B) - Secondary text

## 🚧 Build & Deploy

### Backend
Build for production:
```bash
cd backend
npm run build
```

Start production server:
```bash
cd backend
npm start
```

### Mobile
Build Android APK:
```bash
cd mobile
flutter build apk --release
```

Build iOS IPA:
```bash
cd mobile
flutter build ios --release
```

## 📚 Documentation

- **[Quick Start Guide](docs/QUICKSTART.md)** - Get started in 5 minutes
- **[Flutter Setup](docs/FLUTTER_SETUP.md)** - Complete Flutter app setup
- **[Backend Docs](docs/BACKEND_README.md)** - Backend API documentation
- **[API Reference](docs/API_REFERENCE.md)** - All API endpoints
- **[Flutter Architecture](docs/FLUTTER_FOUNDATION.md)** - Technical details

## 📝 License

All rights reserved © 2025 BeyondC
