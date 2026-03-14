# BeyondC Backend Setup Guide

## Overview
Complete backend infrastructure for BeyondC - a two-sided marketplace connecting brands with creators for collaborations, campaign bidding, event invites, and payments.

## Tech Stack
- **Database**: Supabase (PostgreSQL + RLS + Auth + Storage + Realtime)
- **Framework**: Next.js 14 App Router with TypeScript
- **Payments**: Razorpay for credits and wallet topups
- **Validation**: Zod schemas for all API requests
- **Authentication**: Supabase Auth with role-based access

## Database Schema

### Tables (14)
1. **profiles** - Base user profile (both roles)
2. **creator_profiles** - Creator-specific data (niches, platforms, followers, wallet)
3. **brand_profiles** - Brand-specific data (brand name, category, credits)
4. **campaigns** - Brand campaigns for creator bidding
5. **bids** - Creator bids on campaigns
6. **collab_requests** - Direct collab requests from brands to creators
7. **collabs** - Accepted collaborations with milestone tracking
8. **events** - Brand events for creator invites
9. **event_invites** - Event invitations with QR codes for tickets
10. **credit_transactions** - Brand credit purchase/usage history
11. **wallet_transactions** - Creator wallet topup/deduction history
12. **messages** - In-collab messaging between brand and creator
13. **ratings** - Post-collab ratings (updates avg_rating automatically)
14. **notifications** - Real-time notifications for all actions

### Security
- **RLS enabled** on all tables with role-based policies
- **Privacy-first**: Creator handles hidden until collab accepted
- **creator_discovery_view** - Privacy view for brand discovery (hides handles)
- **Triggers**: Auto-create profiles on signup, update timestamps, calculate avg_rating

## API Structure

### Auth Routes (`/api/auth/`)
- `POST /signup` - User registration with role selection
- `POST /login` - Email/password authentication
- `POST /logout` - Session termination
- `GET /me` - Get current user + profile

### Creator Routes (`/api/creator/`)
- `GET /profile` - Get full creator profile
- `PUT /profile` - Update creator profile (onboarding)
- `GET /campaigns` - Browse active campaigns with filters
- `POST /bids` - Create bid on campaign (checks wallet balance)
- `GET /bids` - Get all own bids
- `DELETE /bids/[id]` - Withdraw pending bid
- `GET /requests` - Get collab requests from brands
- `PUT /requests/[id]` - Accept/reject collab request (deducts collab fee on accept)
- `PUT /collabs/[id]/milestone` - Update milestone status
- `GET /wallet` - Get balance + transactions
- `POST /wallet` - Create topup order (Razorpay)
- `POST /wallet/verify` - Verify payment and add to wallet
- `GET /events` - Get event invites
- `PUT /events/[id]` - Accept/decline event invite (generates QR on accept)
- `GET /events/tickets` - Get all accepted events with QR codes

### Brand Routes (`/api/brand/`)
- `GET /profile` - Get full brand profile
- `PUT /profile` - Update brand profile (onboarding)
- `GET /creators` - Discover creators with filters (uses privacy view)
- `GET /requests` - Get all sent collab requests
- `POST /requests` - Send direct collab request (deducts 1 credit)
- `GET /campaigns` - Get all own campaigns
- `POST /campaigns` - Create new campaign
- `PUT /campaigns/[id]` - Update campaign
- `GET /campaigns/[id]/bids` - Get all bids on campaign
- `PUT /campaigns/[id]/bids/[bidId]` - Accept/reject bid (creates collab on accept)
- `GET /credits` - Get balance + transactions
- `POST /credits` - Purchase credit pack (Razorpay)
- `POST /credits/verify` - Verify payment and add credits
- `GET /events` - Get all own events
- `POST /events` - Create new event
- `POST /events/[id]/invites` - Send invites to creators
- `GET /events/[id]/invites` - Get all invites for event

### Shared Routes
- `GET /collabs/[id]` - Get collab details (both participants)
- `GET /collabs/[id]/messages` - Get all messages in collab
- `POST /collabs/[id]/messages` - Send message (notifies other participant)
- `POST /ratings` - Rate completed collab (auto-updates avg_rating)
- `GET /notifications` - Get all notifications (filter by unread)
- `PUT /notifications/[id]` - Mark single notification as read
- `PUT /notifications/read-all` - Mark all as read

## Setup Instructions

### 1. Install Dependencies
```bash
npm install
```

### 2. Configure Environment Variables
Copy `.env.local.example` to `.env.local` and fill in:
```bash
# Supabase
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key

# Razorpay
NEXT_PUBLIC_RAZORPAY_KEY_ID=your_razorpay_key_id
RAZORPAY_KEY_SECRET=your_razorpay_key_secret

# App URL
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

### 3. Run Database Migrations
Execute migrations in Supabase SQL Editor in this order:
1. `supabase/migrations/20260312000001_initial_schema.sql`
2. `supabase/migrations/20260312000002_rls_policies.sql`
3. `supabase/migrations/20260312000003_triggers.sql`
4. `supabase/migrations/20260312000004_views.sql`

### 4. Start Development Server
```bash
npm run dev
```

## Key Features

### Two-Role System
- **Creator**: Browse campaigns, place bids, manage wallet, track collaborations
- **Brand**: Discover creators, run campaigns, purchase credits, send direct requests

### Collaboration Fees
Based on brand size (stored in paise):
- Micro brands: ₹10-₹30
- Mid-size brands: ₹50-₹100
- Big brands: ₹150-₹300

These fees are deducted from creator wallet when accepting collab requests or winning campaign bids.

### Credit System for Brands
Credit packs:
- Starter: 10 credits for ₹999
- Growth: 25 credits for ₹2,299
- Pro: 50 credits for ₹3,999
- Enterprise: 100 credits for ₹6,999

Credits used for sending direct collab requests (1 credit per request).

### Privacy Controls
- Creator handles (Instagram, YouTube, etc.) hidden in discovery view
- Full creator contact only revealed after collab accepted
- `creator_discovery_view` ensures brands see limited info during discovery

### Milestone Tracking
Collabs follow these milestones:
1. `brief_reviewed` - Creator reviewed campaign brief
2. `draft_submitted` - Creator submitted content draft
3. `content_posted` - Creator posted final content

Each milestone update notifies the brand.

### Payments with Razorpay
- **Creators**: Top up wallet with custom amount
- **Brands**: Purchase credit packs
- Signature verification on all payment callbacks
- Automatic balance updates on successful payment

### Real-time Notifications
15+ notification types:
- Bid updates (placed, accepted, rejected)
- Request updates (sent, accepted, rejected)
- Milestone updates
- Event invites (sent, accepted, declined)
- New messages
- New ratings

## Middleware & Security
- `middleware.ts` protects all API routes
- Role-based access control (creator/brand endpoints separated)
- RLS policies enforce data access rules at database level
- Public routes: `/api/auth/signup`, `/api/auth/login`

## Testing the API

### 1. Create Users
POST `/api/auth/signup`
```json
{
  "email": "creator@example.com",
  "password": "SecurePass123!",
  "display_name": "John Creator",
  "role": "creator"
}
```

### 2. Login
POST `/api/auth/login`
```json
{
  "email": "creator@example.com",
  "password": "SecurePass123!"
}
```

### 3. Complete Onboarding
PUT `/api/creator/profile`
```json
{
  "bio": "Travel content creator",
  "niches": ["travel", "food"],
  "platforms": ["instagram", "youtube"],
  "instagram_handle": "@johncreator",
  "followers_count": 50000,
  "onboarded": true
}
```

## Event QR Codes
When creator accepts event invite, a unique QR code data is generated:
- Stored in `event_invites.qr_code_data`
- Retrieve via `GET /api/creator/events/tickets`
- Frontend can generate QR code image from this data

## Next Steps
- Set up Razorpay webhook handlers for failed payments
- Add real-time subscriptions using Supabase Realtime
- Implement file uploads for campaign briefs and content drafts
- Add analytics endpoints for creator/brand dashboards
- Integrate email notifications via SendGrid/Resend

## File Structure
```
app/api/
├── auth/
│   ├── signup/route.ts
│   ├── login/route.ts
│   ├── logout/route.ts
│   └── me/route.ts
├── creator/
│   ├── profile/route.ts
│   ├── campaigns/route.ts
│   ├── bids/
│   │   ├── route.ts
│   │   └── [id]/route.ts
│   ├── requests/
│   │   ├── route.ts
│   │   └── [id]/route.ts
│   ├── collabs/[id]/milestone/route.ts
│   ├── wallet/
│   │   ├── route.ts
│   │   └── verify/route.ts
│   └── events/
│       ├── route.ts
│       ├── [id]/route.ts
│       └── tickets/route.ts
├── brand/
│   ├── profile/route.ts
│   ├── creators/route.ts
│   ├── requests/route.ts
│   ├── campaigns/
│   │   ├── route.ts
│   │   ├── [id]/route.ts
│   │   └── [id]/bids/
│   │       ├── route.ts
│   │       └── [bidId]/route.ts
│   ├── credits/
│   │   ├── route.ts
│   │   └── verify/route.ts
│   └── events/
│       ├── route.ts
│       └── [id]/invites/route.ts
├── collabs/[id]/
│   ├── route.ts
│   └── messages/route.ts
├── ratings/route.ts
└── notifications/
    ├── route.ts
    ├── [id]/route.ts
    └── read-all/route.ts

lib/
├── supabase/
│   ├── server.ts (createClient, createAdminClient)
│   └── client.ts (browser client)
├── razorpay.ts (Razorpay instance)
├── collabFee.ts (fee calculator)
└── validators.ts (Zod schemas)

supabase/migrations/
├── 20260312000001_initial_schema.sql
├── 20260312000002_rls_policies.sql
├── 20260312000003_triggers.sql
└── 20260312000004_views.sql

middleware.ts (route protection)
```
