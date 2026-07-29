'use client'

import Image from 'next/image'
import { useQuery } from '@tanstack/react-query'
import { creatorApi, type Campaign } from '@/lib/api/creator'
import Link from 'next/link'
import { useState, useMemo } from 'react'

const nicheOptions = ['All', 'Fashion', 'Food', 'Travel', 'Tech', 'Beauty', 'Comedy', 'Fitness', 'Gaming', 'Lifestyle', 'Health', 'Education']
const collabTypeOptions = ['All', 'paid', 'barter', 'hybrid']

export default function CreatorCampaignsPage() {
  const [selectedNiche, setSelectedNiche] = useState('All')
  const [selectedType, setSelectedType] = useState('All')
  const [budgetMin, setBudgetMin] = useState('')
  const [budgetMax, setBudgetMax] = useState('')
  const [search, setSearch] = useState('')

  const queryParams = useMemo(() => {
    const p: Record<string, string | undefined> = {}
    if (selectedNiche !== 'All') p.niche = selectedNiche
    if (selectedType !== 'All') p.collab_type = selectedType
    if (budgetMin) p.budget_min = String(Number(budgetMin) * 100)
    if (budgetMax) p.budget_max = String(Number(budgetMax) * 100)
    return p
  }, [selectedNiche, selectedType, budgetMin, budgetMax])

  const { data, isLoading } = useQuery({
    queryKey: ['creator', 'campaigns', queryParams],
    queryFn: () => creatorApi.getCampaigns(queryParams),
  })

  const campaigns = data?.campaigns || []

  return (
    <div className="max-w-6xl mx-auto space-y-6">
      <div>
        <h1 className="font-jakarta text-3xl font-extrabold text-ink">Browse Campaigns</h1>
        <p className="mt-1 font-nunito text-base text-muted">Find campaigns that match your style.</p>
      </div>

      <div className="border-2 border-ink bg-white p-5 shadow-[4px_4px_0_#C8FF00] space-y-4">
        <div className="flex flex-wrap gap-3">
          <input
            type="text"
            placeholder="Search campaigns..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="flex-1 min-w-[200px] border-2 border-ink bg-white px-4 py-2 font-nunito text-sm text-ink outline-none focus:shadow-[3px_3px_0_#C8FF00]"
          />
        </div>

        <div>
          <p className="mb-2 font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted">Niche</p>
          <div className="flex flex-wrap gap-2">
            {nicheOptions.map((niche) => (
              <button
                key={niche}
                onClick={() => setSelectedNiche(niche)}
                className={`border-2 border-ink px-3 py-1.5 font-space text-[10px] font-bold uppercase tracking-[0.08em] transition-all ${
                  selectedNiche === niche
                    ? 'bg-neon text-ink shadow-[2px_2px_0_#0D0D0D]'
                    : 'bg-white text-ink/70 hover:shadow-[2px_2px_0_#C8FF00]'
                }`}
              >
                {niche}
              </button>
            ))}
          </div>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <div>
            <p className="mb-1 font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted">Collab Type</p>
            <select
              value={selectedType}
              onChange={(e) => setSelectedType(e.target.value)}
              className="w-full border-2 border-ink bg-white px-3 py-2 font-nunito text-sm text-ink outline-none"
            >
              {collabTypeOptions.map((t) => (
                <option key={t} value={t}>{t === 'All' ? 'All Types' : t}</option>
              ))}
            </select>
          </div>
          <div>
            <p className="mb-1 font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted">Min Budget (₹)</p>
            <input
              type="number"
              value={budgetMin}
              onChange={(e) => setBudgetMin(e.target.value)}
              placeholder="0"
              className="w-full border-2 border-ink bg-white px-3 py-2 font-nunito text-sm text-ink outline-none"
            />
          </div>
          <div>
            <p className="mb-1 font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted">Max Budget (₹)</p>
            <input
              type="number"
              value={budgetMax}
              onChange={(e) => setBudgetMax(e.target.value)}
              placeholder="10000"
              className="w-full border-2 border-ink bg-white px-3 py-2 font-nunito text-sm text-ink outline-none"
            />
          </div>
        </div>
      </div>

      {isLoading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {[1, 2, 3, 4].map((i) => (
            <div key={i} className="border-2 border-ink bg-white p-5 animate-pulse">
              <div className="h-5 bg-gray-200 rounded w-3/4 mb-3" />
              <div className="h-3 bg-gray-200 rounded w-full mb-2" />
              <div className="h-3 bg-gray-200 rounded w-1/2" />
            </div>
          ))}
        </div>
      ) : campaigns.length === 0 ? (
        <div className="border-2 border-ink bg-white p-8 text-center">
          <p className="text-2xl mb-2">📭</p>
          <p className="font-nunito text-muted">No campaigns found matching your filters.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {campaigns
            .filter((c: Campaign) => !search || c.title.toLowerCase().includes(search.toLowerCase()))
            .map((campaign: Campaign) => (
            <Link
              key={campaign.id}
              href={`/dashboard/creator/campaigns/${campaign.id}`}
              className="border-2 border-ink bg-white p-5 shadow-[3px_3px_0_#0D0D0D] hover:shadow-[5px_5px_0_#C8FF00] hover:-translate-y-0.5 transition-all block"
            >
              <div className="flex items-start justify-between gap-3">
                <div className="flex items-start gap-3 flex-1 min-w-0">
                  <div className="relative w-10 h-10 rounded-full border-2 border-ink bg-ink flex items-center justify-center font-jakarta text-xs font-bold text-neon shrink-0 overflow-hidden">
                    {campaign.brand_logo ? (
                      <Image src={campaign.brand_logo} alt="" fill className="object-cover" />
                    ) : (
                      campaign.brand_name?.[0] || '?'
                    )}
                  </div>
                  <div className="min-w-0">
                    <h3 className="font-jakarta text-lg font-bold text-ink truncate">{campaign.title}</h3>
                    <p className="font-nunito text-sm text-muted mt-0.5">{campaign.brand_name}</p>
                    <p className="font-nunito text-sm text-muted mt-1 line-clamp-2">{campaign.description}</p>
                  </div>
                </div>
                <span className="shrink-0 rounded-full border-2 border-ink bg-neon px-2.5 py-0.5 font-space text-[9px] font-bold uppercase text-ink">
                  {campaign.collab_type}
                </span>
              </div>

              <div className="mt-4 flex flex-wrap gap-3">
                <span className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-ink">
                  ₹{(campaign.budget_min || 0).toLocaleString()} - ₹{(campaign.budget_max || 0).toLocaleString()}
                </span>
                <span className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted">
                  {campaign.bid_count} bids
                </span>
                <span className="font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted">
                  {campaign.slots_filled}/{campaign.slots_total} filled
                </span>
              </div>

              <div className="mt-3 flex flex-wrap gap-1.5">
                {campaign.niche?.slice(0, 3).map((n: string) => (
                  <span key={n} className="border border-ink bg-white px-2 py-0.5 font-space text-[9px] font-bold text-ink">
                    {n}
                  </span>
                ))}
              </div>
            </Link>
          ))}
        </div>
      )}

      {data && data.totalPages > 1 && (
        <div className="flex items-center justify-center gap-3 pt-4">
          <span className="font-nunito text-sm text-muted">
            Page {data.page} of {data.totalPages} ({data.total} campaigns)
          </span>
        </div>
      )}
    </div>
  )
}
