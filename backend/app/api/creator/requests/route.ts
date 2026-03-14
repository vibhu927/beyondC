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

    // Get all requests sent to this creator
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
      .order('created_at', { ascending: false })

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    return NextResponse.json({ requests })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
