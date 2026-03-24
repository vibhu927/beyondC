import { notFound } from 'next/navigation'
import { PermissionGate } from '@/components/admin/permission-gate'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { createServiceClient } from '@/lib/supabase/service'

export default async function AdminEventDetailPage({ params }: { params: { id: string } }) {
  const service = createServiceClient()
  const { data: event } = await service.from('events').select('*').eq('id', params.id).single()
  if (!event) notFound()

  const { data: invites } = await service
    .from('event_invites')
    .select('id,creator_id,status,ticket_code,created_at')
    .eq('event_id', params.id)
    .order('created_at', { ascending: false })

  return (
    <PermissionGate page="events" action="can_view">
      <div className="space-y-4">
        <Card>
          <CardHeader><CardTitle>{event.title}</CardTitle></CardHeader>
          <CardContent className="grid grid-cols-1 gap-3 md:grid-cols-2">
            <p><span className="text-zinc-500 dark:text-zinc-400">Brand:</span> {event.brand_id}</p>
            <p><span className="text-zinc-500 dark:text-zinc-400">Type:</span> {event.event_type}</p>
            <p><span className="text-zinc-500 dark:text-zinc-400">Date:</span> {new Date(event.event_date).toLocaleString()}</p>
            <p><span className="text-zinc-500 dark:text-zinc-400">City:</span> {event.city || '-'}</p>
            <p><span className="text-zinc-500 dark:text-zinc-400">Slots:</span> {event.slots_filled}/{event.total_slots}</p>
            <p><span className="text-zinc-500 dark:text-zinc-400">Status:</span> {event.status}</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader><CardTitle>Invite List</CardTitle></CardHeader>
          <CardContent className="overflow-x-auto">
            <Table>
              <TableHeader><TableRow><TableHead>Creator</TableHead><TableHead>Status</TableHead><TableHead>Ticket</TableHead><TableHead>Invited</TableHead></TableRow></TableHeader>
              <TableBody>
                {(invites ?? []).map((invite) => (
                  <TableRow key={invite.id}><TableCell>{invite.creator_id}</TableCell><TableCell>{invite.status}</TableCell><TableCell>{invite.ticket_code || '-'}</TableCell><TableCell>{new Date(invite.created_at).toLocaleString()}</TableCell></TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      </div>
    </PermissionGate>
  )
}
