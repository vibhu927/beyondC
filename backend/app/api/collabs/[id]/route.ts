import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const supabase = createClient()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    // Get collab details (RLS ensures user is participant)
    const { data: collab, error } = await supabase
      .from('collabs')
      .select(`
        *,
        brand:brand_profiles!collabs_brand_id_fkey (
          id,
          brand_name,
          brand_category,
          logo_url,
          website,
          contact_email,
          size
        ),
        creator:creator_profiles!collabs_creator_id_fkey (
          id,
          bio,
          niche,
          platforms,
          follower_count,
          avg_rating,
          tier
        )
      `)
      .eq('id', params.id)
      .or(`brand_id.eq.${user.id},creator_id.eq.${user.id}`)
      .single()

    if (error || !collab) {
      return NextResponse.json({ error: 'Collab not found' }, { status: 404 })
    }

    const creatorId = (collab as any).creator_id
    const { data: creatorUser } = creatorId
      ? await supabase
          .from('profiles')
          .select('first_name,full_name')
          .eq('id', creatorId)
          .maybeSingle()
      : { data: null as any }

    const enriched = {
      ...collab,
      creator_first_name: creatorUser?.first_name ?? null,
      creator_full_name: creatorUser?.full_name ?? null,
    }

    return NextResponse.json({ collab: enriched })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
