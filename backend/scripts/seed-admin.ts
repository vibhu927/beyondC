import { createClient } from '@supabase/supabase-js'
import nextEnv from '@next/env'

const { loadEnvConfig } = nextEnv
loadEnvConfig(process.cwd())

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)

function throwIfError(error: { message: string } | null, context: string) {
  if (error) {
    throw new Error(`${context}: ${error.message}`)
  }
}

const SAMPLE = {
  creator: {
    email: 'creator.sample@beyondc.in',
    password: 'Creator@1234',
    firstName: 'Aarav',
    fullName: 'Aarav Creator',
    phone: '9876501234',
  },
  brand: {
    email: 'brand.sample@beyondc.in',
    password: 'Brand@1234',
    firstName: 'Riya',
    fullName: 'Riya Brand',
    phone: '9876505678',
    brandName: 'GlowKart',
  },
}

const IDS = {
  campaign1: '11111111-1111-1111-1111-111111111111',
  campaign2: '22222222-2222-2222-2222-222222222222',
  bid1: '33333333-3333-3333-3333-333333333333',
  bid2: '44444444-4444-4444-4444-444444444444',
  collab1: '55555555-5555-5555-5555-555555555555',
  collab2: '66666666-6666-6666-6666-666666666666',
  event1: '77777777-7777-7777-7777-777777777777',
  event2: '88888888-8888-8888-8888-888888888888',
  invite1: '99999999-9999-9999-9999-999999999991',
  invite2: '99999999-9999-9999-9999-999999999992',
  creditTx1: 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaa1',
  creditTx2: 'aaaaaaa2-aaaa-aaaa-aaaa-aaaaaaaaaaa2',
  walletTx1: 'bbbbbbb1-bbbb-bbbb-bbbb-bbbbbbbbbbb1',
  walletTx2: 'bbbbbbb2-bbbb-bbbb-bbbb-bbbbbbbbbbb2',
  message1: 'ccccccc1-cccc-cccc-cccc-ccccccccccc1',
  message2: 'ccccccc2-cccc-cccc-cccc-ccccccccccc2',
  rating1: 'ddddddd1-dddd-dddd-dddd-ddddddddddd1',
  rating2: 'ddddddd2-dddd-dddd-dddd-ddddddddddd2',
  notification1: 'eeeeeee1-eeee-eeee-eeee-eeeeeeeeeee1',
  notification2: 'eeeeeee2-eeee-eeee-eeee-eeeeeeeeeee2',
}

async function ensureAuthUser(params: {
  email: string
  password: string
  role: 'creator' | 'brand' | 'admin'
  first_name: string
  full_name: string
  phone?: string
  brand_name?: string
}) {
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

  if (error && !error.message.toLowerCase().includes('already')) {
    throw error
  }

  if (created?.user?.id) {
    return created.user.id
  }

  const { data: profile } = await supabase.from('profiles').select('id').eq('email', params.email).single()

  if (!profile?.id) {
    throw new Error(`Unable to resolve user id for ${params.email}`)
  }

  return profile.id
}

async function seedSuperAdmin() {
  const email = 'superadmin@beyondc.in'
  const password = 'BeyondC@SuperAdmin2025!'
  const name = 'Super Admin'

  console.log('Creating super admin user...')

  const { data: authData, error: authError } = await supabase.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
    user_metadata: {
      role: 'admin',
      full_name: name,
      first_name: 'Super',
    },
  })

  if (authError && !authError.message.toLowerCase().includes('already')) {
    throw authError
  }

  let userId = authData?.user?.id

  if (!userId) {
    const { data: existingProfile } = await supabase
      .from('profiles')
      .select('id')
      .eq('email', email)
      .single()

    if (!existingProfile?.id) {
      throw new Error('Unable to resolve super admin user id')
    }

    userId = existingProfile.id
  }

  await supabase.from('profiles').upsert({
    id: userId,
    email,
    full_name: name,
    first_name: 'Super',
    role: 'brand',
    is_admin: true,
    is_super_admin: true,
    is_onboarded: true,
  })

  const roles = [
    {
      name: 'moderator',
      designation: 'Content Moderator',
      description: 'Manages campaigns, collabs and disputes',
    },
    {
      name: 'support',
      designation: 'Support Agent',
      description: 'Handles user issues and reports',
    },
    {
      name: 'finance',
      designation: 'Finance Manager',
      description: 'Manages payments, refunds and revenue',
    },
    {
      name: 'marketing',
      designation: 'Marketing Manager',
      description: 'Manages notifications and featured content',
    },
  ]

  const { data: rolesData } = await supabase
    .from('admin_roles')
    .upsert(roles, { onConflict: 'name' })
    .select()

  const pages = [
    'dashboard',
    'users',
    'campaigns',
    'collabs',
    'events',
    'payments',
    'disputes',
    'notifications',
    'settings',
    'analytics',
    'staff',
  ]

  const permissions: Array<{
    role_id: string
    page: string
    can_view: boolean
    can_edit: boolean
    can_delete: boolean
  }> = []

  rolesData?.forEach((role) => {
    pages.forEach((page) => {
      let can_view = true
      let can_edit = false
      let can_delete = false

      if (role.name === 'moderator') {
        can_edit = ['campaigns', 'collabs', 'disputes'].includes(page)
        can_delete = ['campaigns'].includes(page)
      }

      if (role.name === 'support') {
        can_edit = ['users', 'disputes'].includes(page)
      }

      if (role.name === 'finance') {
        can_view = ['dashboard', 'payments', 'analytics'].includes(page)
        can_edit = page === 'payments'
      }

      if (role.name === 'marketing') {
        can_edit = ['notifications', 'settings'].includes(page)
      }

      permissions.push({
        role_id: role.id,
        page,
        can_view,
        can_edit,
        can_delete,
      })
    })
  })

  await supabase.from('admin_permissions').upsert(permissions, { onConflict: 'role_id,page' })

  const settings = [
    {
      key: 'credit_packs',
      label: 'Credit Pack Prices',
      value: {
        starter: { credits: 5, price: 199 },
        growth: { credits: 15, price: 499 },
        scale: { credits: 35, price: 999 },
      },
    },
    {
      key: 'collab_fees',
      label: 'Creator Collab Fees',
      value: {
        micro: { min: 1000, max: 3000 },
        mid: { min: 5000, max: 10000 },
        big: { min: 15000, max: 30000 },
      },
    },
    {
      key: 'wallet_topups',
      label: 'Wallet Top-up Options',
      value: { options: [99, 199, 499, 999, 1999] },
    },
    {
      key: 'maintenance_mode',
      label: 'Maintenance Mode',
      value: {
        enabled: false,
        message: 'BeyondC is under maintenance. Back soon!',
      },
    },
    {
      key: 'featured_creators',
      label: 'Featured Creator IDs',
      value: { ids: [] },
    },
  ]

  await supabase.from('platform_settings').upsert(settings, { onConflict: 'key' })

  console.log('Super admin is ready')
  console.log(`Email: ${email}`)
  console.log(`Password: ${password}`)
  console.log('Change password after first login')
}

async function seedSampleData() {
  console.log('Creating sample creator + brand users...')

  const creatorId = await ensureAuthUser({
    email: SAMPLE.creator.email,
    password: SAMPLE.creator.password,
    role: 'creator',
    first_name: SAMPLE.creator.firstName,
    full_name: SAMPLE.creator.fullName,
    phone: SAMPLE.creator.phone,
  })

  const brandId = await ensureAuthUser({
    email: SAMPLE.brand.email,
    password: SAMPLE.brand.password,
    role: 'brand',
    first_name: SAMPLE.brand.firstName,
    full_name: SAMPLE.brand.fullName,
    phone: SAMPLE.brand.phone,
    brand_name: SAMPLE.brand.brandName,
  })

  const { error: profilesError } = await supabase.from('profiles').upsert(
    [
      {
        id: creatorId,
        role: 'creator',
        first_name: SAMPLE.creator.firstName,
        full_name: SAMPLE.creator.fullName,
        email: SAMPLE.creator.email,
        phone: SAMPLE.creator.phone,
        is_onboarded: true,
        is_admin: false,
        is_super_admin: false,
      },
      {
        id: brandId,
        role: 'brand',
        first_name: SAMPLE.brand.firstName,
        full_name: SAMPLE.brand.fullName,
        email: SAMPLE.brand.email,
        phone: SAMPLE.brand.phone,
        is_onboarded: true,
        is_admin: false,
        is_super_admin: false,
      },
    ],
    { onConflict: 'id' }
  )
  throwIfError(profilesError, 'Failed to upsert sample profiles')

  const { error: creatorProfileError } = await supabase.from('creator_profiles').upsert(
    {
      id: creatorId,
      niche: ['Fashion', 'Lifestyle'],
      content_type: ['Reels', 'Stories'],
      platforms: ['Instagram'],
      follower_count: 42000,
      followers_count: 42000,
      engagement_rate: 4.6,
      instagram_username: null,
      instagram_verified: false,
      is_discoverable: false,
      following_count: null,
      posts_count: null,
      highest_video_views: null,
      avg_video_views: null,
      avg_likes: null,
      avg_comments: null,
      stats_fetched_at: null,
      bio: 'Lifestyle creator for beauty and fashion collabs.',
      starting_price: 8000,
      wallet_balance: 150000,
      portfolio_links: [],
    },
    { onConflict: 'id' }
  )
  throwIfError(creatorProfileError, 'Failed to upsert sample creator profile')

  const { error: brandProfileError } = await supabase.from('brand_profiles').upsert(
    {
      id: brandId,
      brand_name: SAMPLE.brand.brandName,
      brand_category: 'Beauty',
      website: 'https://glowkart.example.com',
      gst_number: '29ABCDE1234F1Z9',
      description: 'Beauty and skincare brand targeting Gen-Z audience.',
      credit_balance: 25,
      size: 'mid',
      is_brand_verified: true,
    },
    { onConflict: 'id' }
  )
  throwIfError(brandProfileError, 'Failed to upsert sample brand profile')

  console.log('Seeding 2 campaigns, 2 bids, 2 collabs, 2 events...')

  await supabase.from('campaigns').upsert(
    [
      {
        id: IDS.campaign1,
        brand_id: brandId,
        title: 'GlowKart Summer Serum Launch',
        description: 'Promote our new summer serum with quick lifestyle reels.',
        niche: ['Beauty', 'Lifestyle'],
        collab_type: 'paid',
        budget_min: 7000,
        budget_max: 12000,
        product_details: 'Hydrating Vitamin C Serum',
        product_value: 1499,
        deliverables: ['1 Reel', '2 Story Frames'],
        target_tier: ['micro', 'mid'],
        min_followers: 10000,
        slots: 2,
        slots_filled: 1,
        status: 'active',
      },
      {
        id: IDS.campaign2,
        brand_id: brandId,
        title: 'GlowKart Night Routine Challenge',
        description: 'Creator challenge showcasing PM skincare routine.',
        niche: ['Beauty'],
        collab_type: 'hybrid',
        budget_min: 5000,
        budget_max: 9000,
        product_details: 'Night Repair Kit',
        product_value: 2299,
        deliverables: ['1 Reel', '1 Static Post'],
        target_tier: ['micro'],
        min_followers: 8000,
        slots: 2,
        slots_filled: 1,
        status: 'active',
      },
    ],
    { onConflict: 'id' }
  )

  await supabase.from('bids').upsert(
    [
      {
        id: IDS.bid1,
        campaign_id: IDS.campaign1,
        creator_id: creatorId,
        bid_amount: 9000,
        deliverables: '1 Reel + 2 Stories',
        include_barter: false,
        message: 'Can deliver high-retention reels within 3 days.',
        status: 'accepted',
      },
      {
        id: IDS.bid2,
        campaign_id: IDS.campaign2,
        creator_id: creatorId,
        bid_amount: 7500,
        deliverables: '1 Reel + 1 Static',
        include_barter: true,
        message: 'Interested in hybrid collab with product showcase.',
        status: 'pending',
      },
    ],
    { onConflict: 'id' }
  )

  await supabase.from('collabs').upsert(
    [
      {
        id: IDS.collab1,
        brand_id: brandId,
        creator_id: creatorId,
        source: 'bid',
        source_id: IDS.bid1,
        campaign_id: IDS.campaign1,
        agreed_amount: 9000,
        collab_type: 'paid',
        deliverables: ['1 Reel', '2 Story Frames'],
        status: 'in_progress',
        brief_shared: true,
        draft_submitted: true,
      },
      {
        id: IDS.collab2,
        brand_id: brandId,
        creator_id: creatorId,
        source: 'direct_request',
        source_id: IDS.bid2,
        campaign_id: IDS.campaign2,
        agreed_amount: 7500,
        collab_type: 'hybrid',
        deliverables: ['1 Reel', '1 Static Post'],
        status: 'completed',
        brief_shared: true,
        draft_submitted: true,
        draft_approved: true,
        content_posted: true,
        completed_at: new Date().toISOString(),
      },
    ],
    { onConflict: 'id' }
  )

  await supabase.from('events').upsert(
    [
      {
        id: IDS.event1,
        brand_id: brandId,
        title: 'GlowKart Creator Brunch',
        description: 'Offline brunch and product trial for creators.',
        event_type: 'brand_party',
        event_date: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
        venue_name: 'The Courtyard',
        venue_address: 'Bandra West, Mumbai',
        city: 'Mumbai',
        is_virtual: false,
        total_slots: 20,
        slots_filled: 1,
        what_creators_get: 'PR package + paid collab shortlist',
        target_niche: ['Beauty'],
        target_tier: ['micro', 'mid'],
        status: 'upcoming',
      },
      {
        id: IDS.event2,
        brand_id: brandId,
        title: 'GlowKart Virtual Masterclass',
        description: 'Virtual content strategy and skincare workshop.',
        event_type: 'virtual',
        event_date: new Date(Date.now() + 10 * 24 * 60 * 60 * 1000).toISOString(),
        city: 'Online',
        is_virtual: true,
        virtual_link: 'https://meet.google.com/glowkart-masterclass',
        total_slots: 50,
        slots_filled: 1,
        what_creators_get: 'Certificate + future campaign priority',
        target_niche: ['Beauty', 'Lifestyle'],
        target_tier: ['micro'],
        status: 'upcoming',
      },
    ],
    { onConflict: 'id' }
  )

  await supabase.from('event_invites').upsert(
    [
      {
        id: IDS.invite1,
        event_id: IDS.event1,
        brand_id: brandId,
        creator_id: creatorId,
        status: 'accepted',
        ticket_code: 'GLW-EVT-001',
        ticket_generated_at: new Date().toISOString(),
        accepted_at: new Date().toISOString(),
      },
      {
        id: IDS.invite2,
        event_id: IDS.event2,
        brand_id: brandId,
        creator_id: creatorId,
        status: 'pending',
        ticket_code: 'GLW-EVT-002',
        ticket_generated_at: new Date().toISOString(),
      },
    ],
    { onConflict: 'id' }
  )

  await supabase.from('credit_transactions').upsert(
    [
      {
        id: IDS.creditTx1,
        brand_id: brandId,
        type: 'topup',
        amount: 2000,
        reason: 'credit_pack_purchase',
        reference_id: IDS.campaign1,
        razorpay_order_id: 'order_sample_001',
        razorpay_payment_id: 'pay_sample_001',
        balance_after: 40,
      },
      {
        id: IDS.creditTx2,
        brand_id: brandId,
        type: 'deduct',
        amount: 15,
        reason: 'bid_accepted',
        reference_id: IDS.collab1,
        razorpay_order_id: null,
        razorpay_payment_id: null,
        balance_after: 25,
      },
    ],
    { onConflict: 'id' }
  )

  await supabase.from('wallet_transactions').upsert(
    [
      {
        id: IDS.walletTx1,
        creator_id: creatorId,
        type: 'topup',
        amount: 2000,
        reason: 'wallet_topup',
        reference_id: IDS.event1,
        razorpay_order_id: 'order_wallet_001',
        razorpay_payment_id: 'pay_wallet_001',
        balance_after: 2000,
      },
      {
        id: IDS.walletTx2,
        creator_id: creatorId,
        type: 'deduct',
        amount: 500,
        reason: 'collab_fee_deducted',
        reference_id: IDS.collab1,
        razorpay_order_id: null,
        razorpay_payment_id: null,
        balance_after: 1500,
      },
    ],
    { onConflict: 'id' }
  )

  await supabase.from('messages').upsert(
    [
      {
        id: IDS.message1,
        collab_id: IDS.collab1,
        sender_id: brandId,
        sender_role: 'brand',
        content: 'Please share first draft by Wednesday noon.',
      },
      {
        id: IDS.message2,
        collab_id: IDS.collab1,
        sender_id: creatorId,
        sender_role: 'creator',
        content: 'Sure, I will send the edited draft tonight.',
      },
    ],
    { onConflict: 'id' }
  )

  await supabase.from('ratings').upsert(
    [
      {
        id: IDS.rating1,
        collab_id: IDS.collab2,
        rated_by: brandId,
        rated_user: creatorId,
        rated_role: 'creator',
        score: 5,
        review: 'Great communication and fast turnaround.',
      },
      {
        id: IDS.rating2,
        collab_id: IDS.collab2,
        rated_by: creatorId,
        rated_user: brandId,
        rated_role: 'brand',
        score: 4,
        review: 'Clear brief and timely approvals.',
      },
    ],
    { onConflict: 'id' }
  )

  await supabase.from('notifications').upsert(
    [
      {
        id: IDS.notification1,
        user_id: creatorId,
        type: 'campaign_update',
        title: 'New campaign assigned',
        body: 'You have been shortlisted for GlowKart Summer Serum Launch.',
        reference_id: IDS.campaign1,
        reference_type: 'campaign',
      },
      {
        id: IDS.notification2,
        user_id: brandId,
        type: 'bid_received',
        title: 'New creator bid',
        body: 'Aarav Creator submitted a bid for Night Routine Challenge.',
        reference_id: IDS.bid2,
        reference_type: 'bid',
      },
    ],
    { onConflict: 'id' }
  )

  console.log('Sample data seeded successfully.')
  console.log('--- Test Login Credentials ---')
  console.log(`Creator: ${SAMPLE.creator.email} / ${SAMPLE.creator.password}`)
  console.log(`Brand:   ${SAMPLE.brand.email} / ${SAMPLE.brand.password}`)
  console.log('--- Seeded IDs ---')
  console.log(`Creator ID: ${creatorId}`)
  console.log(`Brand ID:   ${brandId}`)
}

async function run() {
  await seedSuperAdmin()
  await seedSampleData()
}

run().catch((error) => {
  console.error(error)
  process.exit(1)
})
