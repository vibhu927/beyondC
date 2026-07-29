import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { z } from 'zod'

const updateStatusSchema = z.object({
  status: z.enum(['started', 'working_on_draft', 'draft_ready', 'content_posted', 'completed']),
  message: z.string().max(500).optional(),
})

const statusMessages: Record<string, string> = {
  started: 'Creator has started working on the collab',
  working_on_draft: 'Creator is working on the draft',
  draft_ready: 'Creator has finished the draft',
  content_posted: 'Creator has posted the content',
  completed: 'Creator has marked the collab as completed',
}

export async function PUT(
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

    const { status, message } = updateStatusSchema.parse(body)

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

    const updateData: Record<string, unknown> = {
      collab_status: status,
      status_updated_at: new Date().toISOString(),
      status_update_message: message || null,
    }

    if (status === 'completed') {
      updateData.status = 'completed'
    }

    const { data: updatedCollab, error: updateError } = await supabase
      .from('collabs')
      .update(updateData)
      .eq('id', params.id)
      .select()
      .single()

    if (updateError) {
      return NextResponse.json({ error: updateError.message }, { status: 400 })
    }

    await supabase.from('notifications').insert({
      user_id: collab.brand_id,
      type: 'collab_status_updated',
      title: 'Collab Status Updated',
      body: message?.trim()
        ? `${statusMessages[status]}: "${message.trim()}"`
        : statusMessages[status],
      reference_id: params.id,
      reference_type: 'collab',
    })

    return NextResponse.json({
      message: 'Status updated',
      collab: updatedCollab,
    })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
