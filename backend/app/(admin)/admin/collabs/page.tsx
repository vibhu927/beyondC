import Link from 'next/link'
import { PermissionGate } from '@/components/admin/permission-gate'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { createServiceClient } from '@/lib/supabase/service'

const PAGE_SIZE = 20
export const dynamic = 'force-dynamic'

export default async function AdminCollabsPage({ searchParams }: { searchParams: { status?: string; page?: string } }) {
  const status = searchParams.status ?? ''
  const page = Number(searchParams.page ?? '1') || 1
  const from = (page - 1) * PAGE_SIZE
  const to = from + PAGE_SIZE - 1

  const service = createServiceClient()
  let query = service
    .from('collabs')
    .select('id,creator_id,brand_id,agreed_amount,status,created_at,started_at', { count: 'exact' })
    .order('created_at', { ascending: false })
    .range(from, to)

  if (status) query = query.eq('status', status)
  const { data, count, error } = await query

  return (
    <PermissionGate page="collabs" action="can_view">
      <Card>
        <CardHeader>
          <CardTitle>Collabs</CardTitle>
          <form className="mt-3 flex gap-2"><Input name="status" defaultValue={status} placeholder="Filter by status" className="max-w-xs" /><Button variant="outline">Apply</Button></form>
        </CardHeader>
        <CardContent className="overflow-x-auto">
          {error && (
            <p className="mb-3 text-sm text-red-600">Could not load collabs: {error.message}</p>
          )}

          <Table>
            <TableHeader><TableRow><TableHead>ID</TableHead><TableHead>Creator</TableHead><TableHead>Brand</TableHead><TableHead>Amount</TableHead><TableHead>Status</TableHead><TableHead>Started</TableHead><TableHead>Actions</TableHead></TableRow></TableHeader>
            <TableBody>
              {(data ?? []).map((row) => (
                <TableRow key={row.id}>
                  <TableCell>{row.id}</TableCell>
                  <TableCell>{row.creator_id}</TableCell>
                  <TableCell>{row.brand_id}</TableCell>
                  <TableCell>{row.agreed_amount || 0}</TableCell>
                  <TableCell>{row.status}</TableCell>
                  <TableCell>{new Date(row.started_at || row.created_at).toLocaleDateString()}</TableCell>
                  <TableCell>
                    <div className="flex gap-2">
                      <Link href={`/admin/collabs/${row.id}`}><Button size="sm" variant="outline">View</Button></Link>
                      <form action={`/api/admin/collabs/${row.id}/dispute`} method="post"><Button size="sm" variant="outline">Mark Disputed</Button></form>
                    </div>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
          <div className="mt-4 flex items-center justify-between text-sm text-zinc-600 dark:text-zinc-400"><p>Total: {count ?? 0}</p><div className="flex gap-2">{page > 1 && <Link href={`/admin/collabs?page=${page - 1}&status=${encodeURIComponent(status)}`}><Button size="sm" variant="outline">Previous</Button></Link>}<Link href={`/admin/collabs?page=${page + 1}&status=${encodeURIComponent(status)}`}><Button size="sm" variant="outline">Next</Button></Link></div></div>
        </CardContent>
      </Card>
    </PermissionGate>
  )
}
