import { notFound } from 'next/navigation'
import { PermissionGate } from '@/components/admin/permission-gate'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Textarea } from '@/components/ui/textarea'
import { createServiceClient } from '@/lib/supabase/service'

export default async function AdminDisputeDetailPage({ params }: { params: { id: string } }) {
  const service = createServiceClient()
  const { data: collab } = await service.from('collabs').select('*').eq('id', params.id).single()
  if (!collab) notFound()

  const [creator, brand] = await Promise.all([
    service.from('profiles').select('id,full_name,email').eq('id', collab.creator_id).maybeSingle(),
    service.from('profiles').select('id,full_name,email').eq('id', collab.brand_id).maybeSingle(),
  ])

  return (
    <PermissionGate page="disputes" action="can_view">
      <div className="space-y-4">
        <Card>
          <CardHeader><CardTitle>Dispute: {collab.id}</CardTitle></CardHeader>
          <CardContent className="space-y-3">
            <p><span className="text-zinc-500 dark:text-zinc-400">Creator:</span> {creator.data?.full_name || collab.creator_id} ({creator.data?.email || '-'})</p>
            <p><span className="text-zinc-500 dark:text-zinc-400">Brand:</span> {brand.data?.full_name || collab.brand_id} ({brand.data?.email || '-'})</p>
            <p><span className="text-zinc-500 dark:text-zinc-400">Current Status:</span> {collab.status}</p>
            <p><span className="text-zinc-500 dark:text-zinc-400">Dispute Description:</span> captured via messages and collab timeline.</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader><CardTitle>Admin Notes & Resolution</CardTitle></CardHeader>
          <CardContent>
            <form action={`/api/admin/collabs/${params.id}/resolve`} method="post" className="space-y-3">
              <Textarea name="admin_notes" placeholder="Admin notes (internal)" />
              <div className="flex flex-wrap gap-2">
                <Button type="submit" name="resolution" value="creator_wins" variant="outline">Creator Wins</Button>
                <Button type="submit" name="resolution" value="brand_wins" variant="outline">Brand Wins</Button>
                <Button type="submit" name="resolution" value="mutual" variant="outline">Mutual</Button>
              </div>
            </form>
          </CardContent>
        </Card>
      </div>
    </PermissionGate>
  )
}
