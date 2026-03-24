import { NextRequest } from 'next/server'
import { requireAdminApiContext } from '@/lib/admin/auth'
import { apiError, apiSuccess } from '@/lib/admin/api'
import { writeAdminLog } from '@/lib/admin/logs'
import { parseRequestBody } from '@/lib/admin/request'
import { createServiceClient } from '@/lib/supabase/service'

export async function POST(request: NextRequest) {
  const auth = await requireAdminApiContext(request)
  if (!auth.ok) return apiError(auth.error, auth.status)
  if (!auth.context.profile.is_super_admin) return apiError('Super admin required', 403)

  const body = await parseRequestBody(request)
  const key = String(body.key || '').trim()
  if (!key) return apiError('key is required')

  let value: unknown = body.value
  if (typeof body.value === 'string') {
    try {
      value = JSON.parse(body.value)
    } catch {
      return apiError('value must be valid JSON')
    }
  }

  const service = createServiceClient()
  const { data, error } = await service
    .from('platform_settings')
    .upsert({
      key,
      label: body.label ? String(body.label) : null,
      value,
      updated_by: auth.context.userId,
      updated_at: new Date().toISOString(),
    })
    .select()
    .single()

  if (error) return apiError(error.message)

  await writeAdminLog({
    adminId: auth.context.userId,
    action: 'updated_platform_setting',
    targetType: 'setting',
    targetId: null,
    details: { key },
  })

  return apiSuccess(data)
}
