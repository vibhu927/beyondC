import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { z } from 'zod'

const submitContentSchema = z.object({
  content_url: z.string().url(),
  content_type: z.enum(['image', 'video', 'link']),
  caption: z.string().max(2000).optional(),
  notes: z.string().max(1000).optional(),
})

export async function POST(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const supabase = createClient()
    const body = await request.json()

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    const content = submitContentSchema.parse(body)

    const { data: collab, error: collabError } = await supabase
      .from('collabs')
      .select('*')
      .eq('id', params.id)
      .eq('creator_id', user.id)
      .single()

    if (collabError || !collab) {
      return NextResponse.json({ error: 'Collab not found' }, { status: 404 })
    }

    if (collab.status !== 'in_progress' && collab.status !== 'active') {
      return NextResponse.json({ error: 'Collab is not active' }, { status: 400 })
    }

    const { data: submission, error: insertError } = await supabase
      .from('content_submissions')
      .insert({
        collab_id: params.id,
        submitted_by: user.id,
        content_url: content.content_url,
        content_type: content.content_type,
        caption: content.caption || null,
        notes: content.notes || null,
      })
      .select()
      .single()

    if (insertError) {
      return NextResponse.json({ error: insertError.message }, { status: 400 })
    }

    await supabase.from('notifications').insert({
      user_id: collab.brand_id,
      type: 'content_submitted',
      title: 'Content Submitted',
      body: 'Creator has submitted content for your review.',
      reference_id: params.id,
      reference_type: 'collab',
    })

    return NextResponse.json({
      message: 'Content submitted',
      submission,
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

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    const { data: submissions, error: queryError } = await supabase
      .from('content_submissions')
      .select('*')
      .eq('collab_id', params.id)
      .order('submitted_at', { ascending: false })

    if (queryError) {
      return NextResponse.json({ error: queryError.message }, { status: 400 })
    }

    return NextResponse.json({ submissions })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
