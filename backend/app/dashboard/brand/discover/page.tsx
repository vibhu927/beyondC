'use client'

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { brandApi, type CreatorPreview } from '@/lib/api/brand'
import { useState, useMemo } from 'react'
import Link from 'next/link'

const nicheOptions = ['All', 'Fashion', 'Food', 'Travel', 'Tech', 'Beauty', 'Comedy', 'Fitness', 'Gaming', 'Lifestyle', 'Health', 'Education']
const tierOptions = ['All', 'Nano', 'Micro', 'Mid', 'Macro']
const stateOptions = [
  'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
  'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand',
  'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur',
  'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab',
  'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura',
  'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
  'Delhi', 'Chandigarh', 'Jammu & Kashmir', 'Ladakh',
  'Puducherry', 'Andaman & Nicobar Islands', 'Dadra & Nagar Haveli and Daman & Diu',
  'Lakshadweep',
]

export default function DiscoverCreatorsPage() {
  const queryClient = useQueryClient()
  const [search, setSearch] = useState('')
  const [niche, setNiche] = useState('All')
  const [tier, setTier] = useState('All')
  const [state, setState] = useState('All')
  const [city, setCity] = useState('')
  const [page, setPage] = useState(1)

  const params: Record<string, string | undefined> = {}
  if (search) params.search = search
  if (niche !== 'All') params.niche = niche
  if (tier !== 'All') params.tier = tier
  if (state !== 'All') params.state = state
  if (city) params.city = city
  params.page = String(page)
  params.limit = '12'

  const { data, isLoading, error } = useQuery({
    queryKey: ['brand', 'discover', params],
    queryFn: () => brandApi.discoverCreators(params),
  })

  const { data: savedData, error: savedError } = useQuery({
    queryKey: ['brand', 'saved-creators'],
    queryFn: () => brandApi.getSavedCreators(),
  })

  const savedIds = useMemo(() => {
    const set = new Set<string>()
    savedData?.saved_creators?.forEach((s) => set.add(s.creator_id))
    return set
  }, [savedData])

  const saveMutation = useMutation({
    mutationFn: (creatorId: string) => brandApi.saveCreator(creatorId),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['brand', 'saved-creators'] }),
  })

  const unsaveMutation = useMutation({
    mutationFn: (creatorId: string) => brandApi.unsaveCreator(creatorId),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['brand', 'saved-creators'] }),
  })

  const creators = data?.creators || []

  return (
    <div className="max-w-6xl mx-auto space-y-6">
      <div>
        <h1 className="font-jakarta text-3xl font-extrabold text-ink">Discover Creators</h1>
        <p className="mt-1 font-nunito text-base text-muted">Find the perfect creators for your brand.</p>
      </div>

      <div className="border-2 border-ink bg-white p-5 shadow-[4px_4px_0_#FF2D78] space-y-4">
        <input
          type="text"
          placeholder="Search by name or niche..."
          value={search}
          onChange={(e) => { setSearch(e.target.value); setPage(1) }}
          className="w-full border-2 border-ink bg-white px-4 py-3 font-nunito text-sm text-ink outline-none focus:shadow-[3px_3px_0_#FF2D78]"
        />

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <div>
            <p className="mb-1 font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted">Niche</p>
            <select
              value={niche}
              onChange={(e) => { setNiche(e.target.value); setPage(1) }}
              className="w-full border-2 border-ink bg-white px-3 py-2 font-nunito text-sm text-ink"
            >
              {nicheOptions.map((n) => <option key={n} value={n}>{n}</option>)}
            </select>
          </div>
          <div>
            <p className="mb-1 font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted">Tier</p>
            <select
              value={tier}
              onChange={(e) => { setTier(e.target.value); setPage(1) }}
              className="w-full border-2 border-ink bg-white px-3 py-2 font-nunito text-sm text-ink"
            >
              {tierOptions.map((t) => <option key={t} value={t}>{t}</option>)}
            </select>
          </div>
          <div>
            <p className="mb-1 font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted">State</p>
            <select
              value={state}
              onChange={(e) => { setState(e.target.value); setPage(1) }}
              className="w-full border-2 border-ink bg-white px-3 py-2 font-nunito text-sm text-ink"
            >
              <option value="All">All States</option>
              {stateOptions.map((s) => <option key={s} value={s}>{s}</option>)}
            </select>
          </div>
          <div>
            <p className="mb-1 font-space text-[10px] font-bold uppercase tracking-[0.08em] text-muted">City</p>
            <input
              type="text"
              placeholder="e.g. Mumbai"
              value={city}
              onChange={(e) => { setCity(e.target.value); setPage(1) }}
              className="w-full border-2 border-ink bg-white px-3 py-2 font-nunito text-sm text-ink outline-none"
            />
          </div>
        </div>
      </div>

      {isLoading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {[1, 2, 3, 4, 5, 6].map((i) => (
            <div key={i} className="border-2 border-ink bg-white p-5 animate-pulse">
              <div className="h-12 w-12 bg-gray-200 rounded-full mb-3" />
              <div className="h-4 bg-gray-200 rounded w-2/3 mb-2" />
              <div className="h-3 bg-gray-200 rounded w-1/2" />
            </div>
          ))}
        </div>
      ) : error ? (
        <div className="border-2 border-[#EF4444] bg-[#FEE2E2] px-4 py-3 font-nunito text-sm text-[#B91C1C]">
          Error loading creators: {error instanceof Error ? error.message : 'Unknown error'}
        </div>
      ) : savedError ? (
        <div className="border-2 border-[#EF4444] bg-[#FEE2E2] px-4 py-3 font-nunito text-sm text-[#B91C1C]">
          Error loading saved data: {savedError instanceof Error ? savedError.message : 'Unknown error'}
        </div>
      ) : creators.length === 0 ? (
        <div className="border-2 border-ink bg-white p-8 text-center">
          <p className="text-2xl mb-2">🔍</p>
          <p className="font-nunito text-muted">No creators match your filters.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {creators.map((creator: CreatorPreview) => {
            const isSaved = savedIds.has(creator.id)
            return (
              <div key={creator.id} className="border-2 border-ink bg-white p-5 shadow-[3px_3px_0_#0D0D0D] hover:shadow-[5px_5px_0_#FF2D78] hover:-translate-y-0.5 transition-all">
                <Link href={`/dashboard/brand/creators/${creator.id}`}>
                  <div className="flex items-center gap-3 mb-3">
                    <div className="w-12 h-12 rounded-full bg-pink border-2 border-ink flex items-center justify-center font-jakarta text-lg font-bold text-white shrink-0">
                      {creator.full_name?.[0]?.toUpperCase() || creator.first_name?.[0]?.toUpperCase() || '?'}
                    </div>
                    <div className="flex-1 min-w-0">
                      <h3 className="font-jakarta text-base font-bold text-ink truncate">{creator.full_name || creator.first_name}</h3>
                      {creator.tier && (
                        <span className="font-space text-[9px] font-bold uppercase text-muted">{creator.tier}</span>
                      )}
                    </div>
                    {creator.instagram_verified && (
                      <span className="text-sm shrink-0" title="Instagram Verified">✅</span>
                    )}
                  </div>

                  <div className="space-y-1.5 font-nunito text-xs text-ink/70">
                    {creator.followers_count != null && (
                      <p>👥 {creator.followers_count.toLocaleString()} followers</p>
                    )}
                    {creator.starting_price != null && (
                      <p>💰 From ₹{(creator.starting_price).toLocaleString()}</p>
                    )}
                    {creator.engagement_rate != null && (
                      <p>📈 {creator.engagement_rate}% engagement</p>
                    )}
                    {creator.city && (
                      <p>📍 {creator.city}{creator.state ? `, ${creator.state}` : ''}</p>
                    )}
                  </div>

                  <div className="mt-3 flex flex-wrap gap-1.5">
                    {creator.niches?.slice(0, 3).map((n: string) => (
                      <span key={n} className="border border-ink bg-pink/10 px-2 py-0.5 font-space text-[9px] font-bold text-ink">{n}</span>
                    ))}
                  </div>
                </Link>

                <div className="mt-4 flex gap-2">
                  <Link
                    href={`/dashboard/brand/creators/${creator.id}`}
                    className="flex-1 border-2 border-ink bg-white px-3 py-2 text-center font-space text-[10px] font-bold uppercase text-ink hover:shadow-[2px_2px_0_#FF2D78] transition-all"
                  >
                    Profile
                  </Link>
                  <button
                    onClick={() => isSaved ? unsaveMutation.mutate(creator.id) : saveMutation.mutate(creator.id)}
                    disabled={saveMutation.isPending || unsaveMutation.isPending}
                    className={`w-10 h-10 border-2 border-ink flex items-center justify-center font-space text-sm font-bold transition-all disabled:opacity-50 ${
                      isSaved ? 'bg-pink text-white' : 'bg-white text-ink hover:bg-pink/10'
                    }`}
                    title={isSaved ? 'Unsave' : 'Save'}
                  >
                    {isSaved ? '★' : '☆'}
                  </button>
                </div>
              </div>
            )
          })}
        </div>
      )}

      {data && data.totalPages > 1 && (
        <div className="flex items-center justify-center gap-3">
          <button
            onClick={() => setPage((p) => Math.max(1, p - 1))}
            disabled={page === 1}
            className="border-2 border-ink bg-white px-4 py-2 font-space text-xs font-bold text-ink disabled:opacity-50"
          >
            ← Prev
          </button>
          <span className="font-nunito text-sm text-muted">Page {page} of {data.totalPages}</span>
          <button
            onClick={() => setPage((p) => Math.min(data.totalPages, p + 1))}
            disabled={page === data.totalPages}
            className="border-2 border-ink bg-white px-4 py-2 font-space text-xs font-bold text-ink disabled:opacity-50"
          >
            Next →
          </button>
        </div>
      )}
    </div>
  )
}
