import { PermissionGate } from '@/components/admin/permission-gate'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Textarea } from '@/components/ui/textarea'
import { createServiceClient } from '@/lib/supabase/service'

type PageProps = {
  searchParams?: {
    success?: string
    error?: string
  }
}

export default async function AdminWalletsPage({ searchParams }: PageProps) {
  const service = createServiceClient()

  const [creatorsRes, brandsRes, profilesRes, recentCreatorTopupsRes, recentBrandTopupsRes] =
    await Promise.all([
      service
        .from('creator_profiles')
        .select('id,wallet_balance')
        .order('updated_at', { ascending: false })
        .limit(100),
      service
        .from('brand_profiles')
        .select('id,credit_balance')
        .order('updated_at', { ascending: false })
        .limit(100),
      service.from('profiles').select('id,full_name,email'),
      service
        .from('wallet_transactions')
        .select('id,creator_id,amount,balance_after,reason,created_at')
        .eq('reason', 'admin_manual_topup')
        .order('created_at', { ascending: false })
        .limit(10),
      service
        .from('credit_transactions')
        .select('id,brand_id,amount,balance_after,reason,created_at')
        .eq('reason', 'admin_manual_topup')
        .order('created_at', { ascending: false })
        .limit(10),
    ])

  const profileById = new Map((profilesRes.data ?? []).map((profile) => [profile.id, profile]))
  const creators = creatorsRes.data ?? []
  const brands = brandsRes.data ?? []

  return (
    <PermissionGate page="payments" action="can_edit">
      <div className="space-y-6">
        {searchParams?.success ? (
          <div className="rounded-md border border-emerald-200 bg-emerald-50 p-3 text-sm text-emerald-800">
            {searchParams.success}
          </div>
        ) : null}

        {searchParams?.error ? (
          <div className="rounded-md border border-red-200 bg-red-50 p-3 text-sm text-red-700">
            {searchParams.error}
          </div>
        ) : null}

        <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
          <Card>
            <CardHeader>
              <CardTitle>Top Up Creator Wallet</CardTitle>
            </CardHeader>
            <CardContent>
              <form action="/api/admin/wallets/manual-topup" method="post" className="space-y-4">
                <input type="hidden" name="targetType" value="creator" />

                <div className="space-y-2">
                  <label htmlFor="creator-id" className="text-sm font-medium">
                    Creator
                  </label>
                  <select
                    id="creator-id"
                    name="targetId"
                    required
                    className="h-10 w-full rounded-md border border-zinc-200 bg-white px-3 text-sm dark:border-zinc-700 dark:bg-zinc-900"
                  >
                    <option value="">Select creator</option>
                    {creators.map((creator) => {
                      const profile = profileById.get(creator.id)
                      const name = profile?.full_name || 'Unnamed creator'
                      const email = profile?.email || creator.id
                      return (
                        <option key={creator.id} value={creator.id}>
                          {name} ({email}) - Wallet: Rs {(creator.wallet_balance ?? 0).toLocaleString()}
                        </option>
                      )
                    })}
                  </select>
                </div>

                <div className="space-y-2">
                  <label htmlFor="creator-amount" className="text-sm font-medium">
                    Amount
                  </label>
                  <Input id="creator-amount" name="amount" type="number" min="1" step="1" required />
                </div>

                <div className="space-y-2">
                  <label htmlFor="creator-reason" className="text-sm font-medium">
                    Reason
                  </label>
                  <Textarea
                    id="creator-reason"
                    name="reason"
                    placeholder="admin_manual_topup"
                    defaultValue="admin_manual_topup"
                  />
                </div>

                <Button type="submit">Add To Wallet</Button>
              </form>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Add Credits To Brand</CardTitle>
            </CardHeader>
            <CardContent>
              <form action="/api/admin/wallets/manual-topup" method="post" className="space-y-4">
                <input type="hidden" name="targetType" value="brand" />

                <div className="space-y-2">
                  <label htmlFor="brand-id" className="text-sm font-medium">
                    Brand
                  </label>
                  <select
                    id="brand-id"
                    name="targetId"
                    required
                    className="h-10 w-full rounded-md border border-zinc-200 bg-white px-3 text-sm dark:border-zinc-700 dark:bg-zinc-900"
                  >
                    <option value="">Select brand</option>
                    {brands.map((brand) => {
                      const profile = profileById.get(brand.id)
                      const name = profile?.full_name || 'Unnamed brand'
                      const email = profile?.email || brand.id
                      return (
                        <option key={brand.id} value={brand.id}>
                          {name} ({email}) - Credits: {(brand.credit_balance ?? 0).toLocaleString()}
                        </option>
                      )
                    })}
                  </select>
                </div>

                <div className="space-y-2">
                  <label htmlFor="brand-amount" className="text-sm font-medium">
                    Credits
                  </label>
                  <Input id="brand-amount" name="amount" type="number" min="1" step="1" required />
                </div>

                <div className="space-y-2">
                  <label htmlFor="brand-reason" className="text-sm font-medium">
                    Reason
                  </label>
                  <Textarea
                    id="brand-reason"
                    name="reason"
                    placeholder="admin_manual_topup"
                    defaultValue="admin_manual_topup"
                  />
                </div>

                <Button type="submit">Add Credits</Button>
              </form>
            </CardContent>
          </Card>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>Recent Manual Top-ups</CardTitle>
          </CardHeader>
          <CardContent className="space-y-6">
            <div>
              <h3 className="mb-2 text-sm font-semibold">Creator Wallet Top-ups</h3>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Creator</TableHead>
                    <TableHead>Amount</TableHead>
                    <TableHead>Balance After</TableHead>
                    <TableHead>Date</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {(recentCreatorTopupsRes.data ?? []).map((row) => {
                    const profile = profileById.get(row.creator_id)
                    const name = profile?.full_name || row.creator_id
                    return (
                      <TableRow key={row.id}>
                        <TableCell>{name}</TableCell>
                        <TableCell>Rs {(row.amount ?? 0).toLocaleString()}</TableCell>
                        <TableCell>Rs {(row.balance_after ?? 0).toLocaleString()}</TableCell>
                        <TableCell>{new Date(row.created_at).toLocaleString()}</TableCell>
                      </TableRow>
                    )
                  })}
                </TableBody>
              </Table>
            </div>

            <div>
              <h3 className="mb-2 text-sm font-semibold">Brand Credit Top-ups</h3>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Brand</TableHead>
                    <TableHead>Credits Added</TableHead>
                    <TableHead>Balance After</TableHead>
                    <TableHead>Date</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {(recentBrandTopupsRes.data ?? []).map((row) => {
                    const profile = profileById.get(row.brand_id)
                    const name = profile?.full_name || row.brand_id
                    return (
                      <TableRow key={row.id}>
                        <TableCell>{name}</TableCell>
                        <TableCell>{(row.amount ?? 0).toLocaleString()}</TableCell>
                        <TableCell>{(row.balance_after ?? 0).toLocaleString()}</TableCell>
                        <TableCell>{new Date(row.created_at).toLocaleString()}</TableCell>
                      </TableRow>
                    )
                  })}
                </TableBody>
              </Table>
            </div>
          </CardContent>
        </Card>
      </div>
    </PermissionGate>
  )
}
