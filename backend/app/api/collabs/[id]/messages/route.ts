import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { z } from 'zod'
import { sendPushNotification } from '@/lib/notifications/push'

const sendMessageSchema = z.object({
  content: z.string().min(1).max(2000),
})

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

    // Verify user is part of this collab
    const { data: collab, error: collabError } = await supabase
      .from('collabs')
      .select('brand_id, creator_id')
      .eq('id', params.id)
      .single()

    if (collabError || !collab) {
      return NextResponse.json({ error: 'Collab not found' }, { status: 404 })
    }

    if (collab.brand_id !== user.id && collab.creator_id !== user.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 403 })
    }

    // Get all messages for this collab
    const { data: messages, error } = await supabase
      .from('messages')
      .select('*')
      .eq('collab_id', params.id)
      .order('created_at', { ascending: true })

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    return NextResponse.json({ messages })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}

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

    // Validate message content
    const { content } = sendMessageSchema.parse(body)

    // Verify user is part of this collab
    const { data: collab, error: collabError } = await supabase
      .from('collabs')
      .select('brand_id, creator_id')
      .eq('id', params.id)
      .single()

    if (collabError || !collab) {
      return NextResponse.json({ error: 'Collab not found' }, { status: 404 })
    }

    if (collab.brand_id !== user.id && collab.creator_id !== user.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 403 })
    }

    // Create message
    const { data: message, error } = await supabase
      .from('messages')
      .insert({
        collab_id: params.id,
        sender_id: user.id,
        content,
      })
      .select()
      .single()

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    // Notify the other participant
    const recipient_id = collab.brand_id === user.id ? collab.creator_id : collab.brand_id
    
    await supabase.from('notifications').insert({
      user_id: recipient_id,
      type: 'new_message',
      title: 'New Message',
      body: content.substring(0, 100),
      reference_id: params.id,
      reference_type: 'collab',
    })

    await sendPushNotification({
      userId: recipient_id,
      title: 'New Message',
      body: content.substring(0, 100),
      data: {
        type: 'new_message',
        collab_id: params.id,
      },
    })

    return NextResponse.json({ message })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
