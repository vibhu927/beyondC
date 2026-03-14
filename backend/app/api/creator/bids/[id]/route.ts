import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function DELETE(
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

    // Withdraw bid (update status to 'withdrawn')
    const { data, error } = await supabase
      .from('bids')
      .update({ status: 'withdrawn' })
      .eq('id', params.id)
      .eq('creator_id', user.id)
      .eq('status', 'pending') // Can only withdraw pending bids
      .select()
      .single()

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    if (!data) {
      return NextResponse.json(
        { error: 'Bid not found or cannot be withdrawn' },
        { status: 404 }
      )
    }

    return NextResponse.json({ message: 'Bid withdrawn successfully', bid: data })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
