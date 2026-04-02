import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { createCollabRequestSchema } from '@/lib/validators'
import { sendPushNotification } from '@/lib/notifications/push'

export async function GET(request: NextRequest) {
  try {
    const supabase = createClient()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    // Get all requests sent by this brand
    const { data: requests, error } = await supabase
      .from('collab_requests')
      .select(`
        *,
        creator:creator_profiles!collab_requests_creator_id_fkey (
          id,
          bio,
          platforms,
          niche,
          follower_count,
          avg_rating,
          instagram_username,
          tier
        )
      `)
      .eq('brand_id', user.id)
      .order('created_at', { ascending: false })

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    const requestIds = (requests ?? []).map((item: any) => item.id)
    const creatorIds = Array.from(new Set((requests ?? []).map((item: any) => item.creator_id).filter(Boolean)))

    const { data: creatorUsers } = creatorIds.length
      ? await supabase
          .from('profiles')
          .select('id,first_name,full_name')
          .in('id', creatorIds)
      : { data: [] as any[] }
    const { data: linkedCollabs } = requestIds.length
      ? await supabase
          .from('collabs')
          .select('id,source_id')
          .eq('brand_id', user.id)
          .eq('source', 'direct_request')
          .in('source_id', requestIds)
      : { data: [] as any[] }

    const collabByRequestId = new Map((linkedCollabs ?? []).map((row: any) => [row.source_id, row.id]))
    const creatorUserById = new Map((creatorUsers ?? []).map((row: any) => [row.id, row]))

    const enriched = (requests ?? []).map((item: any) => {
      const creatorUser = creatorUserById.get(item.creator_id)
      const creatorInstagramHandle = item.creator?.instagram_username || null
      return {
        ...item,
        creator_first_name: creatorUser?.first_name ?? null,
        creator_full_name: creatorUser?.full_name ?? null,
        creator_instagram_handle: creatorInstagramHandle,
        collab_id: collabByRequestId.get(item.id) ?? null,
      }
    })

    return NextResponse.json({ requests: enriched })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const supabase = createClient()
    const body = await request.json()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    // Validate request data
    const validatedData = createCollabRequestSchema.parse(body)

    // Create collab request
    const { data: collabRequest, error: requestError } = await supabase
      .from('collab_requests')
      .insert({
        brand_id: user.id,
        creator_id: validatedData.creator_id,
        collab_type: validatedData.collab_type,
        message: validatedData.message,
        budget: validatedData.budget,
        deliverables: validatedData.deliverables,
      })
      .select()
      .single()

    if (requestError) {
      return NextResponse.json({ error: requestError.message }, { status: 400 })
    }

    // Notify creator
    await supabase.from('notifications').insert({
      user_id: validatedData.creator_id,
      type: 'collab_request',
      title: 'New Collab Request',
      body: 'A brand sent you a collaboration request',
      reference_id: collabRequest.id,
      reference_type: 'request',
    })

    await sendPushNotification({
      userId: validatedData.creator_id,
      title: 'New Collab Request',
      body: 'A brand sent you a collaboration request',
      data: {
        type: 'request_received',
        request_id: collabRequest.id,
      },
    })

    return NextResponse.json({ 
      message: 'Request sent successfully',
      request: collabRequest,
    })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
