'use client'

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { creatorApi, type Bid } from '@/lib/api/creator'
import Link from 'next/link'

export default function MyBidsPage() {
  const queryClient = useQueryClient()

  const { data, isLoading } = useQuery({
    queryKey: ['creator', 'bids'],
    queryFn: () => creatorApi.getBids(),
  })

  const withdrawMutation = useMutation({
    mutationFn: (bidId: string) => creatorApi.withdrawBid(bidId),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['creator', 'bids'] }),
  })

  const bids = data?.bids || []

  if (isLoading) {
    return (
      <div className="max-w-3xl mx-auto">
        <div className="border-2 border-ink bg-white p-8 animate-pulse space-y-4">
          {[1, 2].map((i) => (
            <div key={i} className="h-24 bg-gray-100 rounded" />
          ))}
        </div>
      </div>
    )
  }

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <div>
        <h1 className="font-jakarta text-3xl font-extrabold text-ink">My Bids</h1>
        <p className="mt-1 font-nunito text-base text-muted">Track all your bids on campaigns.</p>
      </div>

      {bids.length === 0 ? (
        <div className="border-2 border-ink bg-white p-8 text-center shadow-[4px_4px_0_#C8FF00]">
          <p className="text-2xl mb-2">⚑</p>
          <p className="font-nunito text-muted">You haven&apos;t placed any bids yet.</p>
          <Link
            href="/dashboard/creator/campaigns"
            className="mt-4 inline-block border-2 border-ink bg-ink px-4 py-2 font-space text-xs font-bold text-neon hover:shadow-[3px_3px_0_#C8FF00] transition-all"
          >
            Browse Campaigns →
          </Link>
        </div>
      ) : (
        <div className="space-y-3">
          {bids.map((bid: Bid) => (
            <div key={bid.id} className="border-2 border-ink bg-white shadow-[3px_3px_0_#0D0D0D]">
              <div className="p-5">
                <div className="flex items-start justify-between gap-3">
                  <div className="flex-1 min-w-0">
                    <Link
                      href={`/dashboard/creator/campaigns/${bid.campaign_id}`}
                      className="font-jakarta text-lg font-bold text-ink hover:text-pink transition-colors"
                    >
                      {bid.campaign?.title || 'Campaign'}
                    </Link>
                    <p className="font-nunito text-sm text-muted mt-0.5">
                      {bid.campaign?.brand_name || 'Brand'}
                    </p>
                  </div>
                  <span className={`shrink-0 rounded-full border-2 border-ink px-2.5 py-0.5 font-space text-[9px] font-bold uppercase ${
                    bid.status === 'pending' ? 'bg-yellow-200 text-ink' :
                    bid.status === 'accepted' ? 'bg-neon text-ink' :
                    bid.status === 'rejected' ? 'bg-red-200 text-red-800' :
                    'bg-gray-200 text-muted'
                  }`}>
                    {bid.status}
                  </span>
                </div>

                <div className="mt-3 flex items-center gap-4">
                  <span className="font-jakarta text-sm font-bold text-ink">
                    ₹{(bid.bid_amount / 100).toLocaleString()}
                  </span>
                  {bid.campaign?.collab_type && (
                    <span className="rounded-full border border-ink bg-white px-2 py-0.5 font-space text-[9px] font-bold uppercase text-muted">
                      {bid.campaign.collab_type}
                    </span>
                  )}
                </div>

                {bid.message && (
                  <p className="mt-2 font-nunito text-sm text-ink/70 italic">&ldquo;{bid.message}&rdquo;</p>
                )}

                <div className="mt-3 flex items-center gap-3">
                  <Link
                    href={`/dashboard/creator/campaigns/${bid.campaign_id}`}
                    className="border-2 border-ink bg-white px-3 py-1.5 font-space text-[10px] font-bold uppercase text-ink hover:shadow-[2px_2px_0_#C8FF00] transition-all"
                  >
                    View Campaign
                  </Link>
                  {bid.status === 'pending' && (
                    <button
                      onClick={() => withdrawMutation.mutate(bid.id)}
                      disabled={withdrawMutation.isPending}
                      className="border-2 border-ink bg-white px-3 py-1.5 font-space text-[10px] font-bold uppercase text-muted hover:bg-red-50 hover:text-red-600 disabled:opacity-50 transition-all"
                    >
                      Withdraw
                    </button>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
