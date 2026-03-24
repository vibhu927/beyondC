import { NextRequest } from 'next/server'
import { requireAdminApiContext } from '@/lib/admin/auth'
import { apiError, apiSuccess } from '@/lib/admin/api'
import { writeAdminLog } from '@/lib/admin/logs'
import { createServiceClient } from '@/lib/supabase/service'
import { parseRequestBody } from '@/lib/admin/request'

export async function POST(request: NextRequest, { params }: { params: { id: string } }) {
  const auth = await requireAdminApiContext(request)
  if (!auth.ok) return apiError(auth.error, auth.status)

  const body = await parseRequestBody(request)
  const resolution = String(body.resolution ?? 'mutual')
  const adminNotes = String(body.admin_notes ?? '')

  const service = createServiceClient()
  const { data: collab, error: readError } = await service
    .from('collabs')
    .select('id,creator_id,brand_id')
    .eq('id', params.id)
    .single()

  if (readError || !collab) return apiError('Collab not found', 404)

  const { data, error } = await service
    .from('collabs')
    .update({ status: 'completed' })
    .eq('id', params.id)
    .select()
    .single()

  if (error) return apiError(error.message)

  await service.from('notifications').insert([
    {
      user_id: collab.creator_id,
      type: 'dispute_resolved',
      title: 'Dispute Resolved',
      body: `Your dispute on collab ${params.id} has been resolved (${resolution}).`,
      reference_id: collab.id,
      reference_type: 'collab',
    },
    {
      user_id: collab.brand_id,
      type: 'dispute_resolved',
      title: 'Dispute Resolved',
      body: `Your dispute on collab ${params.id} has been resolved (${resolution}).`,
      reference_id: collab.id,
      reference_type: 'collab',
    },
  ])

  await writeAdminLog({
    adminId: auth.context.userId,
    action: 'resolved_dispute',
    targetType: 'collab',
    targetId: params.id,
    details: { resolution, adminNotes },
  })

  return apiSuccess(data)
}
