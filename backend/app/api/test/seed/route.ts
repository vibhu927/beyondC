import { NextResponse } from 'next/server'
import { createAdminClient } from '@/lib/supabase/server'

const CREATOR = {
  email: 'creator.test@beyondc.in',
  password: 'TestCreator@123',
  first_name: 'Aarav',
  full_name: 'Aarav Mehta',
  phone: '9876543210',
}

const BRAND = {
  email: 'brand.test@beyondc.in',
  password: 'TestBrand@123',
  first_name: 'Neha',
  full_name: 'Neha Kapoor',
  phone: '9876543211',
  brand_name: 'GlowKart',
}

async function ensureUser(params: {
  email: string
  password: string
  role: 'creator' | 'brand'
  first_name: string
  full_name: string
  phone: string
  brand_name?: string
}) {
  const supabase = createAdminClient()
  const { data: created, error } = await supabase.auth.admin.createUser({
    email: params.email,
    password: params.password,
    email_confirm: true,
    user_metadata: {
      role: params.role,
      first_name: params.first_name,
      full_name: params.full_name,
      phone: params.phone,
      brand_name: params.brand_name,
    },
  })
  if (error && !error.message.toLowerCase().includes('already')) throw error
  if (created?.user?.id) return created.user.id
  const { data: profile } = await supabase.from('profiles').select('id').eq('email', params.email).single()
  if (!profile?.id) throw new Error(`Unable to resolve user id for ${params.email}`)
  return profile.id
}

async function ins(supabase: ReturnType<typeof createAdminClient>, table: string, row: Record<string, unknown>) {
  const { data, error } = await supabase.from(table).insert(row).select('id')
  if (error) throw new Error(`${table}: ${error.message}`)
  return data?.[0]?.id as string
}

export async function POST() {
  try {
    const sb = createAdminClient()
    const now = Date.now()

    // ── 1. Users ──────────────────────────────────────────────────────
    const creatorId = await ensureUser({ ...CREATOR, role: 'creator' })
    const brandId = await ensureUser({ ...BRAND, role: 'brand' })

    // ── 2. Profiles ───────────────────────────────────────────────────
    await sb.from('profiles').upsert([
      { id: creatorId, role: 'creator', first_name: CREATOR.first_name, full_name: CREATOR.full_name, email: CREATOR.email, phone: CREATOR.phone, state: 'Maharashtra', city: 'Mumbai', is_verified: true, is_onboarded: true },
      { id: brandId, role: 'brand', first_name: BRAND.first_name, full_name: BRAND.full_name, email: BRAND.email, phone: BRAND.phone, state: 'Maharashtra', city: 'Mumbai', is_verified: true, is_onboarded: true },
    ], { onConflict: 'id' })

    await sb.from('creator_profiles').upsert({
      id: creatorId, niche: ['Fashion', 'Lifestyle', 'Beauty'], content_type: ['Reels', 'Stories', 'Static Posts'],
      platforms: ['Instagram', 'YouTube'], follower_count: 45000, followers_count: 45000, engagement_rate: 4.8,
      is_discoverable: true, bio: 'Fashion & lifestyle creator from Mumbai. Love bold, aesthetic campaigns!',
      starting_price: 8000, wallet_balance: 250000, portfolio_links: [], youtube_handle: '@aaravcreates',
    }, { onConflict: 'id' })

    await sb.from('brand_profiles').upsert({
      id: brandId,       brand_name: BRAND.brand_name, brand_category: 'Beauty', website: 'https://glowkart.example.com',
      description: 'Premium beauty and skincare brand targeting Gen-Z audience.', credit_balance: 50,
      size: 'mid', is_brand_verified: true, portfolio_links: [],
    }, { onConflict: 'id' })

    // ── 3. Clean all existing data ────────────────────────────────────
    // FK order: ratings → content_submissions → payment_milestones → messages → collabs → bids → campaigns → events → event_invites
    const tables = ['ratings', 'content_submissions', 'payment_milestones', 'messages', 'collabs', 'bids', 'campaigns', 'event_invites', 'events']
    for (const t of tables) {
      const { data: rows } = await sb.from(t).select('id')
      if (rows && rows.length > 0) {
        const { error } = await sb.from(t).delete().in('id', rows.map((r) => r.id))
        if (error) console.warn(`Delete ${t}:`, error.message)
      }
    }
    await sb.from('notifications').delete().eq('user_id', creatorId)
    await sb.from('notifications').delete().eq('user_id', brandId)
    await sb.from('wallet_transactions').delete().eq('creator_id', creatorId)
    await sb.from('credit_transactions').delete().eq('brand_id', brandId)
    await sb.from('saved_creators').delete().eq('brand_id', brandId)

    // ── 4. Campaigns ──────────────────────────────────────────────────
    // 7 active campaigns + 1 completed + 1 paused for realistic data
    const camp1 = await ins(sb, 'campaigns', {
      brand_id: brandId, title: 'Summer Glow Serum Launch', description: 'Promote our new vitamin C serum with aesthetic lifestyle reels.',
      niche: ['Beauty', 'Lifestyle'], collab_type: 'paid', budget_min: 7000, budget_max: 12000,
      product_details: 'Hydrating Vitamin C Serum — ₹1499 MRP. Key ingredients: Niacinamide, Vitamin C, Hyaluronic Acid.',
      product_value: 1499, deliverables: ['1 Reel', '2 Story Frames'], target_tier: ['micro', 'mid'],
      target_state: 'Maharashtra', target_city: 'Mumbai', min_followers: 10000,
      deadline: new Date(now + 14 * 86400000).toISOString(), slots: 3, slots_filled: 1, status: 'active',
    })

    const camp2 = await ins(sb, 'campaigns', {
      brand_id: brandId, title: 'Night Routine Challenge', description: 'Show your PM skincare routine using our Night Repair Kit.',
      niche: ['Beauty'], collab_type: 'hybrid', budget_min: 5000, budget_max: 9000,
      product_details: 'Night Repair Kit — ₹2299 MRP. Includes cleanser, serum, and moisturizer.',
      product_value: 2299, deliverables: ['1 Reel', '1 Static Post'], target_tier: ['micro'],
      target_state: 'Maharashtra', target_city: 'Mumbai', min_followers: 8000,
      deadline: new Date(now + 10 * 86400000).toISOString(), slots: 2, slots_filled: 0, status: 'active',
    })

    const camp3 = await ins(sb, 'campaigns', {
      brand_id: brandId, title: 'Festive Collection Teaser', description: 'Upcoming festive collection — looking for fashion creators for festive season reels.',
      niche: ['Fashion'], collab_type: 'paid', budget_min: 10000, budget_max: 20000,
      deliverables: ['2 Reels', '1 Carousel'], target_tier: ['mid', 'macro'], min_followers: 50000,
      deadline: new Date(now + 30 * 86400000).toISOString(), slots: 5, slots_filled: 0, status: 'active',
    })

    const camp4 = await ins(sb, 'campaigns', {
      brand_id: brandId, title: 'Monsoon Hair Care Reels', description: 'Create content around our anti-frizz hair serum for the monsoon season.',
      niche: ['Beauty', 'Lifestyle'], collab_type: 'barter', budget_min: 0, budget_max: 0,
      product_details: 'Anti-Frizz Hair Serum — ₹899 MRP. Keratin + Argan Oil formula.',
      product_value: 899, deliverables: ['1 Reel', '1 Story Series'], target_tier: ['nano', 'micro'],
      target_state: 'Maharashtra', target_city: 'Pune', min_followers: 5000,
      deadline: new Date(now + 21 * 86400000).toISOString(), slots: 10, slots_filled: 3, status: 'active',
    })

    const camp5 = await ins(sb, 'campaigns', {
      brand_id: brandId, title: 'Work From Home Outfit Showcase', description: 'Style our athleisure line for WFH creators — comfort meets fashion.',
      niche: ['Fashion', 'Lifestyle'], collab_type: 'paid', budget_min: 6000, budget_max: 10000,
      product_details: 'WFH Athleisure Set — ₹2499 MRP. Premium cotton blend.',
      product_value: 2499, deliverables: ['1 Reel', '2 Static Posts'], target_tier: ['micro', 'mid'],
      target_state: 'Karnataka', target_city: 'Bangalore', min_followers: 15000,
      deadline: new Date(now + 18 * 86400000).toISOString(), slots: 4, slots_filled: 1, status: 'active',
    })

    const camp6 = await ins(sb, 'campaigns', {
      brand_id: brandId, title: 'Unboxing Experience Challenge', description: 'Film an aesthetic unboxing of our curated beauty box.',
      niche: ['Beauty'], collab_type: 'hybrid', budget_min: 3000, budget_max: 6000,
      product_details: 'GlowKart Beauty Box — ₹1999 MRP. 6 curated skincare minis.',
      product_value: 1999, deliverables: ['1 Reel'], target_tier: ['nano', 'micro'],
      target_state: 'Delhi', target_city: 'New Delhi', min_followers: 3000,
      deadline: new Date(now + 12 * 86400000).toISOString(), slots: 8, slots_filled: 2, status: 'active',
    })

    const camp7 = await ins(sb, 'campaigns', {
      brand_id: brandId, title: 'Summer Fragrance Launch', description: 'Promote our new citrus-based summer perfume for reels and stories.',
      niche: ['Lifestyle', 'Fashion'], collab_type: 'paid', budget_min: 15000, budget_max: 25000,
      product_details: 'Citrus Bloom EDT — ₹3499 MRP. Top notes: Bergamot, Orange. Base: Musk, Cedarwood.',
      product_value: 3499, deliverables: ['2 Reels', '3 Story Frames'], target_tier: ['macro'],
      target_state: null, target_city: null, min_followers: 100000,
      deadline: new Date(now + 25 * 86400000).toISOString(), slots: 2, slots_filled: 0, status: 'active',
    })

    // ── 5. Bids ───────────────────────────────────────────────────────
    const bid1 = await ins(sb, 'bids', {
      campaign_id: camp1, creator_id: creatorId, bid_amount: 9000,
      deliverables: '1 Reel + 2 Story Frames', message: 'I can deliver high-retention reels within 3 days. My audience loves skincare content!', status: 'accepted',
    })
    const bid2 = await ins(sb, 'bids', {
      campaign_id: camp2, creator_id: creatorId, bid_amount: 7500,
      deliverables: '1 Reel + 1 Static Post', message: 'Hybrid collab sounds great — product + paid works for me.', status: 'accepted',
    })
    const bid3 = await ins(sb, 'bids', {
      campaign_id: camp3, creator_id: creatorId, bid_amount: 15000,
      deliverables: '2 Reels + 1 Carousel', message: 'Perfect for festive content — my audience engages heavily with fashion.', status: 'pending',
    })

    // ── 6. Collab Requests (brand → creator) ──────────────────────────
    const cr1 = await ins(sb, 'collab_requests', {
      brand_id: brandId, creator_id: creatorId, message: 'We love your content! Would you like to collaborate on our serum launch?',
      budget: 9000, collab_type: 'paid', deliverables: ['1 Reel', '2 Story Frames'], status: 'accepted',
      expires_at: new Date(now + 7 * 86400000).toISOString(),
    })

    // ── 7. Collabs ────────────────────────────────────────────────────
    const collab1 = await ins(sb, 'collabs', {
      brand_id: brandId, creator_id: creatorId, source: 'bid', source_id: bid1, campaign_id: camp1,
      agreed_amount: 9000, collab_type: 'paid', deliverables: ['1 Reel', '2 Story Frames'],
      status: 'in_progress', brief_shared: true, collab_status: 'working_on_draft',
      status_updated_at: new Date(now - 86400000).toISOString(),
      status_update_message: 'Creator is working on the draft.',
      contract_terms: { scope: '1 Reel + 2 Story Frames for Summer Glow Serum', usage_rights: 'Brand can repost for 90 days', timeline: 'Content due within 7 days of brief acceptance', exclusivity: 'No competing skincare posts for 14 days' },
      creator_contract_accepted: true, brand_contract_accepted: true,
      creator_contract_accepted_at: new Date(now - 3 * 86400000).toISOString(),
      brand_contract_accepted_at: new Date(now - 2 * 86400000).toISOString(),
      payment_structure: 'milestone_based', started_at: new Date(now - 4 * 86400000).toISOString(),
      last_message: 'Working on the reel draft now!', last_message_at: new Date(now - 3600000).toISOString(),
      last_message_by: creatorId, unread_count_creator: 0, unread_count_brand: 1,
    })

    const collab2 = await ins(sb, 'collabs', {
      brand_id: brandId, creator_id: creatorId, source: 'bid', source_id: bid2, campaign_id: camp2,
      agreed_amount: 7500, collab_type: 'hybrid', deliverables: ['1 Reel', '1 Static Post'],
      status: 'completed', brief_shared: true, draft_submitted: true, draft_approved: true,
      content_posted: true, collab_status: 'completed',
      completed_at: new Date(now - 5 * 86400000).toISOString(),
      payment_structure: 'full_upfront', started_at: new Date(now - 10 * 86400000).toISOString(),
    })

    // ── 8. Payment Milestones (collab1) ───────────────────────────────
    await ins(sb, 'payment_milestones', { collab_id: collab1, name: 'Brief Acceptance', percentage: 30, amount_paise: 270000, status: 'released', released_at: new Date(now - 2 * 86400000).toISOString(), order_index: 0 })
    await ins(sb, 'payment_milestones', { collab_id: collab1, name: 'Draft Submission', percentage: 40, amount_paise: 360000, status: 'pending', order_index: 1 })
    await ins(sb, 'payment_milestones', { collab_id: collab1, name: 'Content Posted', percentage: 30, amount_paise: 270000, status: 'pending', order_index: 2 })

    // ── 9. Content Submissions (collab1) ──────────────────────────────
    await ins(sb, 'content_submissions', {
      collab_id: collab1, submitted_by: creatorId, content_url: 'https://www.instagram.com/reel/test123',
      content_type: 'video', caption: 'Summer glow routine with @glowkart ✨', notes: 'Shot in natural light, trending audio used. 3x saves in first hour.',
      status: 'approved', brand_feedback: 'Love the lighting and pacing! Approved — ready to post.',
      submitted_at: new Date(now - 86400000).toISOString(), reviewed_at: new Date(now - 43200000).toISOString(),
    })
    await ins(sb, 'content_submissions', {
      collab_id: collab1, submitted_by: creatorId, content_url: 'https://www.instagram.com/p/test456',
      content_type: 'image', caption: 'Story frame 1 — product close-up', status: 'pending',
      submitted_at: new Date().toISOString(),
    })

    // ── 10. Messages (collab1) ────────────────────────────────────────
    await ins(sb, 'messages', { collab_id: collab1, sender_id: brandId, sender_role: 'brand', content: 'Hi! Welcome to the campaign. The brief is shared in the contract.', is_read: true })
    await ins(sb, 'messages', { collab_id: collab1, sender_id: creatorId, sender_role: 'creator', content: 'Thanks! I have accepted the contract. Will start working on the reel.', is_read: true })
    await ins(sb, 'messages', { collab_id: collab1, sender_id: creatorId, sender_role: 'creator', content: 'Working on the reel draft now! Should be ready by tomorrow.', is_read: false })

    // ── 11. Events ────────────────────────────────────────────────────
    const event1 = await ins(sb, 'events', {
      brand_id: brandId, title: 'GlowKart Creator Brunch', description: 'Offline brunch and product trial for creators. Network with other creators and try our new range.',
      event_type: 'brand_party', event_date: new Date(now + 7 * 86400000).toISOString(),
      venue_name: 'The Courtyard', venue_address: 'Bandra West, Mumbai', city: 'Mumbai', state: 'Maharashtra',
      is_virtual: false, total_slots: 20, slots_filled: 2,
      what_creators_get: 'PR package + paid collab shortlist + lunch', target_niche: ['Beauty'], target_tier: ['micro', 'mid'],
      status: 'upcoming',
    })

    // ── 12. Event Invites ─────────────────────────────────────────────
    await ins(sb, 'event_invites', {
      event_id: event1, brand_id: brandId, creator_id: creatorId, status: 'accepted',
      ticket_code: 'GLW-EVT-' + Math.random().toString(36).slice(2, 8).toUpperCase(),
      ticket_generated_at: new Date().toISOString(), accepted_at: new Date().toISOString(),
    })

    // ── 13. Ratings (collab2) ─────────────────────────────────────────
    await ins(sb, 'ratings', { collab_id: collab2, rated_by: brandId, rated_user: creatorId, rated_role: 'creator', score: 5, review: 'Amazing work! Delivered on time with great quality.' })
    await ins(sb, 'ratings', { collab_id: collab2, rated_by: creatorId, rated_user: brandId, rated_role: 'brand', score: 5, review: 'Great brand to work with. Clear brief and timely payments.' })

    // ── 14. Notifications ─────────────────────────────────────────────
    await ins(sb, 'notifications', { user_id: creatorId, type: 'contract_created', title: 'Contract Ready', body: 'GlowKart sent you a contract for Summer Glow Serum Launch.', reference_id: collab1, reference_type: 'collab' })
    await ins(sb, 'notifications', { user_id: creatorId, type: 'collab_status_updated', title: 'Status Updated', body: 'Your collab status changed to Working on Draft.', reference_id: collab1, reference_type: 'collab' })
    await ins(sb, 'notifications', { user_id: creatorId, type: 'payment_released', title: 'Payment Released', body: '₹2,700 released for Brief Acceptance milestone.', reference_id: collab1, reference_type: 'collab' })
    await ins(sb, 'notifications', { user_id: creatorId, type: 'content_reviewed', title: 'Content Approved', body: 'Your reel submission was approved by GlowKart.', reference_id: collab1, reference_type: 'collab' })
    await ins(sb, 'notifications', { user_id: creatorId, type: 'bid_accepted', title: 'Bid Accepted!', body: 'Your bid for Night Routine Challenge was accepted.', reference_id: bid2, reference_type: 'bid' })

    // ── 15. Saved Creators ────────────────────────────────────────────
    await ins(sb, 'saved_creators', { brand_id: brandId, creator_id: creatorId })

    // ── 16. Wallet Transactions ───────────────────────────────────────
    await ins(sb, 'wallet_transactions', { creator_id: creatorId, type: 'topup', amount: 5000, reason: 'wallet_topup', razorpay_order_id: 'order_test_001', razorpay_payment_id: 'pay_test_001', balance_after: 250000 })
    await ins(sb, 'wallet_transactions', { creator_id: creatorId, type: 'deduct', amount: 500, reason: 'collab_fee_deducted', reference_id: collab1, balance_after: 249500 })

    // ── 17. Credit Transactions ───────────────────────────────────────
    await ins(sb, 'credit_transactions', { brand_id: brandId, type: 'topup', amount: 3000, reason: 'credit_pack_purchase', razorpay_order_id: 'order_brand_001', razorpay_payment_id: 'pay_brand_001', balance_after: 50 })
    await ins(sb, 'credit_transactions', { brand_id: brandId, type: 'deduct', amount: 10, reason: 'bid_accepted', reference_id: collab1, balance_after: 40 })

    return NextResponse.json({
      success: true,
      message: 'Test data seeded!',
      credentials: {
        creator: { email: CREATOR.email, password: CREATOR.password },
        brand: { email: BRAND.email, password: BRAND.password },
      },
      data: {
        profiles: 2, campaigns: 9, bids: 3, collab_requests: 1, collabs: 2,
        milestones: 3, content: 2, messages: 3, events: 1, event_invites: 1,
        ratings: 2, notifications: 5, saved_creators: 1, wallet: 2, credits: 2,
      },
    })
  } catch (error: any) {
    console.error('Seed error:', error)
    return NextResponse.json({ error: error.message || 'Seed failed' }, { status: 500 })
  }
}
