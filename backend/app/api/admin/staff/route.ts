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
  const action = String(body.action ?? 'add_staff')
  const service = createServiceClient()

  if (action === 'create_role') {
    const { data, error } = await service
      .from('admin_roles')
      .insert({
        name: String(body.name).trim(),
        designation: String(body.designation).trim(),
        description: body.description ? String(body.description) : null,
      })
      .select()
      .single()

    if (error) return apiError(error.message)

    await writeAdminLog({
      adminId: auth.context.userId,
      action: 'created_admin_role',
      targetType: 'role',
      targetId: data.id,
      details: data,
    })

    return apiSuccess(data)
  }

  const email = String(body.email || '').trim().toLowerCase()
  const roleId = String(body.role_id || '').trim()
  const designation = body.designation ? String(body.designation) : null

  if (!email || !roleId) return apiError('email and role_id are required')

  const { data: profile } = await service.from('profiles').select('id').eq('email', email).single()
  if (!profile) return apiError('User with this email does not exist', 404)

  await service.from('profiles').update({ is_admin: true }).eq('id', profile.id)

  const { data, error } = await service
    .from('admin_staff')
    .upsert({
      id: profile.id,
      role_id: roleId,
      designation,
      is_active: true,
      added_by: auth.context.userId,
      updated_at: new Date().toISOString(),
    })
    .select()
    .single()

  if (error) return apiError(error.message)

  await writeAdminLog({
    adminId: auth.context.userId,
    action: 'added_admin_staff',
    targetType: 'user',
    targetId: profile.id,
    details: { roleId, designation },
  })

  return apiSuccess(data)
}
