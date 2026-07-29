'use client'

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { brandApi, type CampaignBid } from '@/lib/api/brand'
import { useParams, useRouter } from 'next/navigation'
import Link from 'next/link'

export default function CampaignBidsPage() {
  const { id } = useParams<{ id: string }>()
  const router = useRouter()
  const queryClient = useQueryClient()

  const { data, isLoading } = useQuery({
    queryKey: ['brand', 'campaign', id, 'bids'],
    queryFn: () => brandApi.getCampaignBids(id),
  })

  const respondMutation = useMutation({
    mutationFn: ({ bidId, action }: { bidId: string; action: 'accept' | 'reject' }) =>
      brandApi.respondToBid(id, bidId, action),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['brand', 'campaign', id, 'bids'] }),
  })

  const bids = data?.bids || []

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <Link href="/dashboard/brand/campaigns" className="inline-flex items-center gap-2 border-2 border-ink bg-white px-4 py-2 font-space text-xs font-bold text-ink hover:shadow-[3px_3px_0_#FF2D78] transition-all">
        ← Back to Campaigns
      </Link>

      <h1 className="font-jakarta text-3xl font-extrabold text-ink">Campaign Bids</h1>

      {isLoading ? (
        <div className="space-y-3">
          {[1, 2, 3].map((i) => (
            <div key={i} className="border-2 border-ink bg-white p-5 animate-pulse"><div className="h-5 bg-gray-200 rounded w-1/2 mb-3" /><div className="h-3 bg-gray-200 rounded w-1/3" /></div>
          ))}
        </div>
      ) : bids.length === 0 ? (
        <div className="border-2 border-ink bg-white p-8 text-center">
          <p className="text-2xl mb-2">📭</p>
          <p className="font-nunito text-muted">No bids received yet.</p>
        </div>
      ) : (
        <div className="space-y-4">
          {bids.map((bid: CampaignBid) => (
            <div key={bid.id} className="border-2 border-ink bg-white p-5 shadow-[3px_3px_0_#0D0D0D]">
              <div className="flex items-start justify-between gap-3">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-pink border-2 border-ink flex items-center justify-center font-jakarta text-sm font-bold text-white">
                    {bid.creator_first_name?.[0] || '?'}
                  </div>
                  <div>
                    <h3 className="font-jakarta text-base font-bold text-ink">{bid.creator_first_name}</h3>
                    {bid.tier && <span className="font-space text-[9px] font-bold uppercase text-muted">{bid.tier}</span>}
                  </div>
                </div>
                <span className={`shrink-0 rounded-full border-2 border-ink px-2.5 py-0.5 font-space text-[9px] font-bold uppercase ${
                  bid.status === 'pending' ? 'bg-yellow-200 text-ink' :
                  bid.status === 'accepted' ? 'bg-neon text-ink' : 'bg-gray-200 text-muted'
                }`}>{bid.status}</span>
              </div>

              <div className="mt-3 grid grid-cols-3 gap-3 font-nunito text-xs">
                <div className="border border-ink bg-white px-3 py-1.5">
                  <p className="font-space text-[9px] font-bold uppercase text-muted">Bid Amount</p>
                  <p className="font-bold text-ink">₹{bid.bid_amount.toLocaleString()}</p>
                </div>
                <div className="border border-ink bg-white px-3 py-1.5">
                  <p className="font-space text-[9px] font-bold uppercase text-muted">Followers</p>
                  <p className="font-bold text-ink">{bid.followers_count?.toLocaleString() || 'N/A'}</p>
                </div>
                <div className="border border-ink bg-white px-3 py-1.5">
                  <p className="font-space text-[9px] font-bold uppercase text-muted">Engagement</p>
                  <p className="font-bold text-ink">{bid.engagement_rate ? `${bid.engagement_rate}%` : 'N/A'}</p>
                </div>
              </div>

              {bid.message && <p className="mt-2 font-nunito text-sm text-ink/70 italic">&ldquo;{bid.message}&rdquo;</p>}

              {bid.status === 'pending' && (
                <div className="mt-4 flex gap-3">
                  <button onClick={() => respondMutation.mutate({ bidId: bid.id, action: 'accept' })} disabled={respondMutation.isPending} className="border-2 border-ink bg-neon px-5 py-2 font-space text-xs font-bold uppercase text-ink disabled:opacity-50">
                    Accept Bid
                  </button>
                  <button onClick={() => respondMutation.mutate({ bidId: bid.id, action: 'reject' })} disabled={respondMutation.isPending} className="border-2 border-ink bg-white px-5 py-2 font-space text-xs font-bold uppercase text-ink disabled:opacity-50">
                    Reject
                  </button>
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
