import { redirect } from 'next/navigation'
import { getCurrentAdminContext } from '@/lib/admin/auth'
import { getAdminPermissions } from '@/lib/admin/permissions'
import { createServiceClient } from '@/lib/supabase/service'
import { AdminPermissionProvider } from '@/components/admin/permissions-provider'
import { AdminShell } from '@/components/admin/admin-shell'

export default async function AdminGroupLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const context = await getCurrentAdminContext()

  if (!context) {
    redirect('/admin/login')
  }

  const permissions = await getAdminPermissions({
    userId: context.userId,
    isSuperAdmin: context.profile.is_super_admin,
  })

  const service = createServiceClient()
  const { data: staff } = await service
    .from('admin_staff')
    .select('designation,admin_roles(designation)')
    .eq('id', context.userId)
    .maybeSingle()

  const derivedDesignation =
    (staff?.designation as string | null) ||
    (staff?.admin_roles as { designation?: string } | null)?.designation ||
    (context.profile.is_super_admin ? 'Super Admin' : 'Admin Staff')

  return (
    <AdminPermissionProvider
      value={{
        permissions,
        identity: {
          id: context.userId,
          name: context.profile.full_name || context.profile.first_name || 'Admin',
          email: context.profile.email,
          designation: derivedDesignation,
          isSuperAdmin: context.profile.is_super_admin,
        },
      }}
    >
      <AdminShell>{children}</AdminShell>
    </AdminPermissionProvider>
  )
}
