import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { z } from 'zod'

const updateMilestoneSchema = z.object({
  milestone: z.enum(['brief_reviewed', 'draft_submitted', 'content_posted']),
})

export async function PUT(
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

    // Validate milestone
    const { milestone } = updateMilestoneSchema.parse(body)

    // Get collab details
    const { data: collab, error: collabError } = await supabase
      .from('collabs')
      .select('*')
      .eq('id', params.id)
      .eq('creator_id', user.id)
      .single()

    if (collabError || !collab) {
      return NextResponse.json({ error: 'Collab not found' }, { status: 404 })
    }

    if (collab.status !== 'in_progress') {
      return NextResponse.json({ error: 'Collab is not in progress' }, { status: 400 })
    }

    // Update milestone
    const { data: updatedCollab, error: updateError } = await supabase
      .from('collabs')
      .update({ milestone_status: milestone })
      .eq('id', params.id)
      .select()
      .single()

    if (updateError) {
      return NextResponse.json({ error: updateError.message }, { status: 400 })
    }

    // Notify brand
    const milestoneMessages: Record<string, string> = {
      brief_reviewed: 'Creator has reviewed the campaign brief',
      draft_submitted: 'Creator has submitted the content draft',
      content_posted: 'Creator has posted the content',
    }

    await supabase.from('notifications').insert({
      user_id: collab.brand_id,
      type: 'milestone_updated',
      title: 'Milestone Updated',
      body: milestoneMessages[milestone],
      reference_id: params.id,
      reference_type: 'collab',
    })

    return NextResponse.json({ 
      message: 'Milestone updated',
      collab: updatedCollab,
    })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
