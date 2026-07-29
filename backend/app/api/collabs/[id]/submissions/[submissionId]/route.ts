import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { z } from 'zod'

const reviewSubmissionSchema = z.object({
  status: z.enum(['approved', 'rejected', 'revision_requested']),
  brand_feedback: z.string().max(2000).optional(),
})

export async function PUT(
  request: NextRequest,
  { params }: { params: { id: string; submissionId: string } }
) {
  try {
    const supabase = createClient()
    const body = await request.json()

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    const { status, brand_feedback } = reviewSubmissionSchema.parse(body)

    const { data: collab, error: collabError } = await supabase
      .from('collabs')
      .select('*')
      .eq('id', params.id)
      .eq('brand_id', user.id)
      .single()

    if (collabError || !collab) {
      return NextResponse.json({ error: 'Collab not found' }, { status: 404 })
    }

    const { data: submission, error: submissionError } = await supabase
      .from('content_submissions')
      .select('*')
      .eq('id', params.submissionId)
      .eq('collab_id', params.id)
      .single()

    if (submissionError || !submission) {
      return NextResponse.json({ error: 'Submission not found' }, { status: 404 })
    }

    if (submission.status !== 'pending') {
      return NextResponse.json({ error: 'Submission already reviewed' }, { status: 400 })
    }

    const { data: updatedSubmission, error: updateError } = await supabase
      .from('content_submissions')
      .update({
        status,
        brand_feedback: brand_feedback || null,
        reviewed_at: new Date().toISOString(),
      })
      .eq('id', params.submissionId)
      .select()
      .single()

    if (updateError) {
      return NextResponse.json({ error: updateError.message }, { status: 400 })
    }

    const statusMessages: Record<string, string> = {
      approved: 'Your content has been approved!',
      rejected: 'Your content has been rejected.',
      revision_requested: 'Revision requested for your content.',
    }

    await supabase.from('notifications').insert({
      user_id: collab.creator_id,
      type: 'content_reviewed',
      title: 'Content Reviewed',
      body: brand_feedback?.trim()
        ? `${statusMessages[status]} Feedback: "${brand_feedback.trim()}"`
        : statusMessages[status],
      reference_id: params.id,
      reference_type: 'collab',
    })

    return NextResponse.json({
      message: 'Submission reviewed',
      submission: updatedSubmission,
    })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
