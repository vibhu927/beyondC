'use client'

import Image from 'next/image'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { brandApi, type SavedCreator } from '@/lib/api/brand'
import Link from 'next/link'
import { useState, useMemo } from 'react'

const nicheOptions = ['All', 'Fashion', 'Food', 'Travel', 'Tech', 'Beauty', 'Comedy', 'Fitness', 'Gaming', 'Lifestyle', 'Health', 'Education']
const tierOptions = ['All', 'Nano', 'Micro', 'Mid', 'Macro']

export default function SavedCreatorsPage() {
  const queryClient = useQueryClient()
  const [search, setSearch] = useState('')
  const [niche, setNiche] = useState('All')
  const [tier, setTier] = useState('All')

  const { data, isLoading } = useQuery({
    queryKey: ['brand', 'saved-creators'],
    queryFn: () => brandApi.getSavedCreators(),
  })

  const unsaveMutation = useMutation({
    mutationFn: (creatorId: string) => brandApi.unsaveCreator(creatorId),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['brand', 'saved-creators'] }),
  })

  const saved = useMemo(() => data?.saved_creators || [], [data?.saved_creators])

  const filtered = useMemo(() => {
    return saved.filter((c: SavedCreator) => {
      const name = (c.creator_full_name || c.creator_first_name || '').toLowerCase()
      if (search && !name.includes(search.toLowerCase())) return false
      if (niche !== 'All' && !c.creator_niches?.includes(niche)) return false
      if (tier !== 'All' && c.creator_tier?.toLowerCase() !== tier.toLowerCase()) return false
      return true
    })
  }, [saved, search, niche, tier])

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <div>
        <h1 className="font-jakarta text-3xl font-extrabold text-ink">Saved Creators</h1>
        <p className="mt-1 font-nunito text-base text-muted">Creators you&apos;ve bookmarked.</p>
      </div>

      <div className="border-2 border-ink bg-white p-5 shadow-[4px_4px_0_#FF2D78] space-y-4">
        <input
          type="text"
          placeholder="Search by name..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none focus:shadow-[3px_3px_0_#FF2D78]"
        />
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <p className="mb-1 font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted">Niche</p>
            <select
              value={niche}
              onChange={(e) => setNiche(e.target.value)}
              className="w-full border-2 border-ink bg-white px-3 py-2 font-nunito text-sm text-ink"
            >
              {nicheOptions.map((n) => <option key={n} value={n}>{n}</option>)}
            </select>
          </div>
          <div>
            <p className="mb-1 font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted">Tier</p>
            <select
              value={tier}
              onChange={(e) => setTier(e.target.value)}
              className="w-full border-2 border-ink bg-white px-3 py-2 font-nunito text-sm text-ink"
            >
              {tierOptions.map((t) => <option key={t} value={t}>{t}</option>)}
            </select>
          </div>
        </div>
      </div>

      {isLoading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          {[1, 2, 3, 4].map((i) => (
            <div key={i} className="border-2 border-ink bg-white p-5 animate-pulse">
              <div className="h-12 w-12 bg-gray-200 rounded-full mb-3" />
              <div className="h-4 bg-gray-200 rounded w-2/3 mb-2" />
            </div>
          ))}
        </div>
      ) : saved.length === 0 ? (
        <div className="border-2 border-ink bg-white p-8 text-center">
          <p className="text-2xl mb-2">☆</p>
          <p className="font-nunito text-muted">No saved creators yet. Discover and save creators you like.</p>
        </div>
      ) : filtered.length === 0 ? (
        <div className="border-2 border-ink bg-white p-8 text-center">
          <p className="text-2xl mb-2">🔍</p>
          <p className="font-nunito text-muted">No saved creators match your filters.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          {filtered.map((creator: SavedCreator) => (
            <div
              key={creator.id}
              className="border-2 border-ink bg-white p-5 shadow-[3px_3px_0_#0D0D0D] hover:shadow-[5px_5px_0_#FF2D78] hover:-translate-y-0.5 transition-all"
            >
              <Link href={`/dashboard/brand/creators/${creator.creator_id}`}>
                <div className="flex items-center gap-3 mb-3">
                  <div className="relative w-12 h-12 rounded-full bg-pink border-2 border-ink flex items-center justify-center font-jakarta text-lg font-bold text-white shrink-0 overflow-hidden">
                    {creator.creator_avatar_url ? (
                      <Image src={creator.creator_avatar_url} alt="" fill className="object-cover" />
                    ) : (
                      (creator.creator_full_name?.[0] || creator.creator_first_name?.[0] || '?').toUpperCase()
                    )}
                  </div>
                  <div className="flex-1 min-w-0">
                    <h3 className="font-jakarta text-base font-bold text-ink truncate">{creator.creator_full_name || creator.creator_first_name}</h3>
                    {creator.creator_tier && (
                      <span className="font-space text-[9px] font-bold uppercase text-muted">{creator.creator_tier}</span>
                    )}
                  </div>
                </div>

                <div className="space-y-1.5 font-nunito text-xs text-ink/70">
                  {creator.creator_followers != null && (
                    <p>👥 {creator.creator_followers.toLocaleString()} followers</p>
                  )}
                  {creator.creator_starting_price != null && (
                    <p>💰 From ₹{creator.creator_starting_price.toLocaleString()}</p>
                  )}
                  {creator.creator_engagement_rate != null && (
                    <p>📈 {Number(creator.creator_engagement_rate).toFixed(1)}% engagement</p>
                  )}
                  {creator.creator_city && (
                    <p>📍 {creator.creator_city}{creator.creator_state ? `, ${creator.creator_state}` : ''}</p>
                  )}
                </div>

                {creator.creator_niches && creator.creator_niches.length > 0 && (
                  <div className="mt-3 flex flex-wrap gap-1.5">
                    {creator.creator_niches.slice(0, 3).map((n: string) => (
                      <span key={n} className="border border-ink bg-pink/10 px-2 py-0.5 font-space text-[9px] font-bold text-ink">{n}</span>
                    ))}
                  </div>
                )}
              </Link>

              <div className="mt-4 flex gap-2">
                <Link
                  href={`/dashboard/brand/creators/${creator.creator_id}`}
                  className="flex-1 border-2 border-ink bg-white px-3 py-2 text-center font-space text-[10px] font-bold uppercase text-ink hover:shadow-[2px_2px_0_#FF2D78] transition-all"
                >
                  Profile
                </Link>
                <button
                  onClick={(e) => {
                    e.preventDefault()
                    unsaveMutation.mutate(creator.creator_id)
                  }}
                  disabled={unsaveMutation.isPending}
                  className="w-10 h-10 border-2 border-ink bg-white flex items-center justify-center font-space text-sm font-bold text-ink hover:bg-red-50 disabled:opacity-50 transition-all"
                  title="Remove"
                >
                  {unsaveMutation.isPending ? '...' : '☆'}
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
