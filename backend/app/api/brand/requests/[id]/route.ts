import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const supabase = createClient()

    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser()

    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    const { data: requestRow, error: requestError } = await supabase
      .from('collab_requests')
      .select('id,status,brand_id')
      .eq('id', params.id)
      .eq('brand_id', user.id)
      .maybeSingle()

    if (requestError) {
      return NextResponse.json({ error: requestError.message }, { status: 400 })
    }

    if (!requestRow) {
      return NextResponse.json({ error: 'Request not found' }, { status: 404 })
    }

    if (requestRow.status !== 'pending') {
      return NextResponse.json(
        { error: 'Only pending requests can be cancelled' },
        { status: 400 }
      )
    }

    const { error: deleteError } = await supabase
      .from('collab_requests')
      .delete()
      .eq('id', params.id)
      .eq('brand_id', user.id)

    if (deleteError) {
      return NextResponse.json({ error: deleteError.message }, { status: 400 })
    }

    return NextResponse.json({ message: 'Request cancelled' })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}

export async function PATCH(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const supabase = createClient()

    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser()

    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    const { data: requestRow, error: requestError } = await supabase
      .from('collab_requests')
      .select('id,status,brand_id')
      .eq('id', params.id)
      .eq('brand_id', user.id)
      .maybeSingle()

    if (requestError) {
      return NextResponse.json({ error: requestError.message }, { status: 400 })
    }

    if (!requestRow) {
      return NextResponse.json({ error: 'Request not found' }, { status: 404 })
    }

    if (requestRow.status !== 'pending') {
      return NextResponse.json(
        { error: 'Only pending requests can be withdrawn' },
        { status: 400 }
      )
    }

    const { error: updateError } = await supabase
      .from('collab_requests')
      .update({ status: 'expired' })
      .eq('id', params.id)
      .eq('brand_id', user.id)

    if (updateError) {
      return NextResponse.json({ error: updateError.message }, { status: 400 })
    }

    return NextResponse.json({ message: 'Request withdrawn' })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
