import Link from 'next/link'
import { PermissionGate } from '@/components/admin/permission-gate'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { createServiceClient } from '@/lib/supabase/service'

const PAGE_SIZE = 20
export const dynamic = 'force-dynamic'

export default async function AdminEventsPage({ searchParams }: { searchParams: { page?: string } }) {
  const page = Number(searchParams.page ?? '1') || 1
  const from = (page - 1) * PAGE_SIZE
  const to = from + PAGE_SIZE - 1
  const service = createServiceClient()

  const { data, count, error } = await service
    .from('events')
    .select('id,title,brand_id,event_type,event_date,city,total_slots,slots_filled,status', { count: 'exact' })
    .order('event_date', { ascending: false })
    .range(from, to)

  return (
    <PermissionGate page="events" action="can_view">
      <Card>
        <CardHeader><CardTitle>Events</CardTitle></CardHeader>
        <CardContent className="overflow-x-auto">
          {error && (
            <p className="mb-3 text-sm text-red-600">Could not load events: {error.message}</p>
          )}

          <Table>
            <TableHeader><TableRow><TableHead>Event Name</TableHead><TableHead>Brand</TableHead><TableHead>Type</TableHead><TableHead>Date</TableHead><TableHead>City</TableHead><TableHead>Slots</TableHead><TableHead>Status</TableHead><TableHead>Actions</TableHead></TableRow></TableHeader>
            <TableBody>
              {(data ?? []).map((row) => (
                <TableRow key={row.id}>
                  <TableCell>{row.title}</TableCell><TableCell>{row.brand_id}</TableCell><TableCell>{row.event_type || '-'}</TableCell><TableCell>{new Date(row.event_date).toLocaleDateString()}</TableCell><TableCell>{row.city || '-'}</TableCell><TableCell>{row.slots_filled}/{row.total_slots}</TableCell><TableCell>{row.status}</TableCell>
                  <TableCell><div className="flex gap-2"><Link href={`/admin/events/${row.id}`}><Button size="sm" variant="outline">View</Button></Link><form action={`/api/admin/events/${row.id}/cancel`} method="post"><Button size="sm" variant="outline">Cancel</Button></form></div></TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
          <div className="mt-4 flex items-center justify-between text-sm text-zinc-600 dark:text-zinc-400"><p>Total: {count ?? 0}</p><div className="flex gap-2">{page > 1 && <Link href={`/admin/events?page=${page - 1}`}><Button size="sm" variant="outline">Previous</Button></Link>}<Link href={`/admin/events?page=${page + 1}`}><Button size="sm" variant="outline">Next</Button></Link></div></div>
        </CardContent>
      </Card>
    </PermissionGate>
  )
}
