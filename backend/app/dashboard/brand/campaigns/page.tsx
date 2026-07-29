'use client'

import { useQuery } from '@tanstack/react-query'
import { brandApi, type BrandCampaign } from '@/lib/api/brand'
import Link from 'next/link'
import { useState, useMemo } from 'react'

const statusFilters = ['all', 'active', 'paused', 'completed']

export default function BrandCampaignsPage() {
  const [filter, setFilter] = useState('all')
  const [search, setSearch] = useState('')

  const { data, isLoading } = useQuery({
    queryKey: ['brand', 'campaigns', filter],
    queryFn: () => brandApi.getCampaigns(filter === 'all' ? undefined : filter),
  })

  const campaigns = useMemo(() => data?.campaigns || [], [data?.campaigns])

  const filtered = useMemo(() => {
    if (!search) return campaigns
    const q = search.toLowerCase()
    return campaigns.filter((c: BrandCampaign) =>
      c.title.toLowerCase().includes(q) || c.description.toLowerCase().includes(q)
    )
  }, [campaigns, search])

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="font-jakarta text-3xl font-extrabold text-ink">My Campaigns</h1>
          <p className="mt-1 font-nunito text-base text-muted">Manage your brand campaigns.</p>
        </div>
        <Link
          href="/dashboard/brand/campaigns/create"
          className="border-2 border-ink bg-pink px-5 py-3 font-space text-xs font-bold uppercase text-white hover:shadow-[4px_4px_0_#0D0D0D] transition-all"
        >
          + New Campaign
        </Link>
      </div>

      <div className="border-2 border-ink bg-white p-4 shadow-[4px_4px_0_#FF2D78] space-y-3">
        <input
          type="text"
          placeholder="Search campaigns by title or description..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none focus:shadow-[3px_3px_0_#FF2D78]"
        />
        <div className="flex gap-2 flex-wrap">
          {statusFilters.map((s) => (
            <button
              key={s}
              onClick={() => setFilter(s)}
              className={`border-2 border-ink px-4 py-2 font-space text-[10px] font-bold uppercase tracking-[0.08em] transition-all ${
                filter === s ? 'bg-pink text-white shadow-[2px_2px_0_#0D0D0D]' : 'bg-white text-ink/70 hover:shadow-[2px_2px_0_#FF2D78]'
              }`}
            >
              {s}
            </button>
          ))}
        </div>
      </div>

      {isLoading ? (
        <div className="space-y-3">
          {[1, 2, 3].map((i) => (
            <div key={i} className="border-2 border-ink bg-white p-5 animate-pulse">
              <div className="h-5 bg-gray-200 rounded w-1/2 mb-3" /><div className="h-3 bg-gray-200 rounded w-1/3" />
            </div>
          ))}
        </div>
      ) : filtered.length === 0 ? (
        <div className="border-2 border-ink bg-white p-8 text-center">
          <p className="text-2xl mb-2">📋</p>
          <p className="font-nunito text-muted">{search || filter !== 'all' ? 'No campaigns match your filters.' : 'No campaigns yet.'}</p>
          {!search && filter === 'all' && (
            <Link href="/dashboard/brand/campaigns/create" className="mt-4 inline-block border-2 border-ink bg-pink px-4 py-2 font-space text-xs font-bold text-white">Create Campaign →</Link>
          )}
        </div>
      ) : (
        <div className="space-y-3">
          {filtered.map((c: BrandCampaign) => (
            <div key={c.id} className="border-2 border-ink bg-white p-5 shadow-[3px_3px_0_#0D0D0D]">
              <div className="flex items-start justify-between gap-3">
                <div className="flex-1 min-w-0">
                  <h3 className="font-jakarta text-lg font-bold text-ink">{c.title}</h3>
                  <p className="font-nunito text-sm text-muted mt-1 line-clamp-1">{c.description}</p>
                </div>
                <span className={`shrink-0 rounded-full border-2 border-ink px-2.5 py-0.5 font-space text-[9px] font-bold uppercase ${
                  c.status === 'active' ? 'bg-neon text-ink' :
                  c.status === 'paused' ? 'bg-yellow-200 text-ink' :
                  c.status === 'completed' ? 'bg-blue-200 text-ink' : 'bg-gray-200 text-muted'
                }`}>{c.status}</span>
              </div>
              <div className="mt-3 flex items-center gap-4 font-nunito text-xs text-ink/70">
                <span className="font-bold text-ink">₹{((c.budget_min || 0)).toLocaleString()} - ₹{((c.budget_max || 0)).toLocaleString()}</span>
                <span>{c.bid_count} bids</span>
                <span>{c.slots_filled}/{c.slots} slots</span>
              </div>
              <div className="mt-3 flex gap-2">
                <Link href={`/dashboard/brand/campaigns/${c.id}/bids`} className="border-2 border-ink bg-pink px-3 py-1 font-space text-[9px] font-bold text-white">View Bids</Link>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
