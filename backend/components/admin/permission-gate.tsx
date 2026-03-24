'use client'

import { PermissionAction, PermissionMap } from '@/lib/admin/constants'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { useAdminPermissions, canAccess } from '@/components/admin/permissions-provider'

export function PermissionGate({
  page,
  action,
  children,
}: {
  page: keyof PermissionMap
  action: PermissionAction
  children: React.ReactNode
}) {
  const { permissions, identity } = useAdminPermissions()

  if (!canAccess(permissions, identity.isSuperAdmin, page, action)) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Access Denied</CardTitle>
        </CardHeader>
        <CardContent>
          You do not have permission to perform this action. Please contact a super admin.
        </CardContent>
      </Card>
    )
  }

  return <>{children}</>
}
