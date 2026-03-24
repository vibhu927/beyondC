import { notFound } from 'next/navigation'
import { PermissionGate } from '@/components/admin/permission-gate'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { createServiceClient } from '@/lib/supabase/service'

export default async function AdminCampaignDetailPage({ params }: { params: { id: string } }) {
  const service = createServiceClient()
  const { data: campaign } = await service.from('campaigns').select('*').eq('id', params.id).single()
  if (!campaign) notFound()

  const { data: bids } = await service
    .from('bids')
    .select('id,creator_id,bid_amount,status,created_at')
    .eq('campaign_id', params.id)
    .order('created_at', { ascending: false })

  return (
    <PermissionGate page="campaigns" action="can_view">
      <div className="space-y-4">
        <Card>
          <CardHeader><CardTitle>{campaign.title}</CardTitle></CardHeader>
          <CardContent className="grid grid-cols-1 gap-3 md:grid-cols-2">
            <p><span className="text-zinc-500 dark:text-zinc-400">Brand:</span> {campaign.brand_id}</p>
            <p><span className="text-zinc-500 dark:text-zinc-400">Type:</span> {campaign.collab_type}</p>
            <p><span className="text-zinc-500 dark:text-zinc-400">Budget:</span> {campaign.budget_min || 0} - {campaign.budget_max || 0}</p>
            <p><span className="text-zinc-500 dark:text-zinc-400">Status:</span> {campaign.status}</p>
            <p className="md:col-span-2"><span className="text-zinc-500 dark:text-zinc-400">Description:</span> {campaign.description || '-'}</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader><CardTitle>Bids</CardTitle></CardHeader>
          <CardContent className="overflow-x-auto">
            <Table>
              <TableHeader><TableRow><TableHead>ID</TableHead><TableHead>Creator</TableHead><TableHead>Amount</TableHead><TableHead>Status</TableHead><TableHead>Date</TableHead></TableRow></TableHeader>
              <TableBody>
                {(bids ?? []).map((bid) => (
                  <TableRow key={bid.id}><TableCell>{bid.id}</TableCell><TableCell>{bid.creator_id}</TableCell><TableCell>{bid.bid_amount || 0}</TableCell><TableCell>{bid.status}</TableCell><TableCell>{new Date(bid.created_at).toLocaleString()}</TableCell></TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      </div>
    </PermissionGate>
  )
}
