import { redirect } from 'next/navigation'
import { getDashboardUser } from '@/lib/dashboard/auth'
import DashboardLayout from '@/components/dashboard/dashboard-layout'
import { QueryProvider } from '@/components/providers/query-provider'

export default async function DashboardGroupLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const user = await getDashboardUser()

  if (!user) {
    redirect('/login')
  }

  return (
    <QueryProvider>
      <DashboardLayout>{children}</DashboardLayout>
    </QueryProvider>
  )
}
