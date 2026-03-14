import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { createEventSchema } from '@/lib/validators'

export async function GET(request: NextRequest) {
  try {
    const supabase = createClient()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    // Get all events created by this brand with invite counts
    const { data: events, error } = await supabase
      .from('events')
      .select(`
        *,
        invites:event_invites(count),
        accepted:event_invites!inner(count)
      `)
      .eq('brand_id', user.id)
      .eq('accepted.status', 'accepted')
      .order('event_date', { ascending: true })

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    return NextResponse.json({ events })
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

    // Validate event data
    const validatedData = createEventSchema.parse(body)

    // Create event
    const { data: event, error } = await supabase
      .from('events')
      .insert({
        brand_id: user.id,
        ...validatedData,
      })
      .select()
      .single()

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    return NextResponse.json({ event })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
