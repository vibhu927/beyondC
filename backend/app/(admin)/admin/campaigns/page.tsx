import Link from 'next/link'
import { PermissionGate } from '@/components/admin/permission-gate'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { createServiceClient } from '@/lib/supabase/service'

const PAGE_SIZE = 20
export const dynamic = 'force-dynamic'

export default async function AdminCampaignsPage({ searchParams }: { searchParams: { q?: string; page?: string; status?: string } }) {
  const q = searchParams.q ?? ''
  const status = searchParams.status ?? ''
  const page = Number(searchParams.page ?? '1') || 1
  const from = (page - 1) * PAGE_SIZE
  const to = from + PAGE_SIZE - 1

  const service = createServiceClient()
  let query = service
    .from('campaigns')
    .select('id,title,brand_id,niche,collab_type,budget_min,budget_max,status,created_at,bids(count)', { count: 'exact' })
    .order('created_at', { ascending: false })
    .range(from, to)

  if (q) query = query.ilike('title', `%${q}%`)
  if (status) query = query.eq('status', status)

  const { data, count, error } = await query

  return (
    <PermissionGate page="campaigns" action="can_view">
      <Card>
        <CardHeader>
          <CardTitle>Campaigns</CardTitle>
          <form className="mt-3 flex flex-wrap gap-2">
            <Input name="q" defaultValue={q} placeholder="Search title" className="max-w-xs" />
            <Input name="status" defaultValue={status} placeholder="Status: active/paused/cancelled" className="max-w-xs" />
            <Button variant="outline" type="submit">Apply</Button>
          </form>
        </CardHeader>
        <CardContent className="overflow-x-auto">
          {error && (
            <p className="mb-3 text-sm text-red-600">Could not load campaigns: {error.message}</p>
          )}

          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Title</TableHead><TableHead>Brand</TableHead><TableHead>Niche</TableHead><TableHead>Type</TableHead><TableHead>Budget</TableHead><TableHead>Bids</TableHead><TableHead>Status</TableHead><TableHead>Created</TableHead><TableHead>Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {(data ?? []).map((row: any) => (
                <TableRow key={row.id}>
                  <TableCell>{row.title}</TableCell>
                  <TableCell>{row.brand_id}</TableCell>
                  <TableCell>{Array.isArray(row.niche) ? row.niche.join(', ') : '-'}</TableCell>
                  <TableCell>{row.collab_type}</TableCell>
                  <TableCell>{row.budget_min || 0} - {row.budget_max || 0}</TableCell>
                  <TableCell>{row.bids?.[0]?.count || 0}</TableCell>
                  <TableCell>{row.status}</TableCell>
                  <TableCell>{new Date(row.created_at).toLocaleDateString()}</TableCell>
                  <TableCell>
                    <div className="flex gap-2">
                      <Link href={`/admin/campaigns/${row.id}`}><Button size="sm" variant="outline">View</Button></Link>
                      <form action={`/api/admin/campaigns/${row.id}/pause`} method="post"><Button size="sm" variant="outline">Pause</Button></form>
                      <form action={`/api/admin/campaigns/${row.id}/cancel`} method="post"><Button size="sm" variant="outline">Cancel</Button></form>
                    </div>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>

          <div className="mt-4 flex items-center justify-between text-sm text-zinc-600 dark:text-zinc-400">
            <p>Total: {count ?? 0}</p>
            <div className="flex gap-2">
              {page > 1 && <Link href={`/admin/campaigns?page=${page - 1}&q=${encodeURIComponent(q)}&status=${encodeURIComponent(status)}`}><Button variant="outline" size="sm">Previous</Button></Link>}
              <Link href={`/admin/campaigns?page=${page + 1}&q=${encodeURIComponent(q)}&status=${encodeURIComponent(status)}`}><Button variant="outline" size="sm">Next</Button></Link>
            </div>
          </div>
        </CardContent>
      </Card>
    </PermissionGate>
  )
}
