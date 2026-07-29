import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { z } from 'zod'

const contractTermsSchema = z.object({
  deliverables: z.string().min(1),
  timeline: z.string().min(1),
  payment_terms: z.string().min(1),
  milestones: z.string().optional(),
  special_conditions: z.string().optional(),
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

    const terms = contractTermsSchema.parse(body)

    const { data: collab, error: collabError } = await supabase
      .from('collabs')
      .select('*')
      .eq('id', params.id)
      .eq('brand_id', user.id)
      .single()

    if (collabError || !collab) {
      return NextResponse.json({ error: 'Collab not found' }, { status: 404 })
    }

    const { data: updatedCollab, error: updateError } = await supabase
      .from('collabs')
      .update({
        contract_terms: terms,
        status: 'pending_contract',
      })
      .eq('id', params.id)
      .select()
      .single()

    if (updateError) {
      return NextResponse.json({ error: updateError.message }, { status: 400 })
    }

    await supabase.from('notifications').insert({
      user_id: collab.creator_id,
      type: 'contract_created',
      title: 'New Contract to Review',
      body: 'A brand has created contract terms for your collab. Please review and accept.',
      reference_id: params.id,
      reference_type: 'collab',
    })

    return NextResponse.json({
      message: 'Contract terms created',
      collab: updatedCollab,
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

    const { data: collab, error: collabError } = await supabase
      .from('collabs')
      .select('contract_terms, creator_contract_accepted, brand_contract_accepted, creator_contract_accepted_at, brand_contract_accepted_at')
      .eq('id', params.id)
      .or(`brand_id.eq.${user.id},creator_id.eq.${user.id}`)
      .single()

    if (collabError || !collab) {
      return NextResponse.json({ error: 'Collab not found' }, { status: 404 })
    }

    return NextResponse.json({ contract: collab })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
