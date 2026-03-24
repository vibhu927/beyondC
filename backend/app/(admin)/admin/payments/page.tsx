import { PermissionGate } from '@/components/admin/permission-gate'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { createServiceClient } from '@/lib/supabase/service'

export default async function AdminPaymentsPage() {
  const service = createServiceClient()
  const [credits, wallets] = await Promise.all([
    service.from('credit_transactions').select('*').order('created_at', { ascending: false }).limit(20),
    service.from('wallet_transactions').select('*').order('created_at', { ascending: false }).limit(20),
  ])

  const allCredit = credits.data ?? []
  const allWallet = wallets.data ?? []
  const all = [...allCredit, ...allWallet]

  const now = new Date()
  const todayRevenue = all
    .filter((row) => new Date(row.created_at).toDateString() === now.toDateString())
    .reduce((sum, row) => sum + (row.amount || 0), 0)
  const monthRevenue = all
    .filter((row) => {
      const date = new Date(row.created_at)
      return date.getMonth() === now.getMonth() && date.getFullYear() === now.getFullYear()
    })
    .reduce((sum, row) => sum + (row.amount || 0), 0)
  const totalRevenue = all.reduce((sum, row) => sum + (row.amount || 0), 0)

  return (
    <PermissionGate page="payments" action="can_view">
      <div className="space-y-6">
        <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
          <Card><CardHeader><CardTitle>Revenue Today</CardTitle></CardHeader><CardContent className="text-2xl font-bold">Rs {todayRevenue.toLocaleString()}</CardContent></Card>
          <Card><CardHeader><CardTitle>Revenue This Month</CardTitle></CardHeader><CardContent className="text-2xl font-bold">Rs {monthRevenue.toLocaleString()}</CardContent></Card>
          <Card><CardHeader><CardTitle>Revenue All Time</CardTitle></CardHeader><CardContent className="text-2xl font-bold">Rs {totalRevenue.toLocaleString()}</CardContent></Card>
        </div>

        <Card>
          <CardHeader><CardTitle>Payments</CardTitle></CardHeader>
          <CardContent>
            <Tabs defaultValue="credits">
              <TabsList>
                <TabsTrigger value="credits">Credit Purchases</TabsTrigger>
                <TabsTrigger value="wallet">Wallet Top-ups</TabsTrigger>
              </TabsList>

              <TabsContent value="credits">
                <div className="overflow-x-auto">
                  <Table>
                    <TableHeader><TableRow><TableHead>User</TableHead><TableHead>Amount</TableHead><TableHead>Credits</TableHead><TableHead>Razorpay ID</TableHead><TableHead>Status</TableHead><TableHead>Date</TableHead><TableHead>Actions</TableHead></TableRow></TableHeader>
                    <TableBody>
                      {allCredit.map((row) => {
                        const failed = !row.razorpay_payment_id
                        return (
                          <TableRow key={row.id} className={failed ? 'bg-red-50' : ''}>
                            <TableCell>{row.brand_id}</TableCell><TableCell>{row.amount}</TableCell><TableCell>{row.balance_after}</TableCell><TableCell>{row.razorpay_payment_id || '-'}</TableCell>
                            <TableCell><Badge className={failed ? 'border-red-300 text-red-700' : 'border-green-300 text-green-700'}>{failed ? 'failed' : 'success'}</Badge></TableCell>
                            <TableCell>{new Date(row.created_at).toLocaleString()}</TableCell>
                            <TableCell><form action="/api/admin/settings" method="post"><Button size="sm" variant="outline">Initiate Refund</Button></form></TableCell>
                          </TableRow>
                        )
                      })}
                    </TableBody>
                  </Table>
                </div>
              </TabsContent>

              <TabsContent value="wallet">
                <div className="overflow-x-auto">
                  <Table>
                    <TableHeader><TableRow><TableHead>User</TableHead><TableHead>Amount</TableHead><TableHead>Balance</TableHead><TableHead>Razorpay ID</TableHead><TableHead>Status</TableHead><TableHead>Date</TableHead></TableRow></TableHeader>
                    <TableBody>
                      {allWallet.map((row) => {
                        const failed = !row.razorpay_payment_id
                        return (
                          <TableRow key={row.id} className={failed ? 'bg-red-50' : ''}>
                            <TableCell>{row.creator_id}</TableCell><TableCell>{row.amount}</TableCell><TableCell>{row.balance_after}</TableCell><TableCell>{row.razorpay_payment_id || '-'}</TableCell>
                            <TableCell><Badge className={failed ? 'border-red-300 text-red-700' : 'border-green-300 text-green-700'}>{failed ? 'failed' : 'success'}</Badge></TableCell>
                            <TableCell>{new Date(row.created_at).toLocaleString()}</TableCell>
                          </TableRow>
                        )
                      })}
                    </TableBody>
                  </Table>
                </div>
              </TabsContent>
            </Tabs>
          </CardContent>
        </Card>
      </div>
    </PermissionGate>
  )
}
