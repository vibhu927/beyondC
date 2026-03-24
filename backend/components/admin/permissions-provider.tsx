'use client'

import { createContext, useContext } from 'react'
import { PermissionAction, PermissionMap } from '@/lib/admin/constants'

type AdminIdentity = {
  id: string
  name: string
  email: string
  designation: string
  isSuperAdmin: boolean
}

type AdminPermissionContextValue = {
  permissions: PermissionMap
  identity: AdminIdentity
}

const AdminPermissionContext = createContext<AdminPermissionContextValue | null>(null)

export function AdminPermissionProvider({
  value,
  children,
}: {
  value: AdminPermissionContextValue
  children: React.ReactNode
}) {
  return <AdminPermissionContext.Provider value={value}>{children}</AdminPermissionContext.Provider>
}

export function useAdminPermissions() {
  const context = useContext(AdminPermissionContext)
  if (!context) {
    throw new Error('useAdminPermissions must be used within AdminPermissionProvider')
  }

  return context
}

export function canAccess(
  permissions: PermissionMap,
  isSuperAdmin: boolean,
  page: keyof PermissionMap,
  action: PermissionAction
) {
  if (isSuperAdmin) {
    return true
  }

  return Boolean(permissions[page]?.[action])
}
