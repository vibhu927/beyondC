import { NextRequest } from 'next/server'
import { requireAdminApiContext } from '@/lib/admin/auth'
import { apiError, apiSuccess } from '@/lib/admin/api'
import { writeAdminLog } from '@/lib/admin/logs'
import { createServiceClient } from '@/lib/supabase/service'

export async function POST(request: NextRequest, { params }: { params: { id: string } }) {
  const auth = await requireAdminApiContext(request)
  if (!auth.ok) return apiError(auth.error, auth.status)

  const service = createServiceClient()
  const { data, error } = await service
    .from('collabs')
    .update({ status: 'disputed' })
    .eq('id', params.id)
    .select()
    .single()

  if (error) return apiError(error.message)

  await writeAdminLog({
    adminId: auth.context.userId,
    action: 'marked_dispute',
    targetType: 'collab',
    targetId: params.id,
    details: {},
  })

  return apiSuccess(data)
}
