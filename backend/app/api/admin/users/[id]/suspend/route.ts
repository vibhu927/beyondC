import { NextRequest } from 'next/server'
import { requireAdminApiContext } from '@/lib/admin/auth'
import { apiError, apiSuccess } from '@/lib/admin/api'
import { writeAdminLog } from '@/lib/admin/logs'
import { createServiceClient } from '@/lib/supabase/service'
import { parseRequestBody } from '@/lib/admin/request'

export async function POST(request: NextRequest, { params }: { params: { id: string } }) {
  const auth = await requireAdminApiContext(request)
  if (!auth.ok) return apiError(auth.error, auth.status)

  const service = createServiceClient()
  const payload = await parseRequestBody(request)

  const { data: profile, error: readError } = await service
    .from('profiles')
    .select('is_suspended')
    .eq('id', params.id)
    .single()

  if (readError || !profile) return apiError('User not found', 404)

  const nextState = !profile.is_suspended
  const { data, error } = await service
    .from('profiles')
    .update({ is_suspended: nextState })
    .eq('id', params.id)
    .select('id,is_suspended')
    .single()

  if (error) return apiError(error.message)

  await writeAdminLog({
    adminId: auth.context.userId,
    action: nextState ? 'suspended_user' : 'unsuspended_user',
    targetType: 'user',
    targetId: params.id,
    details: { reason: payload.reason ?? null },
  })

  return apiSuccess(data)
}
