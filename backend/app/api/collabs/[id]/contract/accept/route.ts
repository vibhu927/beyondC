import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function PUT(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const supabase = createClient()

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    const { data: collab, error: collabError } = await supabase
      .from('collabs')
      .select('*')
      .eq('id', params.id)
      .or(`brand_id.eq.${user.id},creator_id.eq.${user.id}`)
      .single()

    if (collabError || !collab) {
      return NextResponse.json({ error: 'Collab not found' }, { status: 404 })
    }

    if (!collab.contract_terms) {
      return NextResponse.json({ error: 'No contract terms found' }, { status: 400 })
    }

    const isCreator = collab.creator_id === user.id
    const isBrand = collab.brand_id === user.id

    if (!isCreator && !isBrand) {
      return NextResponse.json({ error: 'Not authorized' }, { status: 403 })
    }

    const updateData: Record<string, unknown> = {}

    if (isCreator) {
      if (collab.creator_contract_accepted) {
        return NextResponse.json({ error: 'Already accepted' }, { status: 400 })
      }
      updateData.creator_contract_accepted = true
      updateData.creator_contract_accepted_at = new Date().toISOString()
    }

    if (isBrand) {
      if (collab.brand_contract_accepted) {
        return NextResponse.json({ error: 'Already accepted' }, { status: 400 })
      }
      updateData.brand_contract_accepted = true
      updateData.brand_contract_accepted_at = new Date().toISOString()
    }

    const bothAccepted =
      (isCreator && collab.brand_contract_accepted) ||
      (isBrand && collab.creator_contract_accepted)

    if (bothAccepted) {
      updateData.status = 'active'
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

    const otherPartyId = isCreator ? collab.brand_id : collab.creator_id
    const acceptorRole = isCreator ? 'Creator' : 'Brand'

    await supabase.from('notifications').insert({
      user_id: otherPartyId,
      type: 'contract_accepted',
      title: 'Contract Accepted',
      body: `${acceptorRole} has accepted the contract terms.`,
      reference_id: params.id,
      reference_type: 'collab',
    })

    return NextResponse.json({
      message: bothAccepted ? 'Both parties accepted. Collab is now active.' : 'Contract accepted. Waiting for the other party.',
      collab: updatedCollab,
      bothAccepted,
    })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
