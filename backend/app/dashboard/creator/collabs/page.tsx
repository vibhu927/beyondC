'use client'

import { useQuery } from '@tanstack/react-query'
import { creatorApi, type Collab } from '@/lib/api/creator'
import Link from 'next/link'
import { useState } from 'react'

const statusFilters = ['all', 'in_progress', 'completed']

export default function CreatorCollabsPage() {
  const [filter, setFilter] = useState('all')

  const { data, isLoading } = useQuery({
    queryKey: ['creator', 'collabs', filter],
    queryFn: () => creatorApi.getCollabs(filter === 'all' ? undefined : filter),
  })

  const collabs = data?.collabs || []

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <div>
        <h1 className="font-jakarta text-3xl font-extrabold text-ink">My Collabs</h1>
        <p className="mt-1 font-nunito text-base text-muted">All your brand collaborations.</p>
      </div>

      <div className="flex gap-2">
        {statusFilters.map((s) => (
          <button
            key={s}
            onClick={() => setFilter(s)}
            className={`border-2 border-ink px-4 py-2 font-space text-[10px] font-bold uppercase tracking-[0.08em] transition-all ${
              filter === s
                ? 'bg-neon text-ink shadow-[2px_2px_0_#0D0D0D]'
                : 'bg-white text-ink/70 hover:shadow-[2px_2px_0_#C8FF00]'
            }`}
          >
            {s.replace('_', ' ')}
          </button>
        ))}
      </div>

      {isLoading ? (
        <div className="space-y-3">
          {[1, 2, 3].map((i) => (
            <div key={i} className="border-2 border-ink bg-white p-5 animate-pulse">
              <div className="h-5 bg-gray-200 rounded w-1/2 mb-3" />
              <div className="h-3 bg-gray-200 rounded w-1/3" />
            </div>
          ))}
        </div>
      ) : collabs.length === 0 ? (
        <div className="border-2 border-ink bg-white p-8 text-center">
          <p className="text-2xl mb-2">🤝</p>
          <p className="font-nunito text-muted">No collaborations found.</p>
        </div>
      ) : (
        <div className="space-y-3">
          {collabs.map((collab: Collab) => (
            <Link
              key={collab.id}
              href={`/dashboard/creator/collabs/${collab.id}`}
              className="border-2 border-ink bg-white p-5 shadow-[3px_3px_0_#0D0D0D] hover:shadow-[5px_5px_0_#C8FF00] hover:-translate-y-0.5 transition-all block"
            >
              <div className="flex items-center justify-between gap-3">
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-3">
                    <h3 className="font-jakarta text-lg font-bold text-ink">{collab.brand_name || 'Brand'}</h3>
                    <span className={`rounded-full border border-ink px-2 py-0.5 font-space text-[9px] font-bold uppercase ${
                      collab.status === 'in_progress' ? 'bg-neon text-ink' :
                      collab.status === 'completed' ? 'bg-blue-200 text-ink' :
                      'bg-gray-200 text-muted'
                    }`}>
                      {collab.status}
                    </span>
                  </div>
                  {collab.campaign_title && (
                    <p className="font-nunito text-sm text-muted mt-1">{collab.campaign_title}</p>
                  )}
                </div>
                <span className="shrink-0 rounded-full border-2 border-ink bg-white px-2.5 py-0.5 font-space text-[9px] font-bold text-ink capitalize">
                  {collab.collab_type}
                </span>
              </div>

              <div className="mt-3 flex items-center gap-4 font-nunito text-sm text-ink/70">
                {collab.agreed_amount && (
                  <span className="font-bold text-ink">₹{(collab.agreed_amount).toLocaleString()}</span>
                )}
                <span>Milestone: {collab.milestone_status?.replace(/_/g, ' ') || 'N/A'}</span>
                {collab.rating && <span>⭐ {collab.rating}/5</span>}
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  )
}
