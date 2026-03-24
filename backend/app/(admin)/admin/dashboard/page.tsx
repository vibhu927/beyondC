import { PermissionGate } from '@/components/admin/permission-gate'
import { AdminLineChart, AdminBarChart, AdminPieChart } from '@/components/admin/charts'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { createServiceClient } from '@/lib/supabase/service'

function toDayLabel(input: string) {
  const date = new Date(input)
  return `${date.getDate()}/${date.getMonth() + 1}`
}

export default async function AdminDashboardPage() {
  const service = createServiceClient()

  const [
    usersCount,
    collabCount,
    campaignsCount,
    pendingDisputes,
    suspendedUsers,
    recentLogs,
    creators,
    brands,
    collabs,
    creditTx,
    walletTx,
  ] = await Promise.all([
    service.from('profiles').select('*', { count: 'exact', head: true }),
    service.from('collabs').select('*', { count: 'exact', head: true }),
    service.from('campaigns').select('*', { count: 'exact', head: true }).eq('status', 'active'),
    service.from('collabs').select('*', { count: 'exact', head: true }).eq('status', 'disputed'),
    service.from('profiles').select('*', { count: 'exact', head: true }).eq('is_suspended', true),
    service
      .from('admin_logs')
      .select('id,action,target_type,created_at,admin_id')
      .order('created_at', { ascending: false })
      .limit(10),
    service
      .from('profiles')
      .select('created_at')
      .eq('role', 'creator')
      .gte('created_at', new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString())
      .order('created_at', { ascending: true }),
    service
      .from('profiles')
      .select('created_at')
      .eq('role', 'brand')
      .gte('created_at', new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString())
      .order('created_at', { ascending: true }),
    service
      .from('collabs')
      .select('created_at,agreed_amount,status')
      .gte('created_at', new Date(Date.now() - 180 * 24 * 60 * 60 * 1000).toISOString()),
    service.from('credit_transactions').select('amount,created_at,razorpay_payment_id'),
    service.from('wallet_transactions').select('amount,created_at,razorpay_payment_id'),
  ])

  const totalRevenueThisMonth = [...(creditTx.data ?? []), ...(walletTx.data ?? [])]
    .filter((tx) => {
      const date = new Date(tx.created_at)
      const now = new Date()
      return date.getMonth() === now.getMonth() && date.getFullYear() === now.getFullYear()
    })
    .reduce((sum, tx) => sum + (tx.amount ?? 0), 0)

  const signupMap = new Map<string, { creators: number; brands: number }>()
  ;[...(creators.data ?? [])].forEach((row) => {
    const label = toDayLabel(row.created_at)
    const current = signupMap.get(label) ?? { creators: 0, brands: 0 }
    signupMap.set(label, { ...current, creators: current.creators + 1 })
  })
  ;[...(brands.data ?? [])].forEach((row) => {
    const label = toDayLabel(row.created_at)
    const current = signupMap.get(label) ?? { creators: 0, brands: 0 }
    signupMap.set(label, { ...current, brands: current.brands + 1 })
  })
  const signupData = Array.from(signupMap.entries()).map(([label, value]) => ({ label, ...value }))

  const revenueByMonthMap = new Map<string, number>()
  ;[...(collabs.data ?? [])].forEach((row) => {
    const date = new Date(row.created_at)
    const key = `${date.toLocaleString('default', { month: 'short' })} ${String(date.getFullYear()).slice(-2)}`
    const amount = Number(row.agreed_amount ?? 0)
    revenueByMonthMap.set(key, (revenueByMonthMap.get(key) ?? 0) + amount)
  })
  const revenueByMonth = Array.from(revenueByMonthMap.entries()).map(([label, revenue]) => ({ label, revenue }))

  const { data: creatorTierRows } = await service.from('creator_profiles').select('tier')
  const tierMap = new Map<string, number>()
  ;(creatorTierRows ?? []).forEach((row) => {
    const tier = row.tier ?? 'unknown'
    tierMap.set(tier, (tierMap.get(tier) ?? 0) + 1)
  })
  const tierData = Array.from(tierMap.entries()).map(([name, value]) => ({ name, value }))

  const failedPaymentsCount = [...(creditTx.data ?? []), ...(walletTx.data ?? [])].filter(
    (tx) => !tx.razorpay_payment_id
  ).length

  return (
    <PermissionGate page="dashboard" action="can_view">
      <div className="space-y-6">
        <div className="grid grid-cols-1 gap-4 md:grid-cols-2 xl:grid-cols-4">
          <Card><CardHeader><CardTitle>Total Users</CardTitle></CardHeader><CardContent className="text-2xl font-bold">{usersCount.count ?? 0}</CardContent></Card>
          <Card><CardHeader><CardTitle>Total Collabs</CardTitle></CardHeader><CardContent className="text-2xl font-bold">{collabCount.count ?? 0}</CardContent></Card>
          <Card><CardHeader><CardTitle>Revenue This Month</CardTitle></CardHeader><CardContent className="text-2xl font-bold">Rs {totalRevenueThisMonth.toLocaleString()}</CardContent></Card>
          <Card><CardHeader><CardTitle>Active Campaigns</CardTitle></CardHeader><CardContent className="text-2xl font-bold">{campaignsCount.count ?? 0}</CardContent></Card>
        </div>

        <div className="grid grid-cols-1 gap-4 xl:grid-cols-2">
          <Card>
            <CardHeader><CardTitle>New Signups (Last 30 Days)</CardTitle></CardHeader>
            <CardContent>
              <AdminLineChart
                data={signupData}
                lines={[
                  { key: 'creators', color: '#84cc16', name: 'Creators' },
                  { key: 'brands', color: '#0ea5e9', name: 'Brands' },
                ]}
              />
            </CardContent>
          </Card>
          <Card>
            <CardHeader><CardTitle>Revenue Per Month</CardTitle></CardHeader>
            <CardContent><AdminBarChart data={revenueByMonth} keyName="revenue" /></CardContent>
          </Card>
        </div>

        <div className="grid grid-cols-1 gap-4 xl:grid-cols-3">
          <Card className="xl:col-span-2">
            <CardHeader><CardTitle>Recent Admin Activity</CardTitle></CardHeader>
            <CardContent>
              <div className="overflow-x-auto">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Action</TableHead>
                      <TableHead>Target</TableHead>
                      <TableHead>Admin</TableHead>
                      <TableHead>Time</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {(recentLogs.data ?? []).map((row) => (
                      <TableRow key={row.id}>
                        <TableCell>{row.action}</TableCell>
                        <TableCell>{row.target_type ?? '-'}</TableCell>
                        <TableCell>{row.admin_id}</TableCell>
                        <TableCell>{new Date(row.created_at).toLocaleString()}</TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader><CardTitle>Creator Tier Distribution</CardTitle></CardHeader>
            <CardContent><AdminPieChart data={tierData} dataKey="value" /></CardContent>
          </Card>
        </div>

        <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
          <Card><CardHeader><CardTitle>Pending Disputes</CardTitle></CardHeader><CardContent className="text-2xl font-bold text-amber-600">{pendingDisputes.count ?? 0}</CardContent></Card>
          <Card><CardHeader><CardTitle>Failed Payments</CardTitle></CardHeader><CardContent className="text-2xl font-bold text-red-600">{failedPaymentsCount}</CardContent></Card>
          <Card><CardHeader><CardTitle>Suspended Users</CardTitle></CardHeader><CardContent className="text-2xl font-bold">{suspendedUsers.count ?? 0}</CardContent></Card>
        </div>
      </div>
    </PermissionGate>
  )
}
