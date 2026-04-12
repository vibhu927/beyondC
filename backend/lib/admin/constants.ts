export const ADMIN_PAGES = [
  'dashboard',
  'users',
  'campaigns',
  'collabs',
  'events',
  'payments',
  'disputes',
  'notifications',
  'carousels',
  'settings',
  'analytics',
  'staff',
] as const

export type AdminPage = (typeof ADMIN_PAGES)[number]

export type PermissionAction = 'can_view' | 'can_edit' | 'can_delete'

export type PermissionMap = Record<AdminPage, Record<PermissionAction, boolean>>

export function buildDefaultPermissionMap(): PermissionMap {
  return ADMIN_PAGES.reduce((acc, page) => {
    acc[page] = {
      can_view: false,
      can_edit: false,
      can_delete: false,
    }
    return acc
  }, {} as PermissionMap)
}
