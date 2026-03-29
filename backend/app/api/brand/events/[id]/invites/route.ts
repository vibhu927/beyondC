import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { z } from 'zod'
import { sendPushNotification } from '@/lib/notifications/push'

const sendInvitesSchema = z.object({
  creator_ids: z.array(z.string().uuid()).min(1).max(100),
})

export async function POST(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const supabase = createClient()
    const body = await request.json()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    // Validate creator IDs
    const { creator_ids } = sendInvitesSchema.parse(body)

    // Verify event belongs to brand
    const { data: event, error: eventError } = await supabase
      .from('events')
      .select('*')
      .eq('id', params.id)
      .eq('brand_id', user.id)
      .single()

    if (eventError || !event) {
      return NextResponse.json({ error: 'Event not found' }, { status: 404 })
    }

    // Check for existing invites to avoid duplicates
    const { data: existingInvites } = await supabase
      .from('event_invites')
      .select('creator_id')
      .eq('event_id', params.id)
      .in('creator_id', creator_ids)

    const existingCreatorIds = new Set(existingInvites?.map((inv: any) => inv.creator_id) || [])
    const newCreatorIds = creator_ids.filter((id: string) => !existingCreatorIds.has(id))

    if (newCreatorIds.length === 0) {
      return NextResponse.json({ 
        message: 'All creators already invited',
        invited_count: 0,
      })
    }

    // Create invites
    const invites = newCreatorIds.map((creator_id: string) => ({
      event_id: params.id,
      creator_id,
    }))

    const { data: createdInvites, error: inviteError } = await supabase
      .from('event_invites')
      .insert(invites)
      .select()

    if (inviteError) {
      return NextResponse.json({ error: inviteError.message }, { status: 400 })
    }

    // Notify all invited creators
    const notifications = newCreatorIds.map((creator_id: string) => ({
      user_id: creator_id,
      type: 'event_invite',
      title: 'Event Invitation',
      body: `You're invited to ${event.title}`,
      reference_id: params.id,
      reference_type: 'event',
    }))

    await supabase.from('notifications').insert(notifications)

    await Promise.all(
      newCreatorIds.map((creator_id: string) =>
        sendPushNotification({
          userId: creator_id,
          title: 'Event Invitation',
          body: `You're invited to ${event.title}`,
          data: {
            type: 'event_invite',
            event_id: params.id,
          },
        })
      )
    )

    return NextResponse.json({
      message: 'Invites sent successfully',
      invited_count: newCreatorIds.length,
      invites: createdInvites,
    })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}

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

    // Verify event belongs to brand
    const { data: event } = await supabase
      .from('events')
      .select('brand_id')
      .eq('id', params.id)
      .single()

    if (!event || event.brand_id !== user.id) {
      return NextResponse.json({ error: 'Event not found' }, { status: 404 })
    }

    // Get all invites for this event
    const { data: invites, error } = await supabase
      .from('event_invites')
      .select(`
        *,
        creator:creator_profiles!event_invites_creator_id_fkey (
          id,
          bio,
          niches,
          platforms,
          followers_count,
          avg_rating,
          tier
        )
      `)
      .eq('event_id', params.id)
      .order('created_at', { ascending: false })

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    return NextResponse.json({ invites })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
