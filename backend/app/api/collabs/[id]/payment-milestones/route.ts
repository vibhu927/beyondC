import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { z } from 'zod'

const milestoneSchema = z.object({
  name: z.string().min(1).max(100),
  percentage: z.number().positive().max(100),
})

const milestonesArraySchema = z.object({
  payment_structure: z.enum(['full_upfront', 'milestone_based']),
  milestones: z.array(milestoneSchema).optional(),
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

    const { payment_structure, milestones } = milestonesArraySchema.parse(body)

    const { data: collab, error: collabError } = await supabase
      .from('collabs')
      .select('*')
      .eq('id', params.id)
      .eq('brand_id', user.id)
      .single()

    if (collabError || !collab) {
      return NextResponse.json({ error: 'Collab not found' }, { status: 404 })
    }

    if (payment_structure === 'milestone_based') {
      if (!milestones || milestones.length === 0) {
        return NextResponse.json({ error: 'Milestones required for milestone-based payment' }, { status: 400 })
      }

      const totalPercentage = milestones.reduce((sum, m) => sum + m.percentage, 0)
      if (Math.abs(totalPercentage - 100) > 0.01) {
        return NextResponse.json({ error: 'Milestones must sum to 100%' }, { status: 400 })
      }

      await supabase
        .from('payment_milestones')
        .delete()
        .eq('collab_id', params.id)

      const milestoneInserts = milestones.map((m, index) => ({
        collab_id: params.id,
        name: m.name,
        percentage: m.percentage,
        amount_paise: Math.round((collab.agreed_amount * m.percentage) / 100),
        order_index: index,
      }))

      const { error: insertError } = await supabase
        .from('payment_milestones')
        .insert(milestoneInserts)

      if (insertError) {
        return NextResponse.json({ error: insertError.message }, { status: 400 })
      }
    }

    const { data: updatedCollab, error: updateError } = await supabase
      .from('collabs')
      .update({ payment_structure })
      .eq('id', params.id)
      .select()
      .single()

    if (updateError) {
      return NextResponse.json({ error: updateError.message }, { status: 400 })
    }

    return NextResponse.json({
      message: 'Payment structure updated',
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

    const { data: milestones, error: queryError } = await supabase
      .from('payment_milestones')
      .select('*')
      .eq('collab_id', params.id)
      .order('order_index', { ascending: true })

    if (queryError) {
      return NextResponse.json({ error: queryError.message }, { status: 400 })
    }

    return NextResponse.json({ milestones })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
