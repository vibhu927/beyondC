import { notFound } from 'next/navigation'
import { PermissionGate } from '@/components/admin/permission-gate'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Textarea } from '@/components/ui/textarea'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { createServiceClient } from '@/lib/supabase/service'

export default async function AdminUserDetailPage({ params }: { params: { id: string } }) {
  const service = createServiceClient()

  const { data: profile } = await service.from('profiles').select('*').eq('id', params.id).single()
  if (!profile) {
    notFound()
  }

  const [creatorProfile, brandProfile, bids, collabs, ratings, walletTx, creditTx] = await Promise.all([
    service.from('creator_profiles').select('*').eq('id', params.id).maybeSingle(),
    service.from('brand_profiles').select('*').eq('id', params.id).maybeSingle(),
    service.from('bids').select('*').eq('creator_id', params.id).order('created_at', { ascending: false }).limit(20),
    service
      .from('collabs')
      .select('*')
      .or(`creator_id.eq.${params.id},brand_id.eq.${params.id}`)
      .order('created_at', { ascending: false })
      .limit(20),
    service
      .from('ratings')
      .select('*')
      .or(`rated_by.eq.${params.id},rated_user.eq.${params.id}`)
      .order('created_at', { ascending: false })
      .limit(20),
    service.from('wallet_transactions').select('*').eq('creator_id', params.id).order('created_at', { ascending: false }).limit(20),
    service.from('credit_transactions').select('*').eq('brand_id', params.id).order('created_at', { ascending: false }).limit(20),
  ])

  return (
    <PermissionGate page="users" action="can_view">
      <div className="space-y-6">
        <Card>
          <CardHeader><CardTitle>User Profile</CardTitle></CardHeader>
          <CardContent className="grid grid-cols-1 gap-4 md:grid-cols-2">
            <div>
              <p className="text-sm text-zinc-500 dark:text-zinc-400">Name</p>
              <p className="font-semibold">{profile.full_name || '-'}</p>
            </div>
            <div>
              <p className="text-sm text-zinc-500 dark:text-zinc-400">Email</p>
              <p className="font-semibold">{profile.email}</p>
            </div>
            <div>
              <p className="text-sm text-zinc-500 dark:text-zinc-400">Role</p>
              <p className="font-semibold">{profile.role}</p>
            </div>
            <div>
              <p className="text-sm text-zinc-500 dark:text-zinc-400">Instagram Username</p>
              <p className="font-semibold">{creatorProfile.data?.instagram_username || '-'}</p>
            </div>
            <div>
              <p className="text-sm text-zinc-500 dark:text-zinc-400">Instagram Verified</p>
              <p className="font-semibold">{creatorProfile.data?.instagram_verified ? 'Yes' : 'No'}</p>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader><CardTitle>Moderation Actions</CardTitle></CardHeader>
          <CardContent className="grid grid-cols-1 gap-4 lg:grid-cols-2">
            <form action={`/api/admin/users/${params.id}/suspend`} method="post" className="space-y-2">
              <label className="text-sm font-medium">Suspend/Unsuspend Reason</label>
              <Textarea name="reason" placeholder="Reason for moderation action" />
              <Button variant="outline" type="submit">Toggle Suspension</Button>
            </form>

            {profile.role === 'creator' ? (
              <form action={`/api/admin/users/${params.id}/adjust-wallet`} method="post" className="space-y-2">
                <label className="text-sm font-medium">Manual Wallet Adjustment</label>
                <Input name="amount" type="number" placeholder="Use negative to deduct" required />
                <Textarea name="reason" placeholder="Reason" required />
                <Button type="submit">Update Wallet</Button>
              </form>
            ) : (
              <form action={`/api/admin/users/${params.id}/adjust-credits`} method="post" className="space-y-2">
                <label className="text-sm font-medium">Manual Credits Adjustment</label>
                <Input name="amount" type="number" placeholder="Use negative to deduct" required />
                <Textarea name="reason" placeholder="Reason" required />
                <Button type="submit">Update Credits</Button>
              </form>
            )}
          </CardContent>
        </Card>

        <Tabs defaultValue="collabs">
          <TabsList>
            <TabsTrigger value="bids">Bids</TabsTrigger>
            <TabsTrigger value="collabs">Collabs</TabsTrigger>
            <TabsTrigger value="ratings">Ratings</TabsTrigger>
            <TabsTrigger value="transactions">Transactions</TabsTrigger>
          </TabsList>

          <TabsContent value="bids">
            <Card>
              <CardContent className="pt-4 overflow-x-auto">
                <Table>
                  <TableHeader><TableRow><TableHead>ID</TableHead><TableHead>Status</TableHead><TableHead>Amount</TableHead><TableHead>Date</TableHead></TableRow></TableHeader>
                  <TableBody>
                    {(bids.data ?? []).map((row) => (
                      <TableRow key={row.id}><TableCell>{row.id}</TableCell><TableCell>{row.status}</TableCell><TableCell>{row.bid_amount || 0}</TableCell><TableCell>{new Date(row.created_at).toLocaleString()}</TableCell></TableRow>
                    ))}
                  </TableBody>
                </Table>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="collabs">
            <Card>
              <CardContent className="pt-4 overflow-x-auto">
                <Table>
                  <TableHeader><TableRow><TableHead>ID</TableHead><TableHead>Status</TableHead><TableHead>Amount</TableHead><TableHead>Started</TableHead></TableRow></TableHeader>
                  <TableBody>
                    {(collabs.data ?? []).map((row) => (
                      <TableRow key={row.id}><TableCell>{row.id}</TableCell><TableCell>{row.status}</TableCell><TableCell>{row.agreed_amount || 0}</TableCell><TableCell>{new Date(row.started_at || row.created_at).toLocaleString()}</TableCell></TableRow>
                    ))}
                  </TableBody>
                </Table>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="ratings">
            <Card>
              <CardContent className="pt-4 overflow-x-auto">
                <Table>
                  <TableHeader><TableRow><TableHead>Score</TableHead><TableHead>Review</TableHead><TableHead>Date</TableHead></TableRow></TableHeader>
                  <TableBody>
                    {(ratings.data ?? []).map((row) => (
                      <TableRow key={row.id}><TableCell>{row.score}</TableCell><TableCell>{row.review || '-'}</TableCell><TableCell>{new Date(row.created_at).toLocaleString()}</TableCell></TableRow>
                    ))}
                  </TableBody>
                </Table>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="transactions">
            <Card>
              <CardContent className="pt-4 overflow-x-auto space-y-4">
                {profile.role === 'creator' ? (
                  <Table>
                    <TableHeader><TableRow><TableHead>Type</TableHead><TableHead>Amount</TableHead><TableHead>Reason</TableHead><TableHead>Date</TableHead></TableRow></TableHeader>
                    <TableBody>
                      {(walletTx.data ?? []).map((row) => (
                        <TableRow key={row.id}><TableCell>{row.type}</TableCell><TableCell>{row.amount}</TableCell><TableCell>{row.reason}</TableCell><TableCell>{new Date(row.created_at).toLocaleString()}</TableCell></TableRow>
                      ))}
                    </TableBody>
                  </Table>
                ) : (
                  <Table>
                    <TableHeader><TableRow><TableHead>Type</TableHead><TableHead>Amount</TableHead><TableHead>Reason</TableHead><TableHead>Date</TableHead></TableRow></TableHeader>
                    <TableBody>
                      {(creditTx.data ?? []).map((row) => (
                        <TableRow key={row.id}><TableCell>{row.type}</TableCell><TableCell>{row.amount}</TableCell><TableCell>{row.reason}</TableCell><TableCell>{new Date(row.created_at).toLocaleString()}</TableCell></TableRow>
                      ))}
                    </TableBody>
                  </Table>
                )}
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </PermissionGate>
  )
}
