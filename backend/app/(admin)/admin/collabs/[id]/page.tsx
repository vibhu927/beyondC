import { notFound } from 'next/navigation'
import { PermissionGate } from '@/components/admin/permission-gate'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Textarea } from '@/components/ui/textarea'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { createServiceClient } from '@/lib/supabase/service'

export default async function AdminCollabDetailPage({ params }: { params: { id: string } }) {
  const service = createServiceClient()
  const { data: collab } = await service.from('collabs').select('*').eq('id', params.id).single()
  if (!collab) notFound()

  const [messages, creator, brand] = await Promise.all([
    service.from('messages').select('id,sender_id,content,created_at').eq('collab_id', params.id).order('created_at', { ascending: false }).limit(20),
    service.from('profiles').select('id,full_name,email').eq('id', collab.creator_id).maybeSingle(),
    service.from('profiles').select('id,full_name,email').eq('id', collab.brand_id).maybeSingle(),
  ])

  return (
    <PermissionGate page="collabs" action="can_view">
      <div className="space-y-4">
        <Card>
          <CardHeader><CardTitle>Collab {collab.id}</CardTitle></CardHeader>
          <CardContent className="grid grid-cols-1 gap-3 md:grid-cols-2">
            <p><span className="text-zinc-500 dark:text-zinc-400">Creator:</span> {creator.data?.full_name || collab.creator_id}</p>
            <p><span className="text-zinc-500 dark:text-zinc-400">Brand:</span> {brand.data?.full_name || collab.brand_id}</p>
            <p><span className="text-zinc-500 dark:text-zinc-400">Amount:</span> {collab.agreed_amount || 0}</p>
            <p><span className="text-zinc-500 dark:text-zinc-400">Status:</span> {collab.status}</p>
            <p><span className="text-zinc-500 dark:text-zinc-400">Milestones:</span> brief {String(collab.brief_shared)}, draft {String(collab.draft_submitted)}, approved {String(collab.draft_approved)}, posted {String(collab.content_posted)}</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader><CardTitle>Dispute Resolution</CardTitle></CardHeader>
          <CardContent>
            <form action={`/api/admin/collabs/${params.id}/resolve`} method="post" className="space-y-3">
              <Textarea name="admin_notes" placeholder="Admin notes (internal only)" />
              <div className="flex flex-wrap gap-2">
                <Button name="resolution" value="creator_wins" variant="outline" type="submit">Creator Wins</Button>
                <Button name="resolution" value="brand_wins" variant="outline" type="submit">Brand Wins</Button>
                <Button name="resolution" value="mutual" variant="outline" type="submit">Mutual</Button>
              </div>
            </form>
          </CardContent>
        </Card>

        <Card>
          <CardHeader><CardTitle>Chat (Read Only)</CardTitle></CardHeader>
          <CardContent className="overflow-x-auto">
            <Table>
              <TableHeader><TableRow><TableHead>Sender</TableHead><TableHead>Message</TableHead><TableHead>Time</TableHead></TableRow></TableHeader>
              <TableBody>
                {(messages.data ?? []).map((message) => (
                  <TableRow key={message.id}><TableCell>{message.sender_id}</TableCell><TableCell>{message.content}</TableCell><TableCell>{new Date(message.created_at).toLocaleString()}</TableCell></TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      </div>
    </PermissionGate>
  )
}
