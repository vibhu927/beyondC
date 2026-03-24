import Link from 'next/link'
import { PermissionGate } from '@/components/admin/permission-gate'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { createServiceClient } from '@/lib/supabase/service'

export default async function AdminDisputesPage() {
  const service = createServiceClient()
  const { data } = await service
    .from('collabs')
    .select('id,creator_id,brand_id,status,created_at')
    .eq('status', 'disputed')
    .order('created_at', { ascending: false })
    .limit(20)

  return (
    <PermissionGate page="disputes" action="can_view">
      <Card>
        <CardHeader><CardTitle>Disputes</CardTitle></CardHeader>
        <CardContent className="overflow-x-auto">
          <Table>
            <TableHeader><TableRow><TableHead>Collab ID</TableHead><TableHead>Creator</TableHead><TableHead>Brand</TableHead><TableHead>Status</TableHead><TableHead>Created</TableHead><TableHead>Actions</TableHead></TableRow></TableHeader>
            <TableBody>
              {(data ?? []).map((row) => (
                <TableRow key={row.id}>
                  <TableCell>{row.id}</TableCell><TableCell>{row.creator_id}</TableCell><TableCell>{row.brand_id}</TableCell><TableCell>{row.status}</TableCell><TableCell>{new Date(row.created_at).toLocaleString()}</TableCell>
                  <TableCell><div className="flex gap-2"><Link href={`/admin/disputes/${row.id}`}><Button size="sm" variant="outline">View</Button></Link><form action={`/api/admin/collabs/${row.id}/resolve`} method="post"><Button name="resolution" value="mutual" size="sm" variant="outline">Resolve</Button></form></div></TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </PermissionGate>
  )
}
