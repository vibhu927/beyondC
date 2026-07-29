import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function GET(request: NextRequest) {
  try {
    const supabase = createClient()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    // Get pending requests sent to this creator
    const { data: requests, error } = await supabase
      .from('collab_requests')
      .select(`
        *,
        brand:brand_profiles!collab_requests_brand_id_fkey (
          id,
          brand_name,
          brand_category,
          logo_url,
          avg_rating,
          size
        )
      `)
      .eq('creator_id', user.id)
      .eq('status', 'pending')
      .order('created_at', { ascending: false })

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    const flat = (requests || []).map((r: any) => ({
      ...r,
      brand_name: r.brand?.brand_name ?? '',
      brand_logo: r.brand?.logo_url ?? null,
      brand_category: r.brand?.brand_category ?? '',
      brand: undefined,
    }))

    return NextResponse.json({ requests: flat })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
