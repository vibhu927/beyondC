import { ADMIN_PAGES, buildDefaultPermissionMap, PermissionAction, PermissionMap } from '@/lib/admin/constants'
import { createServiceClient } from '@/lib/supabase/service'

type AdminStaffRow = {
  role_id: string | null
  is_active: boolean
}

type AdminPermissionRow = {
  page: string
  can_view: boolean
  can_edit: boolean
  can_delete: boolean
}

export async function getAdminPermissions(params: {
  userId: string
  isSuperAdmin?: boolean
}): Promise<PermissionMap> {
  const permissionMap = buildDefaultPermissionMap()

  if (params.isSuperAdmin) {
    ADMIN_PAGES.forEach((page) => {
      permissionMap[page] = {
        can_view: true,
        can_edit: true,
        can_delete: true,
      }
    })
    return permissionMap
  }

  const service = createServiceClient()
  const { data: staffRow } = await service
    .from('admin_staff')
    .select('role_id,is_active')
    .eq('id', params.userId)
    .single<AdminStaffRow>()

  if (!staffRow || !staffRow.role_id || !staffRow.is_active) {
    return permissionMap
  }

  const { data: rows } = await service
    .from('admin_permissions')
    .select('page,can_view,can_edit,can_delete')
    .eq('role_id', staffRow.role_id)
    .returns<AdminPermissionRow[]>()

  rows?.forEach((row) => {
    if (ADMIN_PAGES.includes(row.page as any)) {
      permissionMap[row.page as keyof PermissionMap] = {
        can_view: row.can_view,
        can_edit: row.can_edit,
        can_delete: row.can_delete,
      }
    }
  })

  return permissionMap
}

export function hasPermission(
  permissionMap: PermissionMap,
  page: keyof PermissionMap,
  action: PermissionAction
) {
  return Boolean(permissionMap[page]?.[action])
}
