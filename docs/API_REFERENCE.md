# BeyondC Complete API Endpoints Reference

## Authentication Endpoints

### POST `/api/auth/signup`
**Description:** Register new user with role selection  
**Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "role": "creator" | "brand",
  "display_name": "John Doe"
}
```
**Response:** User object with auth session  
**Notes:** Trigger auto-creates profile and role-specific profile

---

### POST `/api/auth/login`
**Description:** Authenticate user  
**Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```
**Response:** User object with auth session

---

### POST `/api/auth/logout`
**Description:** Terminate user session  
**Body:** None  
**Response:** Success message

---

### GET `/api/auth/me`
**Description:** Get current user with full profile  
**Response:** User object with nested profile data

---

## Creator Endpoints

### GET `/api/creator/profile`
**Description:** Get full creator profile with all fields  
**Response:** Profile with creator_profiles joined data

---

### PUT `/api/creator/profile`
**Description:** Update creator profile (onboarding)  
**Body:**
```json
{
  "display_name": "John Creator",
  "bio": "Travel content creator",
  "niches": ["travel", "food"],
  "platforms": ["instagram", "youtube"],
  "instagram_handle": "@johncreator",
  "followers_count": 50000,
  "engagement_rate": 4.5,
  "onboarded": true
}
```
**Response:** Updated profile

---

### GET `/api/creator/campaigns`
**Description:** Browse active campaigns with filters  
**Query Params:**
- `niche`: Filter by niche
- `collab_type`: paid, barter, hybrid
- `min_budget`: Minimum budget in paise
- `max_budget`: Maximum budget in paise
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 20, max: 50)

**Response:** Paginated campaigns with brand details and bid counts

---

### GET `/api/creator/bids`
**Description:** Get all creator's bids  
**Response:** Array of bids with campaign and brand details

---

### POST `/api/creator/bids`
**Description:** Place bid on campaign  
**Body:**
```json
{
  "campaign_id": "uuid",
  "message": "I'd love to work on this campaign..."
}
```
**Response:** Created bid  
**Notes:** 
- Validates wallet balance against collab fee before bidding
- Creates notification for brand
- Returns error if insufficient wallet balance

---

### DELETE `/api/creator/bids/[id]`
**Description:** Withdraw pending bid  
**Response:** Success message  
**Notes:** Only works on pending bids, updates status to 'withdrawn'

---

### GET `/api/creator/requests`
**Description:** Get all collab requests sent to creator  
**Response:** Array of requests with brand details

---

### PUT `/api/creator/requests/[id]`
**Description:** Accept or reject collab request  
**Body:**
```json
{
  "action": "accept" | "reject"
}
```
**Response:** Updated request or created collab  
**Notes:**
- On accept: Validates wallet balance, deducts collab fee, creates collab
- On reject: Updates status and notifies brand
- Creates notification for brand in both cases

---

### PUT `/api/creator/collabs/[id]/milestone`
**Description:** Update collaboration milestone status  
**Body:**
```json
{
  "milestone": "brief_reviewed" | "draft_submitted" | "content_posted"
}
```
**Response:** Updated collab  
**Notes:** Creates notification for brand on each milestone update

---

### GET `/api/creator/wallet`
**Description:** Get wallet balance and transaction history  
**Response:**
```json
{
  "balance": 50000,
  "transactions": [...]
}
```

---

### POST `/api/creator/wallet`
**Description:** Create wallet topup order  
**Body:**
```json
{
  "amount": 50000  // in paise (₹500)
}
```
**Response:** Razorpay order details  
**Notes:** Minimum ₹100 (10000 paise)

---

### POST `/api/creator/wallet/verify`
**Description:** Verify payment and credit wallet  
**Body:**
```json
{
  "razorpay_order_id": "order_...",
  "razorpay_payment_id": "pay_...",
  "razorpay_signature": "signature..."
}
```
**Response:** Updated wallet balance  
**Notes:** Verifies Razorpay signature before crediting

---

### GET `/api/creator/events`
**Description:** Get event invites  
**Query Params:**
- `status`: pending, accepted, declined (optional)

**Response:** Array of invites with event and brand details

---

### PUT `/api/creator/events/[id]`
**Description:** Accept or decline event invite  
**Body:**
```json
{
  "action": "accept" | "reject"
}
```
**Response:** Updated invite  
**Notes:** Generates QR code data on accept

---

### GET `/api/creator/events/tickets`
**Description:** Get all accepted event tickets with QR codes  
**Response:** Array of accepted invites with full event details and QR data

---

## Brand Endpoints

### GET `/api/brand/profile`
**Description:** Get full brand profile  
**Response:** Profile with brand_profiles joined data

---

### PUT `/api/brand/profile`
**Description:** Update brand profile (onboarding)  
**Body:**
```json
{
  "display_name": "Acme Corp",
  "brand_name": "Acme",
  "brand_category": "Fashion",
  "description": "Leading fashion brand...",
  "logo_url": "https://...",
  "website": "https://acme.com",
  "contact_email": "contact@acme.com",
  "size": "micro" | "mid" | "big",
  "onboarded": true
}
```
**Response:** Updated profile

---

### GET `/api/brand/creators`
**Description:** Discover creators with filters (uses privacy view)  
**Query Params:**
- `niche`: Filter by niche
- `platform`: Filter by platform
- `min_followers`: Minimum followers count
- `max_followers`: Maximum followers count
- `tier`: nano, micro, mid, macro, mega
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 20, max: 50)

**Response:** Paginated creators (handles hidden until collab)  
**Notes:** Uses creator_discovery_view for privacy protection

---

### GET `/api/brand/requests`
**Description:** Get all sent collab requests  
**Response:** Array of requests with creator details

---

### POST `/api/brand/requests`
**Description:** Send direct collab request to creator  
**Body:**
```json
{
  "creator_id": "uuid",
  "collab_type": "paid" | "barter" | "hybrid",
  "message": "We'd like to collaborate...",
  "budget": 100000,  // in paise (₹1000)
  "deliverables": ["1 Instagram post", "1 story"]
}
```
**Response:** Created request  
**Notes:**
- Deducts 1 credit from brand balance
- Returns error if insufficient credits
- Creates notification for creator

---

### GET `/api/brand/campaigns`
**Description:** Get all brand's campaigns  
**Query Params:**
- `status`: draft, active, closed (optional)

**Response:** Array of campaigns with bid counts

---

### POST `/api/brand/campaigns`
**Description:** Create new campaign  
**Body:**
```json
{
  "title": "Summer Collection Campaign",
  "description": "Promote our new collection...",
  "niche": "fashion",
  "collab_type": "paid" | "barter" | "hybrid",
  "budget": 150000,  // in paise (₹1500)
  "deliverables": ["2 Instagram posts", "3 stories"],
  "requirements": "Must have 50k+ followers",
  "deadline": "2024-06-30T00:00:00Z",
  "status": "draft" | "active"
}
```
**Response:** Created campaign

---

### PUT `/api/brand/campaigns/[id]`
**Description:** Update campaign details  
**Body:** Same as create, all fields optional  
**Response:** Updated campaign  
**Notes:** Can only update own campaigns (enforced by RLS)

---

### GET `/api/brand/campaigns/[id]/bids`
**Description:** Get all bids on a campaign  
**Response:** Array of bids with creator details

---

### PUT `/api/brand/campaigns/[id]/bids/[bidId]`
**Description:** Accept or reject a bid  
**Body:**
```json
{
  "action": "accept" | "reject"
}
```
**Response:** Updated bid or created collab  
**Notes:**
- On accept: Creates collab from bid, notifies creator
- On reject: Updates status, notifies creator
- Only pending bids can be processed

---

### GET `/api/brand/credits`
**Description:** Get credits balance and transaction history  
**Response:**
```json
{
  "balance": 25,
  "transactions": [...]
}
```

---

### POST `/api/brand/credits`
**Description:** Purchase credit pack  
**Body:**
```json
{
  "pack": "starter" | "growth" | "pro" | "enterprise"
}
```
**Response:** Razorpay order details  
**Notes:**
- Starter: 10 credits for ₹999
- Growth: 25 credits for ₹2,299
- Pro: 50 credits for ₹3,999
- Enterprise: 100 credits for ₹6,999

---

### POST `/api/brand/credits/verify`
**Description:** Verify payment and credit account  
**Body:**
```json
{
  "razorpay_order_id": "order_...",
  "razorpay_payment_id": "pay_...",
  "razorpay_signature": "signature..."
}
```
**Response:** Updated credits balance  
**Notes:** Verifies Razorpay signature before crediting

---

### GET `/api/brand/events`
**Description:** Get all brand's events  
**Response:** Array of events with invite and acceptance counts

---

### POST `/api/brand/events`
**Description:** Create new event  
**Body:**
```json
{
  "title": "Product Launch Party",
  "description": "Launch of our new product line...",
  "event_date": "2024-07-15T18:00:00Z",
  "location": "Mumbai, India",
  "image_url": "https://..."
}
```
**Response:** Created event

---

### POST `/api/brand/events/[id]/invites`
**Description:** Send invites to creators  
**Body:**
```json
{
  "creator_ids": ["uuid1", "uuid2", ...]
}
```
**Response:** Created invites count  
**Notes:**
- Max 100 creators per request
- Skips already invited creators
- Creates notification for each creator

---

### GET `/api/brand/events/[id]/invites`
**Description:** Get all invites for an event  
**Response:** Array of invites with creator details and status

---

## Agency Endpoints

### GET `/api/agency/profile`
**Description:** Get full agency profile  
**Response:** Profile with agency_profiles joined data  
**Notes:**
- Creates agency_profiles entry if missing (for backward compatibility)
- Returns agency stats: total_partnered_creators, total_pitches, total_bids

---

### PUT `/api/agency/profile`
**Description:** Update agency profile (onboarding)  
**Body:**
```json
{
  "display_name": "Creator Hub Agency",
  "bio": "Multi-creator management and brand partnerships",
  "specializations": ["fashion", "lifestyle", "travel"],
  "onboarded": true
}
```
**Response:** Updated profile

---

### GET `/api/agency/creators`
**Description:** Discover creators available to partner with (uses creator_discovery_view)  
**Query Params:**
- `niche`: Filter by niche
- `platform`: Filter by platform
- `min_followers`: Minimum followers count
- `max_followers`: Maximum followers count
- `tier`: nano, micro, mid, macro, mega
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 20, max: 50)

**Response:** Paginated creators (handles privacy & has_agency flag)  
**Notes:** Uses creator_discovery_view filtered for creators without agencies

---

### POST `/api/agency/invites`
**Description:** Send invite to creator to join agency roster  
**Body:**
```json
{
  "creator_id": "uuid",
  "message": "We'd love to represent you..."
}
```
**Response:** Created invite with status 'pending'  
**Notes:**
- Creates notification for creator
- Stores in agency_creators with status='pending'

---

### GET `/api/agency/invites`
**Description:** Get all pending invites sent to creators  
**Response:** Array of invites with creator details and status (pending, accepted, rejected)

---

### PUT `/api/agency/invites/[id]`
**Description:** Respond to agency invite (creator endpoint)  
**Body:**
```json
{
  "action": "accept" | "reject"
}
```
**Response:** Updated invite  
**Notes:**
- On accept: Sets status='accepted', accepted_at timestamp, increments agency total_partnered_creators
- On reject: Sets status='rejected'
- Only creator who received invite can respond
- Creates notification for agency

---

### GET `/api/agency/roster`
**Description:** Get all accepted partner creators  
**Response:** Array of creators with full details (status='accepted' only)  
**Notes:** Paginated, creators managed by agency

---

### DELETE `/api/agency/roster`
**Description:** Remove creator from roster  
**Body:**
```json
{
  "creator_id": "uuid"
}
```
**Response:** Success message  
**Notes:**
- Sets status='removed'
- Decrements total_partnered_creators
- Creates notification for creator

---

### POST `/api/agency/pitches`
**Description:** Create pitch to brand on behalf of roster creator  
**Body:**
```json
{
  "creator_id": "uuid",  // From agency roster
  "brand_id": "uuid",
  "campaign_id": "uuid",  // Optional: specific campaign
  "message": "Our creator is perfect for this campaign...",
  "proposed_rate": 50000  // Optional: proposed collaboration rate in paise
}
```
**Response:** Created pitch  
**Notes:**
- Creator must be in agency roster (status='accepted')
- Creates notification for brand
- Stored in agency_pitches table

---

### GET `/api/agency/pitches`
**Description:** Get all pitches sent by agency  
**Query Params:**
- `status`: pending, accepted, rejected (optional)

**Response:** Array of pitches with creator and brand details

---

### POST `/api/agency/bids`
**Description:** Place bid on campaign on behalf of roster creator  
**Body:**
```json
{
  "creator_id": "uuid",  // From agency roster
  "campaign_id": "uuid",
  "message": "Our creator is excited to collaborate..."
}
```
**Response:** Created bid  
**Notes:**
- Stored in bids table with bidder_type='agency' and agency_id
- Creator must be in agency roster
- Creates notification for brand

---

### GET `/api/agency/bids`
**Description:** Get all bids placed by agency  
**Query Params:**
- `status`: pending, accepted, rejected (optional)

**Response:** Array of bids with creator and campaign details

---

### GET `/api/agency/credits`
**Description:** Get agency credit balance and transaction history  
**Response:**
```json
{
  "balance": 15,
  "transactions": [...]
}
```
**Notes:** Credits track agency's spending on direct outreach to brands

---

### POST `/api/agency/credits`
**Description:** Purchase credit pack  
**Body:**
```json
{
  "pack": "starter" | "growth" | "pro" | "enterprise"
}
```
**Response:** Razorpay order details  
**Notes:**
- Starter: 20 credits for ₹1,499
- Growth: 50 credits for ₹2,999
- Pro: 100 credits for ₹4,999
- Enterprise: 250 credits for ₹9,999

---

### POST `/api/agency/credits/verify`
**Description:** Verify payment and credit account  
**Body:**
```json
{
  "razorpay_order_id": "order_...",
  "razorpay_payment_id": "pay_...",
  "razorpay_signature": "signature..."
}
```
**Response:** Updated credits balance  
**Notes:** Verifies Razorpay signature before crediting

---

## Shared Endpoints

### GET `/api/collabs/[id]`
**Description:** Get collaboration details  
**Response:** Collab with full brand and creator details  
**Notes:** Only accessible to collab participants (enforced by RLS)

---

### GET `/api/collabs/[id]/messages`
**Description:** Get all messages in a collab  
**Response:** Array of messages ordered by time

---

### POST `/api/collabs/[id]/messages`
**Description:** Send message in collab  
**Body:**
```json
{
  "content": "Message text..."
}
```
**Response:** Created message  
**Notes:**
- Max 2000 characters
- Creates notification for other participant
- Only collab participants can message

---

### POST `/api/ratings`
**Description:** Rate completed collaboration  
**Body:**
```json
{
  "collab_id": "uuid",
  "rating": 5,  // 1-5
  "review": "Great experience working together!"
}
```
**Response:** Created rating  
**Notes:**
- Only works on completed collabs
- Can only rate once per collab
- Auto-updates avg_rating via trigger
- Creates notification for rated user

---

### GET `/api/notifications`
**Description:** Get all notifications  
**Query Params:**
- `unread_only`: true/false (optional)

**Response:** Array of notifications (limit 50, latest first)

---

### PUT `/api/notifications/[id]`
**Description:** Mark single notification as read  
**Response:** Success message

---

### PUT `/api/notifications/read-all`
**Description:** Mark all notifications as read  
**Response:** Success message

---

## Notification Types

The following notification types are automatically created by the backend:

1. **bid_placed** - When creator bids on campaign
2. **bid_accepted** - When brand accepts bid
3. **bid_rejected** - When brand rejects bid
4. **collab_request** - When brand sends direct request
5. **request_accepted** - When creator accepts request
6. **request_rejected** - When creator rejects request
7. **milestone_updated** - When creator updates milestone
8. **event_invite** - When brand sends event invite
9. **invite_accepted** - When creator accepts invite
10. **invite_declined** - When creator declines invite
11. **new_message** - When message sent in collab
12. **new_rating** - When user receives rating

---

## Error Responses

All endpoints return errors in this format:
```json
{
  "error": "Error message here"
}
```

Common HTTP status codes:
- **400** - Bad Request (validation error, insufficient funds, etc.)
- **401** - Unauthorized (not authenticated)
- **403** - Forbidden (wrong role for endpoint)
- **404** - Not Found (resource doesn't exist or no access)
- **500** - Internal Server Error

---

## Authentication

All endpoints except `/api/auth/signup` and `/api/auth/login` require authentication via Supabase session cookies.

Role-based access:
- `/api/creator/*` - Only accessible to users with role='creator'
- `/api/brand/*` - Only accessible to users with role='brand'
- `/api/collabs/*`, `/api/ratings`, `/api/notifications` - Accessible to both roles

Enforced by `middleware.ts` at the route level and RLS policies at the database level.

---

## Monetary Values

All monetary values in the API are in **paise** (₹1 = 100 paise):
- Campaign budgets
- Wallet amounts
- Credit pack prices
- Collab fees

Example: To send ₹500, use `50000` in API requests.

---

## Collab Fee Structure

Fees automatically calculated based on brand size (charged to creator):

| Brand Size | Fee Range | Used in API |
|------------|-----------|-------------|
| Micro      | ₹10-₹30   | ₹20 (2000 paise) |
| Mid        | ₹50-₹100  | ₹75 (7500 paise) |
| Big        | ₹150-₹300 | ₹225 (22500 paise) |

Fees deducted when:
- Creator accepts collab request
- Creator wins campaign bid (charged when bid placed, not on acceptance)

---

## Pagination

Endpoints that support pagination return this format:
```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 156,
    "total_pages": 8
  }
}
```

Paginated endpoints:
- `GET /api/creator/campaigns`
- `GET /api/brand/creators`

---

## Real-time Features

To enable real-time updates, use Supabase Realtime subscriptions in your frontend:

```javascript
// Subscribe to new messages
supabase
  .channel('collab-messages')
  .on('postgres_changes', 
    { event: 'INSERT', schema: 'public', table: 'messages', filter: `collab_id=eq.${collabId}` },
    (payload) => {
      // Handle new message
    }
  )
  .subscribe()

// Subscribe to notifications
supabase
  .channel('user-notifications')
  .on('postgres_changes',
    { event: 'INSERT', schema: 'public', table: 'notifications', filter: `user_id=eq.${userId}` },
    (payload) => {
      // Handle new notification
    }
  )
  .subscribe()
```

---

## Testing with cURL

### Sign up as creator:
```bash
curl -X POST http://localhost:3000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "creator.sample@beyondc.in",
    "password": "Creator@1234",
    "role": "creator",
    "display_name": "Aarav Creator"
  }'
```

### Sign up as brand:
```bash
curl -X POST http://localhost:3000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "brand.sample@beyondc.in",
    "password": "Brand@1234",
    "role": "brand",
    "display_name": "Riya Brand"
  }'
```

### Sign up as agency:
```bash
curl -X POST http://localhost:3000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "agency.sample@beyondc.in",
    "password": "Agency@1234",
    "role": "agency",
    "display_name": "Priya Agency"
  }'
```

### Login:
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "creator.sample@beyondc.in",
    "password": "Creator@1234"
  }' \
  -c cookies.txt
```

### Get profile (with auth):
```bash
curl -X GET http://localhost:3000/api/creator/profile \
  -b cookies.txt
```

### Agency get profile:
```bash
curl -X GET http://localhost:3000/api/agency/profile \
  -b cookies.txt
```

---

## Next Steps for Integration

1. **Install dependencies:**
   ```bash
   npm install @supabase/ssr zod razorpay
   ```

2. **Set up environment variables** (see `.env.local.example`)

3. **Run database migrations** in Supabase SQL Editor

4. **Test authentication flow** with Postman or cURL

5. **Integrate with frontend** using the API endpoints

6. **Set up Razorpay webhooks** for payment failure handling

7. **Enable Supabase Realtime** for live notifications and messages
