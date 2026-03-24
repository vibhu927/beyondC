import { PermissionGate } from '@/components/admin/permission-gate'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { createServiceClient } from '@/lib/supabase/service'

export default async function AdminNotificationsPage() {
  const service = createServiceClient()
  const { data: history } = await service
    .from('admin_logs')
    .select('id,action,details,admin_id,created_at')
    .eq('action', 'send_notification')
    .order('created_at', { ascending: false })
    .limit(20)

  return (
    <PermissionGate page="notifications" action="can_view">
      <div className="space-y-4">
        <Card>
          <CardHeader><CardTitle>Send Notification</CardTitle></CardHeader>
          <CardContent>
            <form action="/api/admin/notifications/send" method="post" className="space-y-3">
              <Input name="target" placeholder="all_users / all_creators / all_brands / user_id" required />
              <Input name="title" placeholder="Notification title" required />
              <Textarea name="body" placeholder="Notification message" required />
              <Button type="submit">Send Now</Button>
            </form>
          </CardContent>
        </Card>

        <Card>
          <CardHeader><CardTitle>Notification History</CardTitle></CardHeader>
          <CardContent className="overflow-x-auto">
            <Table>
              <TableHeader><TableRow><TableHead>Target</TableHead><TableHead>Title</TableHead><TableHead>Sent By</TableHead><TableHead>Sent At</TableHead><TableHead>Recipients</TableHead></TableRow></TableHeader>
              <TableBody>
                {(history ?? []).map((row) => (
                  <TableRow key={row.id}>
                    <TableCell>{String((row.details as any)?.target || '-')}</TableCell>
                    <TableCell>{String((row.details as any)?.title || '-')}</TableCell>
                    <TableCell>{row.admin_id}</TableCell>
                    <TableCell>{new Date(row.created_at).toLocaleString()}</TableCell>
                    <TableCell>{String((row.details as any)?.recipients_count || 0)}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      </div>
    </PermissionGate>
  )
}
