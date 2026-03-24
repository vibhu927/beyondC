import { NextRequest } from 'next/server'
import { requireAdminApiContext } from '@/lib/admin/auth'
import { apiError, apiSuccess } from '@/lib/admin/api'
import { writeAdminLog } from '@/lib/admin/logs'
import { parseRequestBody } from '@/lib/admin/request'
import { createServiceClient } from '@/lib/supabase/service'

function parseBoolean(value: any) {
  if (typeof value === 'boolean') return value
  if (typeof value === 'string') return value.toLowerCase() === 'true'
  return undefined
}

export async function PUT(request: NextRequest, { params }: { params: { id: string } }) {
  const auth = await requireAdminApiContext(request)
  if (!auth.ok) return apiError(auth.error, auth.status)
  if (!auth.context.profile.is_super_admin) return apiError('Super admin required', 403)

  const body = await parseRequestBody(request)
  return updateStaffByPayload(auth.context.userId, params.id, body)
}

async function updateStaffByPayload(adminUserId: string, staffId: string, body: Record<string, any>) {
  const service = createServiceClient()

  if (body.action === 'toggle_permission') {
    const permissionId = String(body.permission_id || '')
    const field = String(body.field || '')
    if (!permissionId || !['can_view', 'can_edit', 'can_delete'].includes(field)) {
      return apiError('Invalid permission toggle payload')
    }

    const { data: row } = await service
      .from('admin_permissions')
      .select('id,can_view,can_edit,can_delete')
      .eq('id', permissionId)
      .single()

    if (!row) return apiError('Permission row not found', 404)

    const nextValue = !Boolean((row as any)[field])
    const { data, error } = await service
      .from('admin_permissions')
      .update({ [field]: nextValue })
      .eq('id', permissionId)
      .select()
      .single()

    if (error) return apiError(error.message)

    await writeAdminLog({
      adminId: adminUserId,
      action: 'updated_role_permission',
      targetType: 'role',
      targetId: staffId,
      details: { permissionId, field, nextValue },
    })

    return apiSuccess(data)
  }

  const isActive = parseBoolean(body.is_active)
  const roleId = body.role_id ? String(body.role_id) : undefined
  const designation = body.designation ? String(body.designation) : undefined

  const payload: Record<string, any> = {
    updated_at: new Date().toISOString(),
  }

  if (typeof isActive === 'boolean') payload.is_active = isActive
  if (roleId) payload.role_id = roleId
  if (designation) payload.designation = designation

  const { data, error } = await service
    .from('admin_staff')
    .update(payload)
    .eq('id', staffId)
    .select()
    .single()

  if (error) return apiError(error.message)

  if (typeof isActive === 'boolean' && !isActive) {
    await service.from('profiles').update({ is_admin: false }).eq('id', staffId)
  }

  await writeAdminLog({
    adminId: adminUserId,
    action: 'updated_admin_staff',
    targetType: 'user',
    targetId: staffId,
    details: payload,
  })

  return apiSuccess(data)
}

export async function POST(request: NextRequest, context: { params: { id: string } }) {
  const auth = await requireAdminApiContext(request)
  if (!auth.ok) return apiError(auth.error, auth.status)
  if (!auth.context.profile.is_super_admin) return apiError('Super admin required', 403)

  const body = await parseRequestBody(request)
  if (body._method === 'PUT') {
    return updateStaffByPayload(auth.context.userId, context.params.id, body)
  }

  return apiError('Method not allowed', 405)
}
