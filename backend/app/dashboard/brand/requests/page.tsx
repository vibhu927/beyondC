'use client'

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { brandApi, type BidWithCampaign } from '@/lib/api/brand'
import { useState, useMemo } from 'react'
import Link from 'next/link'

type RequestItem = {
  id: string
  creator_id: string
  creator_first_name: string
  creator_tier: string | null
  budget: number | null
  collab_type: string
  status: string
  message: string | null
  campaign_title: string | null
  created_at: string
}

function formatDate(dateStr: string) {
  return new Date(dateStr).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' })
}

function statusBadge(status: string) {
  const styles: Record<string, string> = {
    pending: 'bg-yellow-200 text-ink',
    accepted: 'bg-neon text-ink',
    rejected: 'bg-gray-200 text-muted',
    expired: 'bg-gray-200 text-muted line-through',
    withdrawn: 'bg-gray-200 text-muted line-through',
  }
  return styles[status] || 'bg-gray-100 text-muted'
}

export default function BrandRequestsPage() {
  const queryClient = useQueryClient()
  const [tab, setTab] = useState<'campaign' | 'sent'>('campaign')
  const [actionMsg, setActionMsg] = useState('')
  const [search, setSearch] = useState('')

  const { data: sentData, isLoading: sentLoading } = useQuery({
    queryKey: ['brand', 'requests'],
    queryFn: () => brandApi.getRequests(),
  })

  const { data: bidsData, isLoading: bidsLoading } = useQuery({
    queryKey: ['brand', 'bids', 'all'],
    queryFn: () => brandApi.getAllBids(),
  })

  const withdrawMutation = useMutation({
    mutationFn: (id: string) => brandApi.withdrawRequest(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['brand', 'requests'] })
      setActionMsg('Request withdrawn.')
      setTimeout(() => setActionMsg(''), 3000)
    },
  })

  const respondBidMutation = useMutation({
    mutationFn: ({ campaignId, bidId, action }: { campaignId: string; bidId: string; action: 'accept' | 'reject' }) =>
      brandApi.respondToBid(campaignId, bidId, action),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['brand', 'bids', 'all'] })
      setActionMsg('Bid updated!')
      setTimeout(() => setActionMsg(''), 3000)
    },
    onError: (e) => {
      setActionMsg(e instanceof Error ? e.message : 'Action failed')
      setTimeout(() => setActionMsg(''), 3000)
    },
  })

  const requests = useMemo(() => (sentData?.requests || []) as RequestItem[], [sentData?.requests])
  const bids = useMemo(() => (bidsData?.bids || []) as BidWithCampaign[], [bidsData?.bids])

  const filteredBids = useMemo(() => {
    if (!search) return bids
    const q = search.toLowerCase()
    return bids.filter((b) =>
      (b.creator_first_name || '').toLowerCase().includes(q) ||
      (b.campaign_title || '').toLowerCase().includes(q)
    )
  }, [bids, search])

  const filteredRequests = useMemo(() => {
    if (!search) return requests
    const q = search.toLowerCase()
    return requests.filter((r) =>
      (r.creator_first_name || '').toLowerCase().includes(q) ||
      (r.campaign_title || '').toLowerCase().includes(q)
    )
  }, [requests, search])

  return (
    <div className="max-w-5xl mx-auto space-y-6">
      <div>
        <h1 className="font-jakarta text-3xl font-extrabold text-ink">Requests</h1>
        <p className="mt-1 font-nunito text-base text-muted">Incoming campaign bids and sent requests.</p>
      </div>

      {actionMsg && <div className="border-2 border-ink bg-neon px-4 py-3 font-nunito text-sm font-semibold text-ink">{actionMsg}</div>}

      <div className="border-2 border-ink bg-white p-4 shadow-[4px_4px_0_#FF2D78]">
        <input
          type="text"
          placeholder="Search by creator name or campaign..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none focus:shadow-[3px_3px_0_#FF2D78]"
        />
      </div>

      {/* Tabs */}
      <div className="flex border-b-2 border-ink">
        <button
          onClick={() => setTab('campaign')}
          className={`px-5 py-3 font-space text-xs font-bold uppercase border-t-2 border-l-2 border-r-2 border-ink -mb-[2px] transition-all ${
            tab === 'campaign' ? 'bg-white text-ink' : 'bg-ink/5 text-muted hover:bg-white'
          }`}
        >
          Campaign Requests {filteredBids.length > 0 && `(${filteredBids.filter((b) => b.status === 'pending').length})`}
        </button>
        <button
          onClick={() => setTab('sent')}
          className={`px-5 py-3 font-space text-xs font-bold uppercase border-t-2 border-l-2 border-r-2 border-ink -mb-[2px] transition-all ${
            tab === 'sent' ? 'bg-white text-ink' : 'bg-ink/5 text-muted hover:bg-white'
          }`}
        >
          Sent Requests ({filteredRequests.length})
        </button>
      </div>

      {/* Campaign Requests Tab */}
      {tab === 'campaign' && (
        <>
          {bidsLoading ? (
            <div className="border-2 border-ink bg-white p-6 animate-pulse space-y-4">
              {[1, 2].map((i) => <div key={i} className="h-16 bg-gray-100 rounded" />)}
            </div>
          ) : bids.length === 0 ? (
            <div className="border-2 border-ink bg-white p-8 text-center">
              <p className="text-2xl mb-2">📢</p>
              <p className="font-nunito text-muted">No campaign bids yet. Create a campaign to receive applications from creators.</p>
              <Link
                href="/dashboard/brand/campaigns/create"
                className="mt-3 inline-block border-2 border-ink bg-pink px-4 py-2 font-space text-xs font-bold uppercase text-white"
              >
                + Create Campaign
              </Link>
            </div>
          ) : (
            <div className="space-y-4">
              {filteredBids.map((bid) => (
                <div key={bid.id} className="border-2 border-ink bg-white p-5 shadow-[4px_4px_0_#FF2D78] hover:shadow-[5px_5px_0_#FF2D78] hover:-translate-y-0.5 transition-all">
                  <div className="flex items-start gap-3">
                    <Link href={`/dashboard/brand/creators/${bid.creator_id}`}>
                      <div className="w-11 h-11 rounded-full border-2 border-ink bg-pink flex items-center justify-center font-jakarta text-base font-bold text-white shrink-0">
                        {bid.creator_first_name?.[0]?.toUpperCase() || 'C'}
                      </div>
                    </Link>
                    <div className="min-w-0 flex-1">
                      <div className="flex items-center gap-2 flex-wrap">
                        <Link href={`/dashboard/brand/creators/${bid.creator_id}`} className="hover:underline">
                          <h3 className="font-jakarta text-base font-bold text-ink">{bid.creator_first_name || 'Creator'}</h3>
                        </Link>
                        {bid.creator_tier && (
                          <span className="rounded-full border border-ink bg-neon/40 px-2 py-0.5 font-space text-[8px] font-bold uppercase text-ink">{bid.creator_tier}</span>
                        )}
                        <span className={`rounded-full border-2 border-ink px-2 py-0.5 font-space text-[8px] font-bold uppercase ${statusBadge(bid.status)}`}>
                          {bid.status}
                        </span>
                      </div>

                      <div className="flex flex-wrap items-center gap-x-3 gap-y-1 mt-1.5">
                        <span className="font-nunito text-xs font-semibold text-ink">{bid.campaign_title}</span>
                        <span className="font-jakarta text-xs font-bold text-ink">💰 ₹{(bid.bid_amount || 0).toLocaleString()}</span>
                        <span className="font-nunito text-[10px] text-muted">{formatDate(bid.created_at)}</span>
                      </div>

                      {bid.message && (
                        <p className="font-nunito text-xs text-muted mt-1 line-clamp-2 bg-ink/5 p-2 border border-ink/20">
                          &ldquo;{bid.message}&rdquo;
                        </p>
                      )}

                      <div className="mt-2">
                        <Link
                          href={`/dashboard/brand/campaigns/${bid.campaign_id}`}
                          className="font-space text-[9px] font-bold uppercase text-pink hover:underline"
                        >
                          View Campaign →
                        </Link>
                      </div>
                    </div>
                  </div>

                  {bid.status === 'pending' && (
                    <div className="mt-3 pt-3 border-t-2 border-ink/10 flex gap-2 justify-end">
                      <button
                        onClick={() => respondBidMutation.mutate({ campaignId: bid.campaign_id, bidId: bid.id, action: 'accept' })}
                        disabled={respondBidMutation.isPending}
                        className="border-2 border-ink bg-pink px-4 py-1.5 font-space text-[10px] font-bold uppercase text-white disabled:opacity-50"
                      >
                        Accept
                      </button>
                      <button
                        onClick={() => respondBidMutation.mutate({ campaignId: bid.campaign_id, bidId: bid.id, action: 'reject' })}
                        disabled={respondBidMutation.isPending}
                        className="border-2 border-ink bg-white px-4 py-1.5 font-space text-[10px] font-bold uppercase text-muted hover:bg-red-50 hover:text-red-600 transition-all disabled:opacity-50"
                      >
                        Reject
                      </button>
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}
        </>
      )}

      {/* Sent Requests Tab */}
      {tab === 'sent' && (
        <>
          {sentLoading ? (
            <div className="border-2 border-ink bg-white p-6 animate-pulse space-y-4">
              {[1, 2].map((i) => <div key={i} className="h-16 bg-gray-100 rounded" />)}
            </div>
          ) : requests.length === 0 ? (
            <div className="border-2 border-ink bg-white p-8 text-center">
              <p className="text-2xl mb-2">✉️</p>
              <p className="font-nunito text-muted">No requests sent yet. Discover creators to reach out.</p>
              <Link
                href="/dashboard/brand/discover"
                className="mt-3 inline-block border-2 border-ink bg-pink px-4 py-2 font-space text-xs font-bold uppercase text-white"
              >
                Discover Creators
              </Link>
            </div>
          ) : (
            <div className="space-y-4">
              {filteredRequests.map((req) => (
                <div key={req.id} className="border-2 border-ink bg-white p-5 shadow-[4px_4px_0_#FF2D78] hover:shadow-[5px_5px_0_#FF2D78] hover:-translate-y-0.5 transition-all">
                  <div className="flex items-start gap-3">
                    <Link href={`/dashboard/brand/creators/${req.creator_id}`}>
                      <div className="w-11 h-11 rounded-full border-2 border-ink bg-pink flex items-center justify-center font-jakarta text-base font-bold text-white shrink-0">
                        {req.creator_first_name?.[0]?.toUpperCase() || 'C'}
                      </div>
                    </Link>
                    <div className="min-w-0 flex-1">
                      <div className="flex items-center gap-2 flex-wrap">
                        <Link href={`/dashboard/brand/creators/${req.creator_id}`} className="hover:underline">
                          <h3 className="font-jakarta text-base font-bold text-ink">{req.creator_first_name || 'Creator'}</h3>
                        </Link>
                        {req.creator_tier && (
                          <span className="rounded-full border border-ink bg-neon/40 px-2 py-0.5 font-space text-[8px] font-bold uppercase text-ink">
                            {req.creator_tier}
                          </span>
                        )}
                        <span className={`rounded-full border-2 border-ink px-2 py-0.5 font-space text-[8px] font-bold uppercase ${statusBadge(req.status)}`}>
                          {req.status}
                        </span>
                      </div>

                      <div className="flex flex-wrap items-center gap-x-3 gap-y-1 mt-1.5">
                        <span className="rounded-full border border-ink bg-pink/10 px-2 py-0.5 font-space text-[8px] font-bold uppercase text-pink">
                          {req.collab_type}
                        </span>
                        {req.budget !== null && req.budget > 0 && (
                          <span className="font-jakarta text-xs font-bold text-ink">₹{(req.budget / 100).toLocaleString()}</span>
                        )}
                        <span className="font-nunito text-[10px] text-muted">{formatDate(req.created_at)}</span>
                      </div>

                      {req.campaign_title && (
                        <p className="font-nunito text-xs text-muted mt-1.5">
                          <span className="font-semibold text-ink">Campaign:</span> {req.campaign_title}
                        </p>
                      )}

                      {req.message && (
                        <p className="font-nunito text-xs text-muted mt-1 line-clamp-2 bg-ink/5 p-2 border border-ink/20">
                          &ldquo;{req.message}&rdquo;
                        </p>
                      )}
                    </div>
                  </div>

                  {req.status === 'pending' && (
                    <div className="mt-3 pt-3 border-t-2 border-ink/10 flex justify-end">
                      <button
                        onClick={() => withdrawMutation.mutate(req.id)}
                        disabled={withdrawMutation.isPending}
                        className="border-2 border-ink bg-white px-4 py-1.5 font-space text-[10px] font-bold uppercase text-muted hover:bg-red-50 hover:text-red-600 transition-all disabled:opacity-50"
                      >
                        {withdrawMutation.isPending ? 'Withdrawing...' : 'Withdraw'}
                      </button>
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}
        </>
      )}
    </div>
  )
}
