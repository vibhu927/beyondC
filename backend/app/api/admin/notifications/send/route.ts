import { NextRequest } from 'next/server'
import { requireAdminApiContext } from '@/lib/admin/auth'
import { apiError, apiSuccess } from '@/lib/admin/api'
import { writeAdminLog } from '@/lib/admin/logs'
import { createServiceClient } from '@/lib/supabase/service'
import { parseRequestBody } from '@/lib/admin/request'

export async function POST(request: NextRequest) {
  const auth = await requireAdminApiContext(request)
  if (!auth.ok) return apiError(auth.error, auth.status)

  const body = await parseRequestBody(request)
  const target = String(body.target || 'all_users')
  const title = String(body.title || '')
  const bodyText = String(body.body || '')

  if (!title || !bodyText) {
    return apiError('title and body are required')
  }

  const service = createServiceClient()
  let profileQuery = service.from('profiles').select('id,role')

  if (target === 'all_creators') profileQuery = profileQuery.eq('role', 'creator')
  if (target === 'all_brands') profileQuery = profileQuery.eq('role', 'brand')
  if (target !== 'all_users' && target !== 'all_creators' && target !== 'all_brands') {
    profileQuery = profileQuery.eq('id', target)
  }

  const { data: recipients, error: recipientsError } = await profileQuery
  if (recipientsError) return apiError(recipientsError.message)

  const rows = (recipients ?? []).map((recipient) => ({
    user_id: recipient.id,
    type: 'admin_broadcast',
    title,
    body: bodyText,
    reference_type: 'admin_notification',
  }))

  if (rows.length > 0) {
    const { error: insertError } = await service.from('notifications').insert(rows)
    if (insertError) return apiError(insertError.message)
  }

  await writeAdminLog({
    adminId: auth.context.userId,
    action: 'send_notification',
    targetType: 'notification',
    details: {
      target,
      title,
      recipients_count: rows.length,
    },
  })

  return apiSuccess({ recipients: rows.length })
}
