import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { createRatingSchema } from '@/lib/validators'

export async function POST(request: NextRequest) {
  try {
    const supabase = createClient()
    const body = await request.json()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    // Validate rating data
    const validatedData = createRatingSchema.parse(body)

    // Verify collab exists and user is participant
    const { data: collab, error: collabError } = await supabase
      .from('collabs')
      .select('*')
      .eq('id', validatedData.collab_id)
      .single()

    if (collabError || !collab) {
      return NextResponse.json({ error: 'Collab not found' }, { status: 404 })
    }

    if (collab.brand_id !== user.id && collab.creator_id !== user.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 403 })
    }

    if (collab.status !== 'completed') {
      return NextResponse.json({ error: 'Can only rate completed collabs' }, { status: 400 })
    }

    // Check if already rated
    const { data: existingRating } = await supabase
      .from('ratings')
      .select('id')
      .eq('collab_id', validatedData.collab_id)
      .eq('rater_id', user.id)
      .single()

    if (existingRating) {
      return NextResponse.json({ error: 'Already rated this collab' }, { status: 400 })
    }

    // Determine who is being rated
    const rated_id = collab.brand_id === user.id ? collab.creator_id : collab.brand_id

    // Create rating
    const { data: rating, error } = await supabase
      .from('ratings')
      .insert({
        collab_id: validatedData.collab_id,
        rater_id: user.id,
        rated_id,
        rating: validatedData.rating,
        review: validatedData.review,
      })
      .select()
      .single()

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    // Notify the rated user
    await supabase.from('notifications').insert({
      user_id: rated_id,
      type: 'new_rating',
      title: 'New Rating Received',
      body: `You received a ${validatedData.rating}-star rating`,
      reference_id: validatedData.collab_id,
      reference_type: 'collab',
    })

    // Note: avg_rating will be updated automatically by the update_avg_rating trigger

    return NextResponse.json({ 
      message: 'Rating submitted successfully',
      rating,
    })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
